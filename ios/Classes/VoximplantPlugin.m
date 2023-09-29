/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

#import "VoximplantPlugin.h"
#import "VoximplantUtils.h"
#import "VICallModule.h"
#import "VIAudioDeviceModule.h"
#import "VIClientModule.h"
#import "VoximplantCallManager.h"
#import "VICameraModule.h"
#import "VIMessagingModule.h"
#import "VIAudioFileModule.h"
#import "VIAudioFileManager.h"

@interface VoximplantPlugin()
@property(nonatomic, strong) FlutterEventChannel *logsEventChannel;
@property(nonatomic, strong) FlutterEventSink logsEventSink;
@property(nonatomic, strong) VIClientModule *clientModule;
@property(nonatomic, strong) VIAudioDeviceModule *audioDeviceModule;
@property(nonatomic, strong) VIAudioFileManager *audioFileManager;
@property(nonatomic, strong) VoximplantCallManager *callManager;
@property(nonatomic, strong) VICameraModule *cameraModule;
@property(nonatomic, strong) VIMessagingModule *messagingModule;
@end

@interface VIClient (Version)
+ (void)setVersionExtension:(NSString *)version;
@end

@interface VIClient (Utils)
+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification;
@end

@implementation VoximplantPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"plugins.voximplant.com/client"
                                                                binaryMessenger:[registrar messenger]];
    VoximplantPlugin* instance = [[VoximplantPlugin alloc] initWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
}

+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification {
    return [VIClient uuidForPushNotification:notification];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        self.registrar = registrar;
        self.logsEventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.voximplant.com/logs"
                                                          binaryMessenger:registrar.messenger];
        [self.logsEventChannel setStreamHandler:self];
        [VIClient setLogDelegate:self];
        self.callManager = [[VoximplantCallManager alloc] init];
        self.clientModule = [[VIClientModule alloc] initWithRegistrar:self.registrar callManager:self.callManager];
        self.audioDeviceModule = [[VIAudioDeviceModule alloc] initWithPlugin:self];
        self.audioFileManager = [[VIAudioFileManager alloc] initWithPlugin:self];
        self.cameraModule = [[VICameraModule alloc] init];
        self.messagingModule = [[VIMessagingModule alloc] initWithRegistrar:self.registrar];
        [VIClient setVersionExtension:@"flutter-3.10.1"];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call isMethodCallOfType:VIMethodTypeMessaging]) {
        if (!self.clientModule.client) {
            result([FlutterError errorWithCode:@"ERROR_CLIENT_NOT_LOGGED_IN"
                                       message:@"Client is not logged in."
                                       details:nil]);
            return;
        }
        if (!self.messagingModule.messenger) {
            self.messagingModule.messenger = self.clientModule.client.messenger;
        }
        [self.messagingModule handleMethodCall:[call excludingType] result:result];

    } else if ([call isMethodCallOfType:VIMethodTypeClient]) {
        [self.clientModule handleMethodCall:[call excludingType] result:result];

    } else if ([call isMethodCallOfType:VIMethodTypeCall]) {
        VICallModule *callModule = [self.callManager checkCallEvent:call.arguments result:result methodName:call.method];
        if (callModule) {
            [callModule handleMethodCall:[call excludingType] result:result];
        }

    } else if ([call isMethodCallOfType:VIMethodTypeVideoStream]) {
        VICallModule *callModule = [self.callManager findCallByStreamId:call.arguments result:result methodName:call.method];
        if (callModule) {
            [callModule handleMethodCall:[call excludingType] result:result];
        }

    } else if ([call isMethodCallOfType:VIMethodTypeAudioDevice]) {
        [self.audioDeviceModule handleMethodCall:[call excludingType] result:result];

    } else if ([call isMethodCallOfType:VIMethodTypeCamera]) {
        [self.cameraModule handleMethodCall:[call excludingType] result:result];

    } else if ([call isMethodCallOfType:VIMethodTypeAudioFile]) {
        [self.audioFileManager handleMethodCall:[call excludingType] result:result];

    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        if ([type isEqual:@"logs"]) {
            self.logsEventSink = events;
        }
    }
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        if ([type isEqual:@"logs"]) {
            self.logsEventSink = nil;
        }
    }
    return nil;
}

#pragma mark - VILogDelegate

- (void)didReceiveLogMessage:(NSString *)message severity:(VILogSeverity)severity {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.logsEventSink) {
            NSString *level = [self formatSeverityToString:severity];

            if (level) {
                self.logsEventSink(@{
                    @"event"               : @"onLogMessage",
                    @"level"               : level,
                    @"logMessage"          : message,
                                   });
            }
        }
    });
}

- (NSString*)formatSeverityToString:(VILogSeverity)severity {
    NSString *result = nil;

    switch(severity) {
        case VILogSeverityError:
            result = @"error";
            break;
        case VILogSeverityWarning:
            result = @"warning";
            break;
        case VILogSeverityInfo:
            result = @"info";
            break;
        case VILogSeverityDebug:
            result = @"debug";
            break;
        case VILogSeverityVerbose:
            result = @"verbose";
            break;
    }

    return result;
}

@end

