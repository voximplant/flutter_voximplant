/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "VoximplantPlugin.h"
#import "VoximplantUtils.h"
#import "VICallModule.h"
#import "VIAudioDeviceModule.h"
#import "VIClientModule.h"
#import "VICallManager.h"

@interface VoximplantPlugin()
@property(nonatomic, strong) VIClientModule *clientModule;
@property(nonatomic, strong) VIAudioDeviceModule *audioDeviceModule;
@property(nonatomic, strong) VICallManager *callManager;
@end

@interface VIClient (Version)
+ (void)setVersionExtension:(NSString *)version;
@end

@interface VIClient (Utils)
+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification;
@end

@implementation VoximplantPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.voximplant.com/client"
                                     binaryMessenger:[registrar messenger]];
    VoximplantPlugin* instance = [[VoximplantPlugin alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification {
    return [VIClient uuidForPushNotification:notification];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    self = [super init];
    if (self) {
        self.registrar = registrar;
        self.callManager = [[VICallManager alloc] init];
        self.clientModule = [[VIClientModule alloc] initWithRegistrar:self.registrar callManager:self.callManager];
        self.audioDeviceModule = [[VIAudioDeviceModule alloc] initWithPlugin:self];
        [VIClient setVersionExtension:@"flutter-1.2.0"];
    }
    return self;
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([self isClientMethod:call]) {
        [self.clientModule handleMethodCall:call result:result];
    } else if ([self isCallMethod:call]) {
        VICallModule *callModule = [self.callManager checkCallEvent:call.arguments result:result methodName:call.method];
        if (callModule) {
            [callModule handleMethodCall:call result:result];
        }
    } else if ([self isAudioDeviceMethod:call] ) {
        [self.audioDeviceModule handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)isClientMethod:(FlutterMethodCall *)call {
    NSString *method = call.method;
    if (!method) {
        return false;
    }
    return [method isEqualToString:@"initClient"] ||
        [method isEqualToString:@"connect"] ||
        [method isEqualToString:@"disconnect"] ||
        [method isEqualToString:@"login"] ||
        [method isEqualToString:@"loginWithToken"] ||
        [method isEqualToString:@"getClientState"] ||
        [method isEqualToString:@"requestOneTimeKey"] ||
        [method isEqualToString:@"tokenRefresh"] ||
        [method isEqualToString:@"loginWithKey"] ||
        [method isEqualToString:@"call"] ||
        [method isEqualToString:@"registerForPushNotifications"] ||
        [method isEqualToString:@"unregisterFromPushNotifications"] ||
        [method isEqualToString:@"handlePushNotification"];
}

- (BOOL)isAudioDeviceMethod:(FlutterMethodCall *)call {
    NSString *method = call.method;
    if (!method) {
        return false;
    }
    return [method isEqualToString:@"selectAudioDevice"] ||
        [method isEqualToString:@"getActiveDevice"] ||
        [method isEqualToString:@"getAudioDevices"] ||
        [method isEqualToString:@"callKitConfigureAudioSession"] ||
        [method isEqualToString:@"callKitReleaseAudioSession"] ||
        [method isEqualToString:@"callKitStartAudioSession"] ||
        [method isEqualToString:@"callKitStopAudio"];
}

- (BOOL)isCallMethod:(FlutterMethodCall *)call {
    NSString *method = call.method;
    if (!method) {
        return false;
    }
    return [method isEqualToString:@"answerCall"] ||
        [method isEqualToString:@"rejectCall"] ||
        [method isEqualToString:@"hangupCall"] ||
        [method isEqualToString:@"sendAudioForCall"] ||
        [method isEqualToString:@"sendInfoForCall"] ||
        [method isEqualToString:@"sendMessageForCall"] ||
        [method isEqualToString:@"sendToneForCall"] ||
        [method isEqualToString:@"holdCall"] ||
        [method isEqualToString:@"setCallKitUUID"];
}

@end
