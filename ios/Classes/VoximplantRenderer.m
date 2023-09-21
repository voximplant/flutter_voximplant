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
@property(nonatomic, strong) VIRTCVideoFrame *frameToRender;
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
    @synchronized (self) {
        if (!self.frameToRender) {
            return nil;
        }
        VIRTCVideoFrame *frame = self.frameToRender;
        int width = 0;
        int height = 0;
        
        if (frame.rotation == RTCVideoRotation_90 || frame.rotation == RTCVideoRotation_270) {
            width = frame.height;
            height = frame.width;
        } else {
            width = frame.width;
            height = frame.height;
        }

        if (!self.pixelBufferRef) {
            [self recreateCVPixelBufferWithWidth:width height:height];
        }

        if ((width != self.frameWidth && height != self.frameHeight) || frame.rotation != self.frameRotation) {
            self.frameWidth = width;
            self.frameHeight = height;
            self.frameRotation = frame.rotation;

            [self sendResolutionChangedEvent];

            [self recreateCVPixelBufferWithWidth:self.frameWidth height:self.frameHeight];
        }

        [frame renderToCVPixelBuffer:self.pixelBufferRef];
        CVPixelBufferRetain(self.pixelBufferRef);
        return self.pixelBufferRef;
    }
}

- (void)renderFrame:(nullable VIRTCVideoFrame *)frame {
    if (!frame) {
        return;
    }
    @synchronized (self) {
        self.frameToRender = frame;
    }

    __weak VoximplantRenderer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        VoximplantRenderer *strongSelf = weakSelf;
        [strongSelf.textureRegistry textureFrameAvailable:strongSelf.textureId];
    });
}

- (void)setSize:(CGSize)size {
}

- (void)recreateCVPixelBufferWithWidth:(int)width height:(int)height {
    if (self.pixelBufferRef) {
        CVPixelBufferRelease(self.pixelBufferRef);
        self.pixelBufferRef = NULL;
    }

    NSDictionary *pixelAttributes = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (NSString*)kCVPixelBufferMetalCompatibilityKey : @YES
    };
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width, height,
                        kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)(pixelAttributes), &_pixelBufferRef);
}

- (void)cleanup {
    [self.textureRegistry unregisterTexture:self.textureId];
}

- (void)sendResolutionChangedEvent {
    __weak VoximplantRenderer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        VoximplantRenderer *strongSelf = weakSelf;
        if (strongSelf.eventSink) {
            NSMutableDictionary *event = [NSMutableDictionary new];
            [event setObject:@"resolutionChanged" forKey:@"event"];
            [event setObject:@(strongSelf.frameWidth) forKey:@"width"];
            [event setObject:@(strongSelf.frameHeight) forKey:@"height"];
            if (strongSelf.frameHeight != 0) {
                [event setObject:@((double)strongSelf.frameWidth / strongSelf.frameHeight) forKey:@"aspectRatio"];
            }
            [event setObject:@([VoximplantUtils convertVideoRotationToInt:strongSelf.frameRotation]) forKey:@"rotation"];
            [event setObject:@(strongSelf.textureId) forKey:@"textureId"];
            strongSelf.eventSink(event);
            strongSelf.reportRendererEvent = NO;
        } else {
            strongSelf.reportRendererEvent = YES;
        }
    });
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
    if (self.pixelBufferRef) {
        CVBufferRelease(self.pixelBufferRef);
        self.pixelBufferRef = NULL;
    }
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
