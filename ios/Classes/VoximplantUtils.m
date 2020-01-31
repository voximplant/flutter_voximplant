/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VoximplantUtils.h"

@implementation VoximplantUtils

+ (NSString *)convertLoginErrorToString:(VILoginErrorCode)code {
    switch (code) {
        case VILoginErrorCodeInvalidUsername:
            return @"ERROR_INVALID_USERNAME";
        case VILoginErrorCodeTimeout:
            return @"ERROR_TIMEOUT";
        case VILoginErrorCodeInvalidState:
            return @"ERROR_INVALID_STATE";
        case VILoginErrorCodeTokenExpired:
            return @"ERROR_TOKEN_EXPIRED";
        case VILoginErrorCodeAccountFrozen:
            return @"ERROR_ACCOUNT_FROZEN";
        case VILoginErrorCodeNetworkIssues:
            return @"ERROR_NETWORK_ISSUES";
        case VILoginErrorCodeInvalidPassword:
            return @"ERROR_INVALID_PASSWORD";
        case VILoginErrorCodeConnectionClosed:
            return @"ERROR_NETWORK_ISSUES";
        case VILoginErrorCodeInternalError:
        default:
            return @"ERROR_INTERNAL";
    }
}

+ (NSString *)getErrorDescriptionForLoginError:(VILoginErrorCode)code {
    switch (code) {
        case VILoginErrorCodeInvalidUsername:
            return @"Invalid username.";
        case VILoginErrorCodeTimeout:
            return @"Login is failed due to timeout.";
        case VILoginErrorCodeInvalidState:
            return @"Login is failed due to invalid state.";
        case VILoginErrorCodeTokenExpired:
            return @"Token expired.";
        case VILoginErrorCodeAccountFrozen:
            return @"Account frozen.";
        case VILoginErrorCodeNetworkIssues:
            return @"Connection to the Voximplant Cloud is closed due to network issues.";
        case VILoginErrorCodeInvalidPassword:
            return @"Invalid password.";
        case VILoginErrorCodeConnectionClosed:
            return @"Connection to the Voximplant Cloud is closed";
        case VILoginErrorCodeInternalError:
        default:
            return @"Internal error.";
    }
}

+ (NSString *)convertCallErrorToString:(VICallErrorCode)code {
    switch (code) {
        case VICallErrorCodeRejected:
            return @"ERROR_REJECTED";
        case VICallErrorCodeTimeout:
            return @"ERROR_TIMEOUT";
        case VICallErrorCodeMediaIsOnHold:
            return @"ERROR_MEDIA_IS_ON_HOLD";
        case VICallErrorCodeAlreadyInThisState:
            return @"ERROR_ALREADY_IN_THIS_STATE";
        case VICallErrorCodeIncorrectOperation:
            return @"ERROR_INCORRECT_OPERATION";
        case VICallErrorCodeInternalError:
        default:
            return @"ERROR_INTERNAL";
    }
}

+ (NSString *)getErrorDescriptionForCallError:(VICallErrorCode)code {
    switch (code) {
        case VICallErrorCodeRejected:
            return @"Operation is rejected";
        case VICallErrorCodeTimeout:
            return @"Operation is not completed in time";
        case VICallErrorCodeMediaIsOnHold:
            return @"Operation can't be performed due to the call is on hold. Unhold the call and repeat the operation";
        case VICallErrorCodeAlreadyInThisState:
            return @"The call is already in requested state";
        case VICallErrorCodeIncorrectOperation:
            return @"Operation is incorrect";
        case VICallErrorCodeInternalError:
        default:
            return @"Internal error occurred";
    }
}

+ (NSDictionary *)convertAuthParamsToDictionary:(VIAuthParams *)authParams {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:@((NSInteger)authParams.accessExpire) forKey:@"accessExpire"];
    [dictionary setValue:authParams.accessToken forKey:@"accessToken"];
    [dictionary setValue:@((NSInteger)authParams.refreshExpire) forKey:@"refreshExpire"];
    [dictionary setValue:authParams.refreshToken forKey:@"refreshToken"];
    return dictionary;
}

+ (NSNumber *)convertVideoStreamTypeToNumber:(VIVideoStreamType)type {
    switch (type) {
        case VIVideoStreamTypeScreenSharing:
            return [NSNumber numberWithInt:1];
        case VIVideoStreamTypeVideo:
        default:
            return [NSNumber numberWithInt:0];
    }
}

+ (int)convertVideoRotationToInt:(RTCVideoRotation)rotation {
    switch (rotation) {
        case RTCVideoRotation_90:
            return 1;
        case RTCVideoRotation_180:
            return 2;
        case RTCVideoRotation_270:
            return 3;
        case RTCVideoRotation_0:
        default:
            return 0;
    }
}

+ (BOOL)isBackCameraByCameraType:(NSNumber *)cameraType {
    if (!cameraType) {
        return false;
    }
    return [cameraType intValue] == 0;
}

@end
