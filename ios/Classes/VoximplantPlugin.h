/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <VoxImplant/VoxImplant.h>

@interface VoximplantPlugin : NSObject<FlutterPlugin>
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
+ (NSUUID *)uuidForPushNotification:(NSDictionary *)notification;

@end
