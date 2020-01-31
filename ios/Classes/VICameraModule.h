/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/


#import <Foundation/Foundation.h>
#import <VoxImplant/VoxImplant.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface VICameraModule : NSObject

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
