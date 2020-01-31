/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class CallManager {
    private final Map<String, CallModule> mCallModules;
    private Handler mHandler = new Handler(Looper.getMainLooper());

    CallManager() {
        mCallModules = new HashMap<>();
    }

    CallModule checkCallEvent(MethodCall call, MethodChannel.Result result, String methodName) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Invalid arguments", null));
            return null;
        }
        String callId = call.argument("callId");
        if (callId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Invalid callId", null));
            return null;
        }
        CallModule callModule  = mCallModules.get(callId);
        if (callModule == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Failed to find call for callId: " + callId, null));
        }
        return callModule;

    }

    CallModule findCallByStreamId(MethodCall call, MethodChannel.Result result, String methodName) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Invalid arguments", null));
            return null;
        }
        String streamId = call.argument("streamId");
        if (streamId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Invalid streamId", null));
            return null;
        }
        CallModule targetCallModule = null;
        for (Map.Entry<String, CallModule> entry : mCallModules.entrySet()) {
            if (entry.getValue().hasVideoStreamId(streamId)) {
                targetCallModule = entry.getValue();
                break;
            }
        }
        if (targetCallModule == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, methodName + ": Failed to find call for streamId: " + streamId, null));
        }
        return targetCallModule;

    }

    void callHasEnded(String callId) {
        mCallModules.remove(callId);
    }

    void addNewCall(String callId, CallModule callModule) {
        mCallModules.put(callId, callModule);
    }
}
