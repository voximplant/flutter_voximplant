/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VICallModule.h"
#import "VoximplantUtils.h"
#import "VoximplantCallManager.h"

@interface VICallModule()
@property(nonatomic, strong) VICall *call;
@property(nonatomic, strong) FlutterEventChannel *eventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, weak) VoximplantCallManager *callManager;
@property(nonatomic, strong) VIVideoStream *localVideoStream;
@property(nonatomic, strong) NSMutableDictionary<NSString *, VIVideoStream *> *remoteVideoStreams;
@property(nonatomic, strong) NSMutableDictionary<NSString *, VoximplantRenderer *> *renderers;
@end


@implementation VICallModule

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                      callManager:(VoximplantCallManager *)callManager
                             call:(VICall *)call {
    self = [super init];
    
    if (self) {
        self.registrar = registrar;
        self.callManager = callManager;
        self.call = call;
        self.remoteVideoStreams = [NSMutableDictionary new];
        self.renderers = [NSMutableDictionary new];
        NSString *channelName = [@"plugins.voximplant.com/call_" stringByAppendingString:self.call.callId];
        self.eventChannel = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:registrar.messenger];
        [self.eventChannel setStreamHandler:self];
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"setCallKitUUID" isEqualToString:call.method]) {
        [self setCallKitUUID:call.arguments result:result];
    } else if ([@"answerCall" isEqualToString:call.method]) {
        [self answerCall:call.arguments result:result];
    } else if ([@"rejectCall" isEqualToString:call.method]) {
        [self rejectCall:call.arguments result:result];
    } else if ([@"hangupCall" isEqualToString:call.method]) {
        [self hangupCall:call.arguments result:result];
    } else if ([@"sendAudioForCall" isEqualToString:call.method]) {
        [self sendAudioForCall:call.arguments result:result];
    } else if ([@"sendInfoForCall" isEqualToString:call.method]) {
        [self sendInfoForCall:call.arguments result:result];
    } else if ([@"sendMessageForCall" isEqualToString:call.method]) {
        [self sendMessageForCall:call.arguments result:result];
    } else if ([@"sendToneForCall" isEqualToString:call.method]) {
        [self sendToneForCall:call.arguments result:result];
    } else if ([@"holdCall" isEqualToString:call.method]) {
        [self holdCall:call.arguments result:result];
    } else if ([@"sendVideoForCall" isEqualToString:call.method]) {
        [self sendVideo:call.arguments result:result];
    } else if ([@"receiveVideoForCall" isEqualToString:call.method]) {
        [self receiveVideoWithResult:result];
    } else if ([@"addVideoRenderer" isEqualToString:call.method]) {
        [self addVideoRenderer:call.arguments result:result];
    } else if ([@"removeVideoRenderer" isEqualToString:call.method]) {
        [self removeVideoRenderer:call.arguments result:result];
    } else if ([@"getCallDuration" isEqualToString:call.method]) {
        [self getCallDuration:call.arguments result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)setCallKitUUID:(NSDictionary *)arguments result:(FlutterResult)result {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[arguments objectForKey:@"uuid"]];
    if (!uuid) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.setCallKitUUID: Invalid UUID"
                                   details:nil]);
    }

    self.call.callKitUUID = uuid;
    result(nil);
}

- (void)answerCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *customData = [arguments objectForKey:@"customData"] != [NSNull null] ? [arguments objectForKey:@"customData"] : nil;
    NSDictionary *headers = [arguments objectForKey:@"extraHeaders"] != [NSNull null] ? [arguments objectForKey:@"extraHeaders"] : nil;
    NSNumber *sendVideo = [arguments objectForKey:@"sendVideo"] != [NSNull null] ? [arguments objectForKey:@"sendVideo"] : @(NO);
    NSNumber *receiveVideo = [arguments objectForKey:@"receiveVideo"] != [NSNull null] ? [arguments objectForKey:@"receiveVideo"] : @(NO);
    //TODO(yulia): add preferrable codec
    VICallSettings *callSettings = [[VICallSettings alloc] init];
    callSettings.customData = customData;
    callSettings.extraHeaders = headers;
    callSettings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:receiveVideo.boolValue sendVideo:sendVideo.boolValue];
    
    [self.call answerWithSettings:callSettings];
    result(nil);
}

