/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <VoxImplant/VoxImplant.h>
#import "VoximplantPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface VICallModule : NSObject <FlutterStreamHandler, VICallDelegate, VIEndpointDelegate, VIEndpointDelegate>

- (instancetype)initWithPlugin:(VoximplantPlugin *)plugin call:(VICall *)call;
- (void)answerCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)rejectCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)hangupCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)sendAudioForCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)sendInfoForCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)sendMessageForCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)sendToneForCall:(NSDictionary *)arguments result:(FlutterResult)result;
- (void)holdCall:(NSDictionary *)arguments result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
