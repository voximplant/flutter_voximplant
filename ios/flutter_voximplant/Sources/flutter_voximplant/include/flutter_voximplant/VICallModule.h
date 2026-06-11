/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <VoxImplantSDK/VoxImplantSDK.h>

#import "VoximplantRenderer.h"

NS_ASSUME_NONNULL_BEGIN
@class VoximplantCallManager;

@interface VICallModule : NSObject <FlutterStreamHandler, VICallDelegate, VIEndpointDelegate, VIQualityIssueDelegate>

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                      callManager:(VoximplantCallManager *)callManager
                             call:(VICall *)call;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

- (BOOL)hasVideoStreamId:(NSString *)streamId;
@end

NS_ASSUME_NONNULL_END
