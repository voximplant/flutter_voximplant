/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.Voximplant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class VoximplantPlugin implements MethodCallHandler {
    final String TAG_NAME = "VOXFLUTTER";

    private final Registrar mRegistrar;
    private final MethodChannel mChannel;

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private final AudioDeviceModule mAudioDeviceModule;
    private final ClientModule mClientModule;
    private final CallManager mCallManager;
    private final CameraModule mCameraModule;

    public VoximplantPlugin(Registrar registrar, MethodChannel channel) {
        mRegistrar = registrar;
        mChannel = channel;
        mCallManager = new CallManager();
        mAudioDeviceModule = new AudioDeviceModule(registrar);
        mClientModule = new ClientModule(registrar, mCallManager);
        mCameraModule = new CameraModule(registrar.context());

        Voximplant.subVersion = "flutter-2.0.0";
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.voximplant.com/client");
        channel.setMethodCallHandler(new VoximplantPlugin(registrar, channel));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (isClientMethod(call)) {
            mClientModule.handleMethodCall(call, result);
        } else if (isCallMethod(call)) {
            CallModule callModule = mCallManager.checkCallEvent(call, result, "Call." + call.method);
            if (callModule != null) {
                callModule.handleMethodCall(call, result);
            }
        } else if (isVideoStreamMethod(call)) {
            CallModule callModule = mCallManager.findCallByStreamId(call, result, "Call." + call.method);
            if (callModule != null) {
                callModule.handleMethodCall(call, result);
            }
        } else if (isAudioDeviceMethod(call)) {
            mAudioDeviceModule.handleMethodCall(call, result);
        } else if (isCameraMethod(call)) {
            mCameraModule.handleMethodCall(call, result);
        } else {
            result.notImplemented();
        }
    }

    private boolean isClientMethod(MethodCall call) {
        String method = call.method;
        if (method == null) {
            return false;
        }
        return method.equals("initClient") ||
                method.equals("connect") ||
                method.equals("disconnect") ||
                method.equals("login") ||
                method.equals("loginWithToken") ||
                method.equals("getClientState") ||
                method.equals("requestOneTimeKey") ||
                method.equals("tokenRefresh") ||
                method.equals("loginWithKey") ||
                method.equals("call") ||
                method.equals("registerForPushNotifications") ||
                method.equals("unregisterFromPushNotifications") ||
                method.equals("handlePushNotification");
    }

    private boolean isCallMethod(MethodCall call) {
        String method = call.method;
        if (method == null) {
            return false;
        }
        return method.equals("answerCall") ||
                method.equals("rejectCall") ||
                method.equals("hangupCall") ||
                method.equals("sendAudioForCall") ||
                method.equals("sendInfoForCall") ||
                method.equals("sendMessageForCall") ||
                method.equals("sendToneForCall") ||
                method.equals("holdCall") ||
                method.equals("sendVideoForCall") ||
                method.equals("receiveVideoForCall");
    }

    private boolean isVideoStreamMethod(MethodCall call) {
        String method = call.method;
        if (method == null) {
            return false;
        }
        return method.equals("addVideoRenderer") ||
                method.equals("removeVideoRenderer");
    }

    private boolean isAudioDeviceMethod(MethodCall call) {
        String method = call.method;
        if (method == null) {
            return false;
        }
        return call.method.equals("selectAudioDevice") ||
                call.method.equals("getActiveDevice") ||
                call.method.equals("getAudioDevices");
    }

    private boolean isCameraMethod(MethodCall call) {
        String method = call.method;
        if (method == null) {
            return false;
        }
        return call.method.equals("selectCamera") ||
                call.method.equals("setCameraResolution");
    }
}
