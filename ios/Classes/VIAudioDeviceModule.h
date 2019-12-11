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

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
