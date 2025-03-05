/*
* Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
*/

#import "VoximplantUtils.h"
#import <VoximplantWebRTC/VoximplantWebRTC.h>

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
        case VILoginErrorCodeMAUAccessDenied:
            return @"ERROR_MAU_ACCESS_DENIED";
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
        case VILoginErrorCodeMAUAccessDenied:
            return @"Monthly Active Users (MAU) limit is reached. Payment is required.";
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

+ (NSString *)convertMessagingErrorToString:(VIErrorEvent *)error {
    switch (error.errorCode) {
        case 1:
            return @"ERROR_TRANSPORT_MESSAGE_STRUCTURE_IS_WRONG";
        case 2:
            return @"ERROR_EVENT_NAME_IS_UNKNOWN";
        case 3:
            return @"ERROR_NOT_AUTHORIZED";
        case 8:
            return @"ERROR_CONVERSATION_DOES_NOT_EXIST";
        case 10:
            return @"ERROR_MESSAGE_DOES_NOT_EXIST";
        case 11:
            return @"ERROR_MESSAGE_DELETED";
        case 12:
            return @"ERROR_ACL";
        case 13:
            return @"ERROR_ALREADY_IN_PARTICIPANTS_LIST";
        case 15:
            return @"ERROR_PUBLIC_JOIN_IS_UNAVAILABLE";
        case 16:
            return @"ERROR_CONVERSATION_DELETED";
        case 18:
            return @"ERROR_USER_VALIDATION";
        case 19:
            return @"ERROR_USER_IS_NOT_IN_THE_PARTICIPANT_LIST";
        case 21:
            return @"ERROR_REQUESTED_NUMBER_TOO_BIG_OR_0";
        case 22:
            return @"ERROR_REQUESTED_NUMBER_TOO_BIG";
        case 23:
            return @"ERROR_MESSAGE_SIZE_EXCEEDS_LIMIT";
        case 24:
            return @"ERROR_WRONG_SEQUENCE_ARGUMENT";
        case 25:
            return @"ERROR_USER_NOT_FOUND";
        case 26:
            return @"ERROR_NOTIFICATION_EVENT_INCORRECT";
        case 28:
            return @"ERROR_FROM_GREATER_THAN_TO";
        case 30:
            return @"ERROR_IM_SERVICE_UNAVAILABLE";
        case 32:
            return @"ERROR_LIMIT_PER_SECOND";
        case 33:
            return @"ERROR_LIMIT_PER_MINUTE";
        case 34:
            return @"ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER";
        case 35:
            return @"ERROR_NUMBER_OF_USERS_IN_DIRECT";
        case 36:
            return @"ERROR_SPECIFY_MAXIMUM_TWO_PARAMS";
        case 37:
            return @"ERROR_ADDING_TO_DIRECT";
        case 38:
            return @"ERROR_REMOVING_FROM_DIRECT";
        case 39:
            return @"ERROR_EDITING_PARTICIPANTS_IN_DIRECT";
        case 40:
            return @"ERROR_LEAVING_DIRECT_NOT_ALLOWED";
        case 41:
            return @"ERROR_SPECIFY_AT_LEAST_TWO_PARAMS";
        case 500:
            return @"ERROR_INTERNAL";
        case 10000:
            return @"ERROR_METHOD_CALL_DISCARDED";
        case 10001:
            return @"ERROR_INVALID_ARGUMENTS";
        case 10002:
            return @"ERROR_TIMEOUT";
        case 10003:
            return @"ERROR_CLIENT_NOT_LOGGED_IN";
        case 10004:
            return @"ERROR_FAILED_TO_PROCESS_RESPONSE";
        case 0:
        default:
            return @"ERROR_SOMETHING_WENT_WRONG";
    }
}

