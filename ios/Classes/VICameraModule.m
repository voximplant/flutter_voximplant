/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/


#import "VICameraModule.h"
#import "VoximplantUtils.h"

@interface VICameraModule()
@property(nonatomic, strong) VICameraManager *cameraManager;
@end

@implementation VICameraModule

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cameraManager = [VICameraManager sharedCameraManager];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"selectCamera" isEqualToString:call.method]) {
        [self selectCamera:call.arguments result:result];
    } else if ([@"setCameraResolution" isEqualToString:call.method]) {
        [self selectCameraResolution:call.arguments result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)selectCamera:(NSDictionary *)arguments result:(FlutterResult)result {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"VICameraManager.selectCamera: Invalid arguments"
                            details:nil]);
        return;
    }
    NSNumber *cameraType = [arguments objectForKey:@"cameraType"];
    if (!cameraType) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                                   message:@"VICameraManager.selectCamera: Invalid camera type"
                                   details:nil]);
        return;
    }
    self.cameraManager.useBackCamera = [VoximplantUtils isBackCameraByCameraType:cameraType];
    result(nil);
}

- (void)selectCameraResolution:(NSDictionary *)arguments result:(FlutterResult)result {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"VICameraManager.selectCameraResolution: Invalid arguments"
                            details:nil]);
        return;
    }
    NSNumber *width = [arguments objectForKey:@"width"];
    NSNumber *height = [arguments objectForKey:@"height"];
    if (!width || !height) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:@"VICameraManager.selectCameraResolution: width or height is not specified"
                            details:nil]);
        return;
    }
    AVCaptureDevicePosition position = self.cameraManager.useBackCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    NSArray<AVCaptureDevice *> *captureDevices = [self.cameraManager captureDevices];
    AVCaptureDevice *captureDevice = captureDevices[0];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    NSArray<AVCaptureDeviceFormat *> *formats = [self.cameraManager supportedFormatsForDevice:captureDevice];
    int targetWidth = [width intValue];
    int targetHeight = [height intValue];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        }
    }
    [self.cameraManager changeCaptureFormat:selectedFormat];
    result(nil);
}

@end
