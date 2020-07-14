/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <VoxImplant/VoxImplant.h>
#import "VoximplantCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface VIClientModule : NSObject<VIClientSessionDelegate, FlutterStreamHandler, VIClientCallManagerDelegate>

@property(nonatomic, strong, readonly) VIClient *client;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar callManager:(VoximplantCallManager *)callManager;

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
