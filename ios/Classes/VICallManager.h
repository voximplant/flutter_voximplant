/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "VICallModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface VICallManager : NSObject
- (VICallModule *)checkCallEvent:(NSDictionary *)arguments result:(FlutterResult)result methodName:(NSString *)methodName;

- (void)callHasEnded:(NSString *)callId;

- (void)addNewCall:(VICallModule *)callModule callId:(NSString *)callId;
@end

NS_ASSUME_NONNULL_END
