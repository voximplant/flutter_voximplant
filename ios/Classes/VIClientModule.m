/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VIClientModule.h"
#import "VoximplantUtils.h"

@interface VIClientModule()
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) VIClient *client;
@property(nonatomic, strong) NSMutableDictionary<NSString *, FlutterResult> *clientMethodCallResults;
@property(nonatomic, strong) FlutterEventChannel *incomingCallEventChannel;
@property(nonatomic, strong) FlutterEventSink incomingCallEventSink;
@property(nonatomic, strong) FlutterEventChannel *connectionClosedEventChannel;
@property(nonatomic, strong) FlutterEventSink connectionClosedEventSink;
@property(nonatomic, strong) VoximplantCallManager *callManager;
@end

@implementation VIClientModule

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar callManager:(VoximplantCallManager *)callManager {
    self = [super init];
    if (self) {
        self.registrar = registrar;
        self.callManager = callManager;
        self.clientMethodCallResults = [NSMutableDictionary new];
        self.incomingCallEventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.voximplant.com/incoming_calls"
                                                                  binaryMessenger:registrar.messenger];
        [self.incomingCallEventChannel setStreamHandler:self];
        self.connectionClosedEventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.voximplant.com/connection_closed"
                                                                      binaryMessenger:registrar.messenger];
        [self.connectionClosedEventChannel setStreamHandler:self];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"initClient" isEqualToString:call.method]) {
        [self initClient:call.arguments];
    } else if ([@"connect" isEqualToString:call.method]) {
        [self connectWithArguments:call.arguments result:result];
    } else if ([@"disconnect" isEqualToString:call.method]) {
        [self.client disconnect];
        [self.clientMethodCallResults setObject:result forKey:@"disconnect"];
    } else if ([@"login" isEqualToString:call.method]) {
        [self loginWithPassword:call.arguments result:result];
    } else if ([@"loginWithToken" isEqualToString:call.method]) {
        [self loginWithToken:call.arguments result:result];
    } else if ([@"getClientState" isEqualToString:call.method]) {
        result(@(self.client.clientState));
    } else if ([@"requestOneTimeKey" isEqualToString:call.method]) {
        [self requestOneTimeKey:call.arguments result:result];
    } else if ([@"tokenRefresh" isEqualToString:call.method]) {
        [self refreshToken:call.arguments result:result];
    } else if ([@"loginWithKey" isEqualToString:call.method]) {
        [self loginWithKey:call.arguments result:result];
    } else if ([@"call" isEqualToString:call.method]) {
        [self createAndStartCall:call.arguments result:result];
    } else if ([@"registerForPushNotifications" isEqualToString:call.method]) {
        [self registerForPushNotifications:call.arguments result:result];
    } else if ([@"unregisterFromPushNotifications" isEqualToString:call.method]) {
        [self unregisterFromPushNotifications:call.arguments result:result];
    } else if ([@"handlePushNotification" isEqualToString:call.method]) {
        [self handlePushNotification:call.arguments result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initClient:(NSDictionary *)arguments {
    NSNumber *logLevel = [arguments objectForKey:@"logLevel"];
    if (logLevel) {
        VILogLevel level = VILogLevelInfo;
        switch ([logLevel integerValue]) {
            case 0:
                level = VILogLevelError;
                break;
            case 1:
                level = VILogLevelWarning;
                break;
            case 2:
                level = VILogLevelInfo;
                break;
            case 3:
                level = VILogLevelDebug;
                break;
            case 4:
                level = VILogLevelVerbose;
                break;
            default:
                break;
        }
        [VIClient setLogLevel:level];
    }

    NSString *bundleId = [arguments objectForKey:@"bundleId"];
    if (bundleId == (id)[NSNull null]) bundleId = nil;
    self.client = [[VIClient alloc] initWithDelegateQueue:dispatch_get_main_queue() bundleId:bundleId];
    self.client.sessionDelegate = self;
    self.client.callManagerDelegate = self;
}

- (void)connectWithArguments:(NSDictionary *)arguments result:(FlutterResult)result {
    BOOL connectResult = false;
    if (arguments) {
        NSNumber *connectivityCheck = [arguments objectForKey:@"connectivityCheck"];
        NSArray *servers = [arguments objectForKey:@"servers"] != [NSNull null] ? [arguments objectForKey:@"servers"] : nil;
        connectResult = [self.client connectWithConnectivityCheck:[connectivityCheck boolValue] gateways:servers];
    } else {
        connectResult = [self.client connect];
    }
    if (connectResult) {
        [self.clientMethodCallResults setObject:result forKey:@"connect"];
    } else {
        result([FlutterError errorWithCode:@"ERROR_CONNECTION_FAILED" message:@"Invalid state" details:nil]);
    }
}

- (void)loginWithPassword:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *username = [arguments objectForKey:@"username"];
    if (username == (id)[NSNull null]) username = nil;
    NSString *password = [arguments objectForKey:@"password"];
    if (password == (id)[NSNull null]) password = nil;
    [self.client loginWithUser:username
                      password:password
                       success:^(NSString * _Nonnull displayName, VIAuthParams * _Nonnull authParams) {
                           NSMutableDictionary *resultParams = [NSMutableDictionary new];
                           [resultParams setObject:displayName forKey:@"displayName"];
                           [resultParams setValuesForKeysWithDictionary:[VoximplantUtils convertAuthParamsToDictionary:authParams]];
                           result(resultParams);
                       }
                       failure:^(NSError * _Nonnull error) {
                           result([FlutterError errorWithCode:[VoximplantUtils convertLoginErrorToString:error.code]
                                                      message:[VoximplantUtils getErrorDescriptionForLoginError:error.code]
                                                      details:nil]);
                       }];
}

- (void)loginWithToken:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *username = [arguments objectForKey:@"username"];
    if (username == (id)[NSNull null]) username = nil;
    NSString *token = [arguments objectForKey:@"token"];
    if (token == (id)[NSNull null]) token = nil;
    [self.client loginWithUser:username
                         token:token
                       success:^(NSString * _Nonnull displayName, VIAuthParams * _Nonnull authParams) {
                           NSMutableDictionary *resultParams = [NSMutableDictionary new];
                           [resultParams setObject:displayName forKey:@"displayName"];
                           [resultParams setValuesForKeysWithDictionary:[VoximplantUtils convertAuthParamsToDictionary:authParams]];
                           result(resultParams);
                       }
                       failure:^(NSError * _Nonnull error) {
                           result([FlutterError errorWithCode:[VoximplantUtils convertLoginErrorToString:error.code]
                                                      message:[VoximplantUtils getErrorDescriptionForLoginError:error.code]
                                                      details:nil]);
                       }];
}