- (void)rejectCall:(NSDictionary *)arguments result:(FlutterResult)result {
    VIRejectMode rejectMode = VIRejectModeDecline;
    NSString *rejectModeArg = [arguments objectForKey:@"rejectMode"];
    if ([rejectModeArg isEqualToString:@"reject"]) {
        rejectMode= VIRejectModeBusy;
    }
    NSDictionary *headers = [arguments objectForKey:@"headers"] != [NSNull null] ? [arguments objectForKey:@"headers"] : nil;
    [self.call rejectWithMode:rejectMode headers:headers];
    result(nil);
}

- (void)hangupCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSDictionary *headers = [arguments objectForKey:@"headers"] != [NSNull null] ? [arguments objectForKey:@"headers"] : nil;
    [self.call hangupWithHeaders:headers];
    result(nil);
}

- (void)sendAudioForCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSNumber *enable = [arguments objectForKey:@"enable"];
    if (!enable) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendAudio: Failed to get enable parameter"
                                   details:nil]);
        return;
    }
    self.call.sendAudio = enable.boolValue;
    result(nil);
}

- (void)sendInfoForCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *mimeType = [arguments objectForKey:@"mimetype"];
    NSString *body = [arguments objectForKey:@"body"];
    NSDictionary *headers = [arguments objectForKey:@"headers"] != [NSNull null] ? [arguments objectForKey:@"headers"] : nil;
    if (!mimeType) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendInfo: Failed to get mimeType parameter"
                                   details:nil]);
        return;
    }
    if (!body) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendInfo: Failed to get body parameter"
                                   details:nil]);
        return;
    }
    [self.call sendInfo:body mimeType:mimeType headers:headers];
    result(nil);
}

- (void)sendMessageForCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *message = [arguments objectForKey:@"message"];
    if (!message) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendMessage: Failed to get message parameter"
                                   details:nil]);
        return;
    }
    [self.call sendMessage:message];
    result(nil);
}

- (void)sendToneForCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *tone = [arguments objectForKey:@"tone"];
    if (!tone) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendTone: Failed to get tone parameter"
                                   details:nil]);
        return;
    }
    [self.call sendDTMF:tone];
    result(nil);
}

- (void)holdCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSNumber *enable = [arguments objectForKey:@"enable"];
    if (!enable) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.hold: Failed to get enable parameter"
                                   details:nil]);
        return;
    }
    [self.call setHold:[enable boolValue] completion:^(NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[VoximplantUtils convertCallErrorToString:error.code]
                                       message:[VoximplantUtils getErrorDescriptionForCallError:error.code]
                                       details:nil]);
        } else {
            result(nil);
        }
    }];
}

- (void)sendVideo:(NSDictionary *)arguments result:(FlutterResult)result {
    NSNumber *enable = [arguments objectForKey:@"enable"];
    if (!enable) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.sendVideo: Failed to get enable parameter"
                                   details:nil]);
        return;
    }
    [self.call setSendVideo:[enable boolValue] completion:^(NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[VoximplantUtils convertCallErrorToString:error.code]
                                       message:[VoximplantUtils getErrorDescriptionForCallError:error.code]
                                       details:nil]);
        } else {
            result(nil);
        }
    }];
}

- (void)receiveVideoWithResult:(FlutterResult)result {
    [self.call startReceiveVideoWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[VoximplantUtils convertCallErrorToString:error.code]
                                       message:[VoximplantUtils getErrorDescriptionForCallError:error.code]
                                       details:nil]);
        } else {
            result(nil);
        }
    }];
}

- (void)addVideoRenderer:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *streamId = [arguments objectForKey:@"streamId"];
    if (!streamId) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"Call.addVideoRenderer: Invalid streamId"
                            details:nil]);
        return;
    }
    if ([self.localVideoStream.streamId isEqualToString:streamId]) {
        VoximplantRenderer *renderer = [[VoximplantRenderer alloc] initWithTextureRegistry:self.registrar.textures
                                                                                 messenger:self.registrar.messenger];
        [self.localVideoStream addRenderer:renderer];
        [self.renderers setObject:renderer forKey:streamId];
        NSMutableDictionary *resultParams = [NSMutableDictionary new];
        [resultParams setObject:@(renderer.textureId) forKey:@"textureId"];
        result(resultParams);
        return;
    }
    VIVideoStream *videoStream = [self.remoteVideoStreams objectForKey:streamId];
    if (videoStream) {
        VoximplantRenderer *renderer = [[VoximplantRenderer alloc] initWithTextureRegistry:self.registrar.textures
                                                                                 messenger:self.registrar.messenger];
        [videoStream addRenderer:renderer];
        [self.renderers setObject:renderer forKey:streamId];
        NSMutableDictionary *resultParams = [NSMutableDictionary new];
        [resultParams setObject:@(renderer.textureId) forKey:@"textureId"];
        result(resultParams);
    } else {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.addVideoRenderer: Failed to find video stream by id"
                                   details:nil]);
    }
}

