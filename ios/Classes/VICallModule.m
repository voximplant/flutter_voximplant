/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "VICallModule.h"
#import "VoximplantUtils.h"

@interface VICallModule()
@property(nonatomic, strong) VICall *call;
@property(nonatomic, strong) FlutterEventChannel *eventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, weak) VoximplantPlugin *plugin;
@end


@implementation VICallModule

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin call:(VICall *)call {
    self = [super init];
    
    if (self) {
        self.plugin = plugin;
        self.call = call;
        NSString *channelName = [@"plugins.voximplant.com/call_" stringByAppendingString:self.call.callId];
        self.eventChannel = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:plugin.registrar.messenger];
        [self.eventChannel setStreamHandler:self];
    }
    
    return self;
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
    VICallSettings *callSettings = [[VICallSettings alloc] init];
    callSettings.customData = customData;
    callSettings.extraHeaders = headers;
    callSettings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:NO sendVideo:NO];
    
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
    self.call.sendAudio = [enable boolValue];
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

#pragma mark - VICallDelegate

- (void)callDidStartAudio:(VICall *)call {
    [self sendEvent:@{
        @"event" : @"callStartAudio"
    }];
}

- (void)call:(VICall *)call didAddEndpoint:(VIEndpoint *)endpoint {
    [endpoint setDelegate:self];
    [self sendEvent:@{
        @"event"       : @"endpointAdded",
        @"endpointId"  : endpoint.endpointId,
        @"userName"    : endpoint.user ? endpoint.user : [NSNull null],
        @"displayName" : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
        @"sipUri"      : endpoint.sipURI ? endpoint.sipURI : [NSNull null]
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
    for (VIEndpoint *endpoint in self.call.endpoints) {
        endpoint.delegate = nil;
    }
    [self.call removeDelegate:self];
    [self sendEvent:@{
        @"event"       : @"callFailed",
        @"code"        : @(error.code),
        @"description" : error.description,
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
    for (VIEndpoint *endpoint in self.call.endpoints) {
        endpoint.delegate = nil;
    }
    [self.call removeDelegate:self];
    [self.plugin callHasEnded:call.callId];
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

#pragma mark - VIEndpointDeelegate

- (void)endpointInfoDidUpdate:(VIEndpoint *)endpoint {
    [self sendEvent:@{
        @"event"               : @"endpointInfoUpdated",
        @"endpointId"          : endpoint.endpointId,
        @"endpointUserName"    : endpoint.user ? endpoint.user : [NSNull null],
        @"endpointDisplayName" : endpoint.userDisplayName ? endpoint.userDisplayName : [NSNull null],
        @"endpointSipUri"      : endpoint.sipURI ? endpoint.sipURI : [NSNull null]
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