- (void)loginWithKey:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *username = [arguments objectForKey:@"username"];
    if (username == (id)[NSNull null]) username = nil;
    NSString *hash = [arguments objectForKey:@"hash"];
    if (hash == (id)[NSNull null]) hash = nil;
    if (!username || !hash) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.loginWithOneTimeKey: username and/or hash is null"
                                   details:nil]);
        return;
    }
    [self.client loginWithUser:username
                    oneTimeKey:hash
                       success:^(NSString * _Nonnull displayName, VIAuthParams * _Nonnull authParams) {
                           NSMutableDictionary *resultParams = [NSMutableDictionary new];
                           [resultParams setObject:displayName forKey:@"displayName"];
                           [resultParams setValuesForKeysWithDictionary:[VoximplantUtils convertAuthParamsToDictionary:authParams]];
                           result(resultParams);
                       } failure:^(NSError * _Nonnull error) {
                           result([FlutterError errorWithCode:[VoximplantUtils convertLoginErrorToString:error.code]
                                                      message:[VoximplantUtils getErrorDescriptionForLoginError:error.code]
                                                      details:nil]);
                       }];
}

- (void)requestOneTimeKey:(NSString *)username result:(FlutterResult)result {
    if (!username) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.requestOneTimeKey: username is null"
                                   details:nil]);
        return;
    }
    [self.client requestOneTimeKeyWithUser:username
                                    result:^(NSString * _Nullable oneTimeKey, NSError * _Nullable error) {
                                        if (error) {
                                            result([FlutterError errorWithCode:[VoximplantUtils convertLoginErrorToString:error.code]
                                                                       message:[VoximplantUtils getErrorDescriptionForLoginError:error.code]
                                                                       details:nil]);
                                        } else {
                                            result(oneTimeKey);
                                        }
                                    }];
}

