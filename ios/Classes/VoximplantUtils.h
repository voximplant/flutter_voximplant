/*
* Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Flutter/Flutter.h>
#import <VoxImplant/VoxImplant.h>

@interface VoximplantUtils : NSObject 

+ (NSString *)convertLoginErrorToString:(VILoginErrorCode)code;
+ (NSString *)getErrorDescriptionForLoginError:(VILoginErrorCode)code;
+ (NSString *)convertCallErrorToString:(VICallErrorCode)code;
+ (NSString *)getErrorDescriptionForCallError:(VICallErrorCode)code;
+ (NSDictionary *)convertAuthParamsToDictionary:(VIAuthParams *)authParams;
@end
