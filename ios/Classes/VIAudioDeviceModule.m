/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "VIAudioDeviceModule.h"

@interface VIAudioDeviceModule()
@property(nonatomic, strong) FlutterEventChannel *eventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, weak) VoximplantPlugin *plugin;
@property(nonatomic, strong) VIAudioManager *audioManager;
@end

@implementation VIAudioDeviceModule

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.plugin = plugin;
        self.audioManager = [VIAudioManager sharedAudioManager];
        self.audioManager.delegate = self;
        self.eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.voximplant.com/audio_device_events"
                                                      binaryMessenger:plugin.registrar.messenger];
        [self.eventChannel setStreamHandler:self];
    }
    
    return self;
}

- (void)selectAudioDevice:(NSDictionary *)arguments result:(FlutterResult)result {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"AudioDeviceManager.selectAudioDevice: Invalid arguments"
                            details:nil]);
        return;
    }
    NSNumber *audioDevice = [arguments objectForKey:@"audioDevice"];
    if (!audioDevice) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"AudioDeviceManager.selectAudioDevice: audioDevice is null"
                                   details:nil]);
        return;
    }
    [self.audioManager selectAudioDevice:[self convertNumberToAudioDevice:audioDevice]];
    result(nil);
}

- (void)getActiveDevice:(NSDictionary *)arguments result:(FlutterResult)result {
    VIAudioDevice *audioDevice = [self.audioManager currentAudioDevice];
    result([self convertAudioDeviceToNumber:audioDevice]);
}

- (void)getAudioDevices:(NSDictionary *)arguments result:(FlutterResult)result {
    NSSet *audioDevices = [self.audioManager availableAudioDevices];
    NSMutableArray<NSNumber*> * resultDevices = [[NSMutableArray alloc] init];
    for (VIAudioDevice* device in audioDevices) {
        [resultDevices addObject:[self convertAudioDeviceToNumber:device]];
    }
    result(resultDevices);
}

- (VIAudioDevice *)convertNumberToAudioDevice:(NSNumber *)device {
    if (!device) {
        return nil;
    }
    if ([device intValue] == 0 ) {
        return [VIAudioDevice deviceWithType:VIAudioDeviceTypeBluetooth];
    }
    if ([device intValue] == 1) {
        return [VIAudioDevice deviceWithType:VIAudioDeviceTypeReceiver];
    }
    if ([device intValue] == 2) {
        return [VIAudioDevice deviceWithType:VIAudioDeviceTypeSpeaker];
    }
    if ([device intValue] == 3) {
       return [VIAudioDevice deviceWithType:VIAudioDeviceTypeWired];
    }
    return [VIAudioDevice deviceWithType:VIAudioDeviceTypeNone];
}

- (NSNumber *)convertAudioDeviceToNumber:(VIAudioDevice *)device {
    switch (device.type) {
        case VIAudioDeviceTypeBluetooth:
            return [NSNumber numberWithInt:0];
        case VIAudioDeviceTypeReceiver:
            return [NSNumber numberWithInt:1];
        case VIAudioDeviceTypeSpeaker:
            return [NSNumber numberWithInt:2];
        case VIAudioDeviceTypeWired:
            return [NSNumber numberWithInt:3];
        default:
            return [NSNumber numberWithInt:4];
    }
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (void)audioDeviceChanged:(VIAudioDevice *)audioDevice {
    if (self.eventSink) {
        self.eventSink(@{
            @"event": @"audioDeviceChanged",
            @"audioDevice" : [self convertAudioDeviceToNumber:audioDevice]
        });
    }
}

- (void)audioDeviceUnavailable:(VIAudioDevice *)audioDevice {
    
}

- (void)audioDevicesListChanged:(NSSet<VIAudioDevice *> *)availableAudioDevices {
    NSMutableArray<NSNumber*> * resultDevices = [[NSMutableArray alloc] init];
    for (VIAudioDevice* device in availableAudioDevices) {
        [resultDevices addObject:[self convertAudioDeviceToNumber:device]];
    }
    if (self.eventSink) {
        self.eventSink(@{
            @"event" : @"audioDeviceListChanged",
            @"audioDeviceList" : resultDevices
        });
    }
}

@end