- (void)refreshToken:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *username = [arguments objectForKey:@"username"];
    if (username == (id)[NSNull null]) username = nil;
    NSString *refreshToken = [arguments objectForKey:@"refreshToken"];
    if (refreshToken == (id)[NSNull null]) refreshToken = nil;
    if (!username || !refreshToken) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.tokenRefresh: username and/or refreshToken is null"
                                   details:nil]);
        return;
    }
    [self.client refreshTokenWithUser:username
                                token:refreshToken
                               result:^(VIAuthParams * _Nullable authParams, NSError * _Nullable error) {
                                   if (error) {
                                       result([FlutterError errorWithCode:[VoximplantUtils convertLoginErrorToString:error.code]
                                                                  message:[VoximplantUtils getErrorDescriptionForLoginError:error.code]
                                                                  details:nil]);
                                   } else {
                                       result([VoximplantUtils convertAuthParamsToDictionary:authParams]);
                                   }
                               }];
}

- (void)registerForPushNotifications:(NSString *)token result:(FlutterResult)result {
    if (!token) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.registerForPushNotifications: Invalid arguments"
                                   details:nil]);
        return;
    }
    [self.client registerVoIPPushNotificationsToken:[self dataFromHexString:token]
                                         completion:nil];
    result(nil);
}

- (void)unregisterFromPushNotifications:(NSString *)token result:(FlutterResult)result {
    if (!token) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.unregisterFromPushNotifications: Invalid arguments"
                                   details:nil]);
        return;
    }
    [self.client unregisterVoIPPushNotificationsToken:[self dataFromHexString:token]
                                           completion:nil];
    result(nil);
}

- (void)handlePushNotification:(NSDictionary *)arguments result:(FlutterResult)result {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.handlePushNotification: Invalid arguments"
                                   details:nil]);
        return;
    }
    [self.client handlePushNotification:arguments];
    result(nil);
}

- (void)createAndStartCall:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *number = [arguments objectForKey:@"number"];
    if ([number isEqual:[NSNull null]]) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"Client.call: Number parameter can not be null"
                                   details:nil]);
        return;
    }
    NSString *customData = [arguments objectForKey:@"customData"] != [NSNull null] ? [arguments objectForKey:@"customData"] : nil;
    NSDictionary *headers = [arguments objectForKey:@"extraHeaders"] != [NSNull null] ? [arguments objectForKey:@"extraHeaders"] : nil;
    NSNumber *sendVideo = [arguments objectForKey:@"sendVideo"] != [NSNull null] ? [arguments objectForKey:@"sendVideo"] : @(NO);
    NSNumber *receiveVideo = [arguments objectForKey:@"receiveVideo"] != [NSNull null] ? [arguments objectForKey:@"receiveVideo"] : @(NO);
    BOOL conference = [[arguments objectForKey:@"conference"] boolValue];
    //TODO(yulia): add preferrable codec
    VICallSettings *callSettings = [[VICallSettings alloc] init];
    callSettings.customData = customData;
    callSettings.extraHeaders = headers;
    callSettings.videoFlags = [VIVideoFlags videoFlagsWithReceiveVideo:receiveVideo.boolValue sendVideo:sendVideo.boolValue];

    VICall *call = conference
        ? [self.client callConference:number settings:callSettings]
        : [self.client call:number settings:callSettings];
    
    if (call) {
        VICallModule *callModule = [[VICallModule alloc] initWithRegistrar:self.registrar callManager:self.callManager call:call];
        [self.callManager addNewCall:callModule callId:call.callId];
        [call start];
        NSMutableDictionary *resultParams = [NSMutableDictionary new];
        [resultParams setObject:call.callId forKey:@"callId"];
        result(resultParams);
    } else {
        result([FlutterError errorWithCode:@"ERROR_CLIENT_NOT_LOGGED_IN"
                                   message:@"Client.call: Client is not logged in"
                                   details:nil]);
    }
}