- (void)removeVideoRenderer:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *streamId = [arguments objectForKey:@"streamId"];
    if (!streamId) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"Call.removeVideoRenderer: Invalid streamId"
                            details:nil]);
        return;
    }
    if ([self.localVideoStream.streamId isEqualToString:streamId]) {
        VoximplantRenderer *renderer = [self.renderers objectForKey:streamId];
        [self.localVideoStream removeRenderer:renderer];
        [renderer cleanup];
        [self.renderers removeObjectForKey:streamId];
        self.localVideoStream = nil;
        result(nil);
        return;
    }
    VIVideoStream *videoStream = [self.remoteVideoStreams objectForKey:streamId];
    VoximplantRenderer *renderer = [self.renderers objectForKey:streamId];
    if (videoStream && renderer) {
        [videoStream removeRenderer:renderer];
        [renderer cleanup];
        [self.renderers removeObjectForKey:streamId];
        result(nil);
    } else {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Call.removeVideoRenderer: Failed to find video stream and video renderer by stream id"
                                   details:nil]);
    }
}

- (void)getCallDuration:(NSDictionary *)arguments result:(FlutterResult)result {
    result([NSNumber fromTimeInterval:[self.call duration]]);
}
 
- (BOOL)hasVideoStreamId:(NSString *)streamId {
    return [self.localVideoStream.streamId isEqualToString:streamId] || [self.remoteVideoStreams objectForKey:streamId] != nil;
}

- (void)cleanupResources {
    if (self.localVideoStream) {
        VoximplantRenderer *renderer = [self.renderers objectForKey:self.localVideoStream.streamId];
        if (renderer) {
            [self.localVideoStream removeRenderer:renderer];
            [renderer cleanup];
        }
        self.localVideoStream = nil;
    }
    [self.remoteVideoStreams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull streamId, VIVideoStream * _Nonnull videoStream, BOOL * _Nonnull stop) {
        VoximplantRenderer *renderer = [self.renderers objectForKey:streamId];
        if (renderer) {
            [videoStream removeRenderer:renderer];
            [renderer cleanup];
        }
    }];
    [self.renderers removeAllObjects];
    [self.remoteVideoStreams removeAllObjects];
    
    for (VIEndpoint *endpoint in self.call.endpoints) {
        endpoint.delegate = nil;
    }
    [self.call removeDelegate:self];
}

#pragma mark - VICallDelegate

- (void)callDidStartAudio:(VICall *)call {
    [self sendEvent:@{
        @"event" : @"callAudioStarted"
    }];
}

- (void)call:(VICall *)call didAddEndpoint:(VIEndpoint *)endpoint {
    [endpoint setDelegate:self];
    [self sendEvent:@{
        @"event"         : @"endpointAdded",
        @"endpointId"    : endpoint.endpointId,
        @"userName"      : endpoint.user ? endpoint.user : [NSNull null],
        @"displayName"   : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
        @"sipUri"        : endpoint.sipURI ? endpoint.sipURI : [NSNull null],
        @"endpointPlace" : endpoint.place ? endpoint.place : [NSNumber numberWithInt:0]
    }];
}

- (void)call:(VICall *)call didReceiveStatistics:(VICallStats *)stat {
    
}

- (void)call:(VICall *)call didConnectWithHeaders:(NSDictionary *)headers {
    [self sendEvent:@{
        @"event"   : @"callConnected",
        @"headers" : headers
    }];
}

- (void)call:(VICall *)call startRingingWithHeaders:(NSDictionary *)headers {
    [self sendEvent:@{
        @"event"   : @"callRinging",
        @"headers" : headers
    }];
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    [self cleanupResources];
    [self.callManager callHasEnded:call.callId];
    [self sendEvent:@{
        @"event"       : @"callFailed",
        @"code"        : @(error.code),
        @"description" : error.localizedDescription,
        @"headers"     : headers
    }];
}

