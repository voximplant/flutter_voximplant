/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <VoxImplant/VoxImplant.h>
#import <Flutter/Flutter.h>
#import "VoximplantPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIAudioDeviceModule : NSObject<FlutterStreamHandler, VIAudioManagerDelegate>
- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin;
- (void)selectAudioDevice:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)getActiveDevice:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)getAudioDevices:(NSDictionary *)arguments result:(FlutterResult)result;

- (void)callKitConfigureAudioSession:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)callKitReleaseAudioSession:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)callKitStartAudio:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)callKitStopAudio:(NSDictionary *)arguments result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
