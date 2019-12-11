/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <VoxImplant/VoxImplant.h>
#import "VICallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIClientModule : NSObject<VIClientSessionDelegate, FlutterStreamHandler, VIClientCallManagerDelegate>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar callManager:(VICallManager *)callManager;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
