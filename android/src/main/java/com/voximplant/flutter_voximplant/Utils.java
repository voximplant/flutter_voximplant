/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import com.voximplant.sdk.call.CallError;
import com.voximplant.sdk.call.QualityIssue;
import com.voximplant.sdk.call.QualityIssueLevel;
import com.voximplant.sdk.call.VideoCodec;
import com.voximplant.sdk.call.VideoStreamReceiveStopReason;
import com.voximplant.sdk.call.VideoStreamType;
import com.voximplant.sdk.client.LoginError;
import com.voximplant.sdk.hardware.AudioFileUsage;
import com.voximplant.sdk.messaging.IErrorEvent;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INTERNAL;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_ACL;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_ADDING_TO_DIRECT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_ALREADY_IN_PARTICIPANTS_LIST;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_CLIENT_NOT_LOGGED_IN;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_CONVERSATION_DELETED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_CONVERSATION_DOES_NOT_EXIST;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_EDITING_PARTICIPANTS_IN_DIRECT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_EVENT_NAME_IS_UNKNOWN;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_FAILED_TO_PROCESS_RESPONSE;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_FROM_GREATER_THAN_TO;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_IM_SERVICE_UNAVAILABLE;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_INVALID_ARGUMENTS;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_LEAVING_DIRECT_NOT_ALLOWED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_LIMIT_PER_MINUTE;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_LIMIT_PER_SECOND;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_MESSAGE_DELETED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_MESSAGE_DOES_NOT_EXIST;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_MESSAGE_SIZE_EXCEEDS_LIMIT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_METHOD_CALL_DISCARDED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_NOTIFICATION_EVENT_INCORRECT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_NOT_AUTHORIZED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_NUMBER_OF_USERS_IN_DIRECT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_PUBLIC_JOIN_IS_UNAVAILABLE;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_REMOVING_FROM_DIRECT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_REQUESTED_NUMBER_TOO_BIG;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_REQUESTED_NUMBER_TOO_BIG_OR_0;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_SOMETHING_WENT_WRONG;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_SPECIFY_AT_LEAST_TWO_PARAMS;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_SPECIFY_MAXIMUM_TWO_PARAMS;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_TIMEOUT;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_TRANSPORT_MESSAGE_STRUCTURE_IS_WRONG;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_USER_IS_NOT_IN_THE_PARTICIPANT_LIST;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_USER_NOT_FOUND;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_USER_VALIDATION;
import static com.voximplant.flutter_voximplant.VoximplantErrors.Messaging.ERROR_WRONG_SEQUENCE_ARGUMENT;

import java.util.HashMap;
import java.util.Map;

class Utils {
    static String convertLoginErrorToString(LoginError error) {
        switch (error) {
            case INVALID_PASSWORD:
                return VoximplantErrors.ERROR_INVALID_PASSWORD;
            case ACCOUNT_FROZEN:
                return VoximplantErrors.ERROR_ACCOUNT_FROZEN;
            case INVALID_USERNAME:
                return VoximplantErrors.ERROR_INVALID_USERNAME;
            case TIMEOUT:
                return VoximplantErrors.ERROR_TIMEOUT;
            case INVALID_STATE:
                return VoximplantErrors.ERROR_INVALID_STATE;
            case NETWORK_ISSUES:
                return VoximplantErrors.ERROR_NETWORK_ISSUES;
            case TOKEN_EXPIRED:
                return VoximplantErrors.ERROR_TOKEN_EXPIRED;
            case MAU_ACCESS_DENIED:
                return VoximplantErrors.ERROR_MAU_ACCESS_DENIED;
            case INTERNAL_ERROR:
            default:
                return ERROR_INTERNAL;
        }
    }