#pragma mark - VIClientSessionDelegate
- (void)client:(nonnull VIClient *)client sessionDidFailConnectWithError:(nonnull NSError *)error {
    FlutterResult result = [self.clientMethodCallResults objectForKey:@"connect"];
    if (result) {
        [self.clientMethodCallResults removeObjectForKey:@"connect"];
        result([FlutterError errorWithCode:@"ERROR_CONNECTION_FAILED"
                                   message:error.localizedDescription
                                   details:nil]);
    }
}

- (void)clientSessionDidConnect:(nonnull VIClient *)client {
    FlutterResult result = [self.clientMethodCallResults objectForKey:@"connect"];
    if (result) {
        [self.clientMethodCallResults removeObjectForKey:@"connect"];
        result(nil);
    }
}

- (void)clientSessionDidDisconnect:(nonnull VIClient *)client {
    FlutterResult result = [self.clientMethodCallResults objectForKey:@"disconnect"];
    if (result) {
        [self.clientMethodCallResults removeObjectForKey:@"disconnect"];
        result(nil);
    }
    if (self.connectionClosedEventSink) {
        self.connectionClosedEventSink(@{
            @"event" : @"connectionClosed"
        });
    }
}

#pragma mark - VIClientCallManagerDelegate

- (void)client:(VIClient *)client didReceiveIncomingCall:(VICall *)call withIncomingVideo:(BOOL)video headers:(NSDictionary *)headers {
    if (self.incomingCallEventSink) {
        VICallModule *callModule = [[VICallModule alloc] initWithRegistrar:self.registrar callManager:self.callManager call:call];
        [self.callManager addNewCall:callModule callId:call.callId];
        self.incomingCallEventSink(@{
            @"event"               : @"incomingCall",
            @"callId"              : call.callId,
            @"uuid"                : call.callKitUUID ? call.callKitUUID.UUIDString : [NSNull null],
            @"video"               : @(video),
            @"headers"             : headers ?: [NSNull null],
            @"endpointId"          : call.endpoints.firstObject.endpointId ?: [NSNull null],
            @"endpointUserName"    : call.endpoints.firstObject.user ?: [NSNull null],
            @"endpointDisplayName" : call.endpoints.firstObject.userDisplayName ?: [NSNull null],
            @"endpointSipUri"      : call.endpoints.firstObject.sipURI ?: [NSNull null],
            @"endpointPlace"       : call.endpoints.firstObject.place ?: [NSNull null]
        });
    }
}

- (void)client:(VIClient *)client pushDidExpire:(NSUUID *)callKitUUID {
    if (self.incomingCallEventSink) {
        self.incomingCallEventSink(@{
            @"event": @"pushDidExpire",
            @"uuid" : callKitUUID.UUIDString,
        });
    }
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        if ([type isEqual:@"connection_closed"]) {
            self.connectionClosedEventSink = nil;
        }
        if ([type isEqual:@"incoming_calls"]) {
            self.incomingCallEventSink = nil;
        }
    }
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        if ([type isEqual:@"connection_closed"]) {
            self.connectionClosedEventSink = events;
        }
        if ([type isEqual:@"incoming_calls"]) {
            self.incomingCallEventSink = events;
        }
    }
    return nil;
}

- (NSData *)dataFromHexString:(NSString *)string {
    NSMutableData *data = [NSMutableData dataWithCapacity: string.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < string.length / 2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

@end