+ (NSString *)convertAudioFileErrorToString:(VIAudioFileErrorCode)audioFileError {
     switch (audioFileError) {
         case VIAudioFileErrorCodeDestroyed:
             return @"ERROR_DESTROYED";
         case VIAudioFileErrorCodeInterrupted:
             return @"ERROR_INTERRUPTED";
         case VIAudioFileErrorCodeAlreadyPlaying:
             return @"ERROR_ALREADY_PLAYING";
         case VIAudioFileErrorCodeCallKitActivated:
             return @"ERROR_CALLKIT_ACTIVATED";
         case VIAudioFileErrorCodeCallKitDeactivated:
             return @"ERROR_CALLKIT_DEACTIVATED";
         case VIAudioFileErrorCodeFailedToConfigureAudioSession:
             return @"ERROR_FAILED_TO_CONFIGURE_AUDIO_SESSION";
         case VIAudioFileErrorCodeInternal:
         default:
             return @"ERROR_INTERNAL";
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

+ (NSNumber *)convertVideoStreamReceiveStopReasonToNumber:(VIVideoStreamReceiveStopReason)reason {
    if ([reason isEqualToString:VIVideoStreamReceiveStopReasonManual]) {
        return @(1);
    }
    return @(0);
}

+ (NSNumber *)convertQualityIssueLevelToInt:(VIQualityIssueLevel)level {
    switch(level) {
        case VIQualityIssueLevelNone:
            return @(0);
        case VIQualityIssueLevelMinor:
            return @(1);
        case VIQualityIssueLevelMajor:
            return @(2);
        case VIQualityIssueLevelCritical:
            return @(3);
        default:
            return @(0);
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

+ (VIVideoCodec)convertCodecFromString:(NSString *)codec {
    if ([codec isEqualToString:@"VP8"]) {
        return VIVideoCodecVP8;
    } else if ([codec isEqualToString:@"H264"]) {
        return VIVideoCodecH264;
    } else {
        return VIVideoCodecAuto;
    }
}

+ (NSNumber *)convertQualityIssueTypeToInt:(VIQualityIssueType)type {
    if ([type isEqual:VIQualityIssueTypeCodecMismatch]) {
        return @(0);
    } else if ([type isEqual:VIQualityIssueTypeLocalVideoDegradation]) {
        return @(1);
    } else if ([type isEqual:VIQualityIssueTypeHighMediaLatency]) {
        return @(2);
    } else if ([type isEqual:VIQualityIssueTypeIceDisconnected]) {
        return @(3);
    } else if ([type isEqual:VIQualityIssueTypeNoAudioSignal]) {
        return @(4);
    } else if ([type isEqual:VIQualityIssueTypePacketLoss]) {
        return @(5);
    } else if ([type isEqual:VIQualityIssueTypeNoAudioReceive]) {
        return @(6);
    } else if ([type isEqual:VIQualityIssueTypeNoVideoReceive]) {
        return @(7);
    } else {
        return @(3);
    }
}

+ (VIConnectionNode)convertStringToNode:(NSString *)node {
    if ([node isEqualToString:@"Node1"]) {
        return VIConnectionNodeNode1;
    } else if ([node isEqualToString:@"Node2"]) {
        return VIConnectionNodeNode2;
    } else if ([node isEqualToString:@"Node3"]) {
        return VIConnectionNodeNode3;
    } else if ([node isEqualToString:@"Node4"]) {
        return VIConnectionNodeNode4;
    } else if ([node isEqualToString:@"Node5"]) {
        return VIConnectionNodeNode5;
    } else if ([node isEqualToString:@"Node6"]) {
        return VIConnectionNodeNode6;
    } else if ([node isEqualToString:@"Node7"]) {
        return VIConnectionNodeNode7;
    } else if ([node isEqualToString:@"Node8"]) {
        return VIConnectionNodeNode8;
    } else if ([node isEqualToString:@"Node9"]) {
        return VIConnectionNodeNode9;
    } else if ([node isEqualToString:@"Node10"]) {
        return VIConnectionNodeNode10;
    } else if ([node isEqualToString:@"Node11"]) {
        return VIConnectionNodeNode11;
    } else {
        return VIConnectionNodeNode1;
    }
}

+ (BOOL)validateConnectionNodeString:(NSString *)node {
    return [node isEqualToString:@"Node1"] ||
    [node isEqualToString:@"Node2"] ||
    [node isEqualToString:@"Node3"] ||
    [node isEqualToString:@"Node4"] ||
    [node isEqualToString:@"Node5"] ||
    [node isEqualToString:@"Node6"] ||
    [node isEqualToString:@"Node7"] ||
    [node isEqualToString:@"Node8"] ||
    [node isEqualToString:@"Node9"] ||
    [node isEqualToString:@"Node10"] ||
    [node isEqualToString:@"Node11"];
}

@end


@implementation FlutterMethodCall (MethodType)

- (BOOL)isMethodCallOfType:(VIMethodType)type {
    NSArray<NSString *> *methodNameComponents = [self.method componentsSeparatedByString:@"."];
    return methodNameComponents && methodNameComponents.firstObject
    ? [methodNameComponents.firstObject isEqualToString:type]
    : NO;
}

- (FlutterMethodCall *)excludingType {
    NSArray<NSString *> *methodNameComponents = [self.method componentsSeparatedByString:@"."];
    NSString *method = methodNameComponents && methodNameComponents.count > 0
    ? methodNameComponents[1]
    : self.method;

    return [FlutterMethodCall methodCallWithMethodName:method
                                             arguments:self.arguments];
}

@end


@implementation NSNumber (FromTimeInterval)

+ (instancetype)fromTimeInterval:(NSTimeInterval)timeInterval {
    return @((NSInteger)round(timeInterval * 1000.0));
}

@end