- (void)call:(VICall *)call didReceiveMessage:(NSString *)message headers:(NSDictionary *)headers {
    [self sendEvent:@{
        @"event"   : @"messageReceived",
        @"message" : message,
        @"headers" : headers
    }];
}

- (void)call:(VICall *)call didReceiveInfo:(NSString *)body type:(NSString *)type headers:(NSDictionary *)headers {
    [self sendEvent:@{
        @"event"   : @"sipInfoReceived",
        @"type"    : type,
        @"body"    : body,
        @"headers" : headers
    }];
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    [self cleanupResources];
    [self.callManager callHasEnded:call.callId];
    [self sendEvent:@{
        @"event"             : @"callDisconnected",
        @"headers"           : headers,
        @"answeredElsewhere" : answeredElsewhere
    }];
}

- (void)iceTimeoutForCall:(VICall *)call {
    [self sendEvent:@{
        @"event" : @"iceTimeout"
    }];
}

- (void)iceCompleteForCall:(VICall *)call {
    [self sendEvent:@{
        @"event" : @"iceCompleted"
    }];
}

- (void)call:(VICall *)call didAddLocalVideoStream:(VIVideoStream *)videoStream {
    if (!self.localVideoStream) {
        self.localVideoStream = videoStream;
        [self sendEvent:@{
            @"event"           : @"localVideoStreamAdded",
            @"videoStreamId"   : videoStream.streamId,
            @"videoStreamType" : [VoximplantUtils convertVideoStreamTypeToNumber:videoStream.type]
        }];
    } else {
        NSLog(@"VOXFLUTTER >  call: didAddLocalVideoStream: local video stream has been already reported");
    }
}

- (void)call:(VICall *)call didRemoveLocalVideoStream:(VIVideoStream *)videoStream {
    if ([self.localVideoStream.streamId isEqualToString:videoStream.streamId]) {
        [self sendEvent:@{
            @"event"         : @"localVideoStreamRemoved",
            @"videoStreamId" : videoStream.streamId,
        }];
    } else {
        NSLog(@"VOXFLUTTER >  call: didRemoveLocalVideoStream: video stream id does not match to previously added video stream");
    }
}

#pragma mark - VIEndpointDeelegate

- (void)endpointInfoDidUpdate:(VIEndpoint *)endpoint {
    [self sendEvent:@{
        @"event"               : @"endpointInfoUpdated",
        @"endpointId"          : endpoint.endpointId,
        @"endpointUserName"    : endpoint.user ? endpoint.user : [NSNull null],
        @"endpointDisplayName" : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
        @"endpointSipUri"      : endpoint.sipURI ? endpoint.sipURI : [NSNull null],
        @"endpointPlace"       : endpoint.place ? endpoint.place : [NSNumber numberWithInt:0]
    }];
}

- (void)endpoint:(VIEndpoint *)endpoint didAddRemoteVideoStream:(VIVideoStream *)videoStream {
    [self.remoteVideoStreams setObject:videoStream forKey:videoStream.streamId];
    [self sendEvent:@{
        @"event"               : @"remoteVideoStreamAdded",
        @"endpointId"          : endpoint.endpointId,
        @"videoStreamId"       : videoStream.streamId,
        @"videoStreamType"     : [VoximplantUtils convertVideoStreamTypeToNumber:videoStream.type]
    }];
}

- (void)endpoint:(VIEndpoint *)endpoint didRemoveRemoteVideoStream:(VIVideoStream *)videoStream {
    [self sendEvent:@{
        @"event"               : @"remoteVideoStreamRemoved",
        @"endpointId"          : endpoint.endpointId,
        @"videoStreamId"       : videoStream.streamId,
    }];
}

- (void)endpointDidRemove:(VIEndpoint *)endpoint {
    [endpoint setDelegate:nil];
    [self sendEvent:@{
        @"event"      : @"endpointRemoved",
        @"endpointId" : endpoint.endpointId,
    }];
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        NSString *channelName = [@"plugins.voximplant.com/call_" stringByAppendingString:self.call.callId];
        if ([type isEqual:channelName]) {
            self.eventSink = events;
            [self.call addDelegate:self];
            
            for (VIEndpoint *endpoint in self.call.endpoints) {
                endpoint.delegate = self;
            }
        }
    }
    self.eventSink = events;
    return nil;
}

#pragma mark - Private

- (void)sendEvent:(NSDictionary *)event {
    if (self.eventSink) {
        self.eventSink(event);
    }
}

@end