    static String getErrorDescriptionForLoginError(LoginError error) {
        switch (error) {
            case INVALID_PASSWORD:
                return "Invalid password.";
            case ACCOUNT_FROZEN:
                return "Account frozen.";
            case INVALID_USERNAME:
                return "Invalid username.";
            case TIMEOUT:
                return "Login is failed due to timeout.";
            case INVALID_STATE:
                return "Login is failed due to invalid state.";
            case NETWORK_ISSUES:
                return "Connection to the Voximplant Cloud is closed due to network issues.";
            case TOKEN_EXPIRED:
                return "Token expired.";
            case MAU_ACCESS_DENIED:
                return "Monthly Active Users (MAU) limit is reached. Payment is required.";
            case INTERNAL_ERROR:
            default:
                return "Internal error.";
        }
    }

    static String convertCallErrorToString(CallError error) {
        switch (error) {
            case ALREADY_IN_THIS_STATE:
                return VoximplantErrors.ERROR_ALREADY_IN_THIS_STATE;
            case FUNCTIONALITY_IS_DISABLED:
                return VoximplantErrors.ERROR_FUNCTIONALITY_IS_DISABLED;
            case INCORRECT_OPERATION:
                return VoximplantErrors.ERROR_INCORRECT_OPERATION;
            case MEDIA_IS_ON_HOLD:
                return VoximplantErrors.ERROR_MEDIA_IS_ON_HOLD;
            case MISSING_PERMISSION:
                return VoximplantErrors.ERROR_MISSING_PERMISSION;
            case REJECTED:
                return VoximplantErrors.ERROR_REJECTED;
            case TIMEOUT:
                return VoximplantErrors.ERROR_TIMEOUT;
            case INTERNAL_ERROR:
                default:
                return VoximplantErrors.ERROR_INTERNAL;
        }
    }

    static String getErrorDescriptionForCallError(CallError error) {
        switch (error) {
            case ALREADY_IN_THIS_STATE:
                return "The call is already in requested state";
            case FUNCTIONALITY_IS_DISABLED:
                return "Requested functionality is disabled";
            case INCORRECT_OPERATION:
                return "Operation is incorrect";
            case MEDIA_IS_ON_HOLD:
                return "Operation can't be performed due to the call is on hold. Unhold the call and repeat the operation";
            case MISSING_PERMISSION:
                return "Operation can't be performed due to missing permission";
            case REJECTED:
                return "Operation is rejected";
            case TIMEOUT:
                return "Operation is not completed in time";
            case INTERNAL_ERROR:
                default:
                return "Internal error occurred";
        }
    }

    static String convertMessagingErrorToString(IErrorEvent error) {
        switch (error.getErrorCode()) {
            case 1:
                return ERROR_TRANSPORT_MESSAGE_STRUCTURE_IS_WRONG;
            case 2:
                return ERROR_EVENT_NAME_IS_UNKNOWN;
            case 3:
                return ERROR_NOT_AUTHORIZED;
            case 8:
                return ERROR_CONVERSATION_DOES_NOT_EXIST;
            case 10:
                return ERROR_MESSAGE_DOES_NOT_EXIST;
            case 11:
                return ERROR_MESSAGE_DELETED;
            case 12:
                return ERROR_ACL;
            case 13:
                return ERROR_ALREADY_IN_PARTICIPANTS_LIST;
            case 15:
                return ERROR_PUBLIC_JOIN_IS_UNAVAILABLE;
            case 16:
                return ERROR_CONVERSATION_DELETED;
            case 18:
                return ERROR_USER_VALIDATION;
            case 19:
                return ERROR_USER_IS_NOT_IN_THE_PARTICIPANT_LIST;
            case 21:
                return ERROR_REQUESTED_NUMBER_TOO_BIG_OR_0;
            case 22:
                return ERROR_REQUESTED_NUMBER_TOO_BIG;
            case 23:
                return ERROR_MESSAGE_SIZE_EXCEEDS_LIMIT;
            case 24:
                return ERROR_WRONG_SEQUENCE_ARGUMENT;
            case 25:
                return ERROR_USER_NOT_FOUND;
            case 26:
                return ERROR_NOTIFICATION_EVENT_INCORRECT;
            case 28:
                return ERROR_FROM_GREATER_THAN_TO;
            case 30:
                return ERROR_IM_SERVICE_UNAVAILABLE;
            case 32:
                return ERROR_LIMIT_PER_SECOND;
            case 33:
                return ERROR_LIMIT_PER_MINUTE;
            case 34:
                return ERROR_DIRECT_CANNOT_BE_PUBLIC_OR_UBER;
            case 35:
                return ERROR_NUMBER_OF_USERS_IN_DIRECT;
            case 36:
                return ERROR_SPECIFY_MAXIMUM_TWO_PARAMS;
            case 37:
                return ERROR_ADDING_TO_DIRECT;
            case 38:
                return ERROR_REMOVING_FROM_DIRECT;
            case 39:
                return ERROR_EDITING_PARTICIPANTS_IN_DIRECT;
            case 40:
                return ERROR_LEAVING_DIRECT_NOT_ALLOWED;
            case 41:
                return ERROR_SPECIFY_AT_LEAST_TWO_PARAMS;
            case 500:
                return VoximplantErrors.Messaging.ERROR_INTERNAL;
            case 10000:
                return ERROR_METHOD_CALL_DISCARDED;
            case 10001:
                return ERROR_INVALID_ARGUMENTS;
            case 10002:
                return ERROR_TIMEOUT;
            case 10003:
                return ERROR_CLIENT_NOT_LOGGED_IN;
            case 10004:
                return ERROR_FAILED_TO_PROCESS_RESPONSE;
            case 0:
            default:
                return ERROR_SOMETHING_WENT_WRONG;
        }
    }

