/*
 * Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import com.voximplant.sdk.call.CallError;
import com.voximplant.sdk.client.LoginError;

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
            case INTERNAL_ERROR:
            default:
                return VoximplantErrors.ERROR_INTERNAL;
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
                return  VoximplantErrors.ERROR_TIMEOUT;
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
}
