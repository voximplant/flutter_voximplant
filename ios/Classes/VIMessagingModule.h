/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <VoxImplant/VoxImplant.h>

NS_ASSUME_NONNULL_BEGIN

@interface VIMessagingModule : NSObject <FlutterStreamHandler, VIMessengerDelegate>

@property(nonatomic, strong) VIMessenger *messenger;

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
