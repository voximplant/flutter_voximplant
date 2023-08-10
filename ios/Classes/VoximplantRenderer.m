/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VoximplantRenderer.h"
#import "VoximplantUtils.h"

@interface VoximplantRenderer()
@property(nonatomic, strong) id<FlutterTextureRegistry> textureRegistry;
@property(nonatomic) CVPixelBufferRef pixelBufferRef;
@property(nonatomic) int frameWidth;
@property(nonatomic) int frameHeight;
@property(nonatomic, assign) RTCVideoRotation frameRotation;
@property(nonatomic, strong) FlutterEventChannel *rendererEventChannel;
@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, assign) BOOL reportRendererEvent;
@end

@implementation VoximplantRenderer

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)registry
                              messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.textureRegistry = registry;
        self.textureId = [registry registerTexture:self];
        self.frameWidth = 0;
        self.frameHeight = 0;
        NSString *channelName = [@"plugins.voximplant.com/renderer_" stringByAppendingFormat:@"%lld", self.textureId];
        self.rendererEventChannel = [FlutterEventChannel eventChannelWithName:channelName
                                                              binaryMessenger:messenger];
        [self.rendererEventChannel setStreamHandler:self];
    }
    return self;
}

- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    if (self.pixelBufferRef != nil){
        CVBufferRetain(self.pixelBufferRef);
        return self.pixelBufferRef;
    }
    return nil;
}

- (void)renderFrame:(nullable RTCVideoFrame *)frame {
    if (!frame) {
        NSLog(@"VOXFLUTTER >  renderer: renderFrame: skip frame");
        return;
    }

    [frame renderToCVPixelBuffer:self.pixelBufferRef];

    if (frame.rotation != self.frameRotation || frame.width * frame.height != self.frameWidth * self.frameHeight) {
        if (frame.rotation == RTCVideoRotation_90 || frame.rotation == RTCVideoRotation_270) {
            self.frameWidth = frame.height;
            self.frameHeight = frame.width;
        } else {
            self.frameWidth = frame.width;
            self.frameHeight = frame.height;
        }
        self.frameRotation = frame.rotation;
        [self sendResolutionChangedEvent];
    }

    __weak VoximplantRenderer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        VoximplantRenderer *strongSelf = weakSelf;
        [strongSelf.textureRegistry textureFrameAvailable:strongSelf.textureId];
    });
}

- (void)setSize:(CGSize)size {
    if (self.frameWidth != size.width || self.frameHeight != size.height) {
        NSLog(@"VOXFLUTTER >  renderer: setSize - size is changed");
        if (self.pixelBufferRef) {
            CVPixelBufferRelease(self.pixelBufferRef);
            self.pixelBufferRef = NULL;
        }
        NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
        CVPixelBufferCreate(kCFAllocatorDefault,
                            size.width, size.height,
                            kCVPixelFormatType_32BGRA,
                            (__bridge CFDictionaryRef)(pixelAttributes), &_pixelBufferRef);
        NSLog(@"VOXFLUTTER >  renderer: setSize - CVPixelBuffer is recreated");
    }
}

- (void)cleanup {
    [self.textureRegistry unregisterTexture:self.textureId];
}

- (void)dealloc {
    NSLog(@"VOXFLUTTER >  renderer: dealloc");
    if (self.pixelBufferRef) {
        NSLog(@"VOXFLUTTER >  renderer: dealloc - release CVPixelBuffer");
        CVBufferRelease(self.pixelBufferRef);
        NSLog(@"VOXFLUTTER >  renderer: dealloc - CVPixelBuffer is released");
    }
}

- (void)sendResolutionChangedEvent {
    __weak VoximplantRenderer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        VoximplantRenderer *strongSelf = weakSelf;
        if (self.eventSink) {
            NSMutableDictionary *event = [NSMutableDictionary new];
            [event setObject:@"resolutionChanged" forKey:@"event"];
            [event setObject:@(strongSelf.frameWidth) forKey:@"width"];
            [event setObject:@(strongSelf.frameHeight) forKey:@"height"];
            if (self.frameHeight != 0) {
                [event setObject:@((double)strongSelf.frameWidth / strongSelf.frameHeight) forKey:@"aspectRatio"];
            }
            [event setObject:@([VoximplantUtils convertVideoRotationToInt:strongSelf.frameRotation]) forKey:@"rotation"];
            [event setObject:@(strongSelf.textureId) forKey:@"textureId"];
            self.eventSink(event);
            self.reportRendererEvent = NO;
        } else {
            self.reportRendererEvent = YES;
        }
    });
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    if ([arguments isKindOfClass:[NSString class]]) {
        NSString *type = (NSString *)arguments;
        NSString *channelName = [@"plugins.voximplant.com/renderer_" stringByAppendingFormat:@"%lld", self.textureId];
        if ([type isEqual:channelName]) {
            self.eventSink = events;
        }
        if (self.reportRendererEvent) {
            [self sendResolutionChangedEvent];
        }
    }
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}
@end
