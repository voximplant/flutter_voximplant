/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoximplantRenderer : NSObject <FlutterTexture, RTCVideoRenderer, FlutterStreamHandler>

@property(nonatomic) int64_t textureId;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)cleanup;

@end

NS_ASSUME_NONNULL_END
