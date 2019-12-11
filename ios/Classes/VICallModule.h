/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <VoxImplant/VoxImplant.h>

NS_ASSUME_NONNULL_BEGIN
@class VICallManager;

@interface VICallModule : NSObject <FlutterStreamHandler, VICallDelegate, VIEndpointDelegate, VIEndpointDelegate>

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                      callManager:(VICallManager *)callManager
                             call:(VICall *)call;
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
