/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <VoxImplantSDK/VoxImplantSDK.h>

@interface VoximplantPlugin : NSObject<FlutterPlugin, FlutterStreamHandler, VILogDelegate>
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification;

@end
