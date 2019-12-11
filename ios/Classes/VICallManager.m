/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "VICallManager.h"

@interface VICallManager()
@property(nonatomic, strong) NSMutableDictionary *callModules;

@end

@implementation VICallManager

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

- (void)callHasEnded:(NSString *)callId {
    [self.callModules removeObjectForKey:callId];
}

- (void)addNewCall:(VICallModule *)callModule callId:(NSString *)callId {
    [self.callModules setObject:callModule forKey:callId];
}

@end
