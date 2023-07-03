/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <VoxImplantSDK/VoxImplantSDK.h>
#import <Flutter/Flutter.h>
#import "VoximplantPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIAudioDeviceModule : NSObject<FlutterStreamHandler, VIAudioManagerDelegate>
- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin;

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
