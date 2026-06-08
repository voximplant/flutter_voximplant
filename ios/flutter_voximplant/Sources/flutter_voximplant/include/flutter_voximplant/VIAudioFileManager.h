/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

#import "VoximplantPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIAudioFileManager: NSObject

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
