/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VoximplantCallManager.h"

@interface VoximplantCallManager()

@property(nonatomic, strong) NSMutableDictionary *callModules;

@end

@implementation VoximplantCallManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callModules = [NSMutableDictionary new];
    }
    return self;
}

- (VICallModule *)checkCallEvent:(NSDictionary *)arguments result:(FlutterResult)result methodName:(NSString *)methodName {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:[methodName stringByAppendingString:@": Invalid arguments"]
                            details:nil]);
        return nil;
    }
    NSString *callId = [arguments objectForKey:@"callId"];
    if (!callId) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:[methodName stringByAppendingString:@": Invalid callId"]
                            details:nil]);
        return nil;
    }
    VICallModule *callModule = [self.callModules objectForKey:callId];
    if (!callModule) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:[methodName stringByAppendingString:@": Failed to find call for callId"]
                            details:nil]);
    }
    return callModule;
}

- (VICallModule *)findCallByStreamId:(NSDictionary *)arguments result:(FlutterResult)result methodName:(NSString *)methodName {
    if (!arguments) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:[methodName stringByAppendingString:@": Invalid arguments"]
                            details:nil]);
        return nil;
    }
    NSString *streamId = [arguments objectForKey:@"streamId"];
    if (!streamId) {
        result([FlutterError errorWithCode:@"ERROR_INVALID_ARGUMENTS"
                            message:[methodName stringByAppendingString:@": Invalid streamId"]
                            details:nil]);
        return nil;
    }
    __block VICallModule *callModule = nil;
    [self.callModules enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VICallModule * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj hasVideoStreamId:streamId]) {
            callModule = obj;
            *stop = YES;
        }
    }];
    return callModule;
}

- (void)callHasEnded:(NSString *)callId {
    [self.callModules removeObjectForKey:callId];
}

- (void)addNewCall:(VICallModule *)callModule callId:(NSString *)callId {
    [self.callModules setObject:callModule forKey:callId];
}

@end