    static VideoCodec convertStringToVideoCodec(String videoCodec) {
        switch (videoCodec) {
            case "VP8":
                return VideoCodec.VP8;
            case "H264":
                return VideoCodec.H264;
            case "AUTO":
            default:
                return VideoCodec.AUTO;
        }
    }

    static int convertVideoStreamTypeToInt(VideoStreamType type) {
        switch (type) {
            case SCREEN_SHARING:
                return 1;
            default:
            case VIDEO:
                return 0;
        }
    }

    static int convertVideoStreamReceiveStopReasonToInt(VideoStreamReceiveStopReason reason) {
        switch (reason) {
            case MANUAL:
                return 1;
            case AUTOMATIC:
            default:
                return 0;
        }
    }

    static AudioFileUsage convertStringToAudioFileUsage(String usage) {
        if (usage == null) {
            return AudioFileUsage.UNKNOWN;
        }
        switch (usage) {
            case "incall":
                return AudioFileUsage.IN_CALL;
            case "notification":
                return AudioFileUsage.NOTIFICATION;
            case "ringtone":
                return AudioFileUsage.RINGTONE;
            case "unknown":
            default:
                return AudioFileUsage.UNKNOWN;
        }
    }

    static Integer convertQualityIssueLevelToInt(QualityIssueLevel level) {
        switch (level) {
            case MINOR:
                return 1;
            case MAJOR:
                return 2;
            case CRITICAL:
                return 3;
            case NONE:
            default:
                return 0;
        }
    }

    static int convertQualityIssueToInt(QualityIssue issue) {
        switch (issue) {
            case CODEC_MISMATCH:
                return 0;
            case LOCAL_VIDEO_DEGRADATION:
                return 1;
            case HIGH_MEDIA_LATENCY:
                return 2;
            case NO_AUDIO_SIGNAL:
                return 4;
            case PACKET_LOSS:
                return 5;
            case NO_AUDIO_RECEIVE:
                return 6;
            case NO_VIDEO_RECEIVE:
                return 7;
            case ICE_DISCONNECTED:
            default:
                return 3;
        }
    }

    static Map<Integer, Integer> convertQualityIssuesMapToHashMap(Map<QualityIssue, QualityIssueLevel> issues) {
        Map<Integer, Integer> parsedIssues = new HashMap<>();
        for(Map.Entry<QualityIssue, QualityIssueLevel> pair : issues.entrySet()) {
            parsedIssues.put(convertQualityIssueToInt(pair.getKey()), convertQualityIssueLevelToInt(pair.getValue()));
        }
        return parsedIssues;
    }
}
