/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.content.Context;

import com.voximplant.sdk.Voximplant;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

public class VoximplantPlugin implements MethodCallHandler, FlutterPlugin {
    final String TAG_NAME = "VOXFLUTTER";

    private MethodChannel mChannel;

    private AudioDeviceModule mAudioDeviceModule;
    private ClientModule mClientModule;
    private CallManager mCallManager;
    private CameraModule mCameraModule;

    public VoximplantPlugin() {
        Voximplant.subVersion = "flutter-2.2.0";
    }

    private void configure(Context context, TextureRegistry textures, BinaryMessenger messenger) {
        mChannel = new MethodChannel(messenger, "plugins.voximplant.com/client");
        mCallManager = new CallManager();
        mAudioDeviceModule = new AudioDeviceModule(messenger);
        mClientModule = new ClientModule(messenger, context, textures, mCallManager);
        mCameraModule = new CameraModule(context);
        mChannel.setMethodCallHandler(this);
    }

    public static void registerWith(Registrar registrar) {
        new VoximplantPlugin().configure(registrar.context(),
                                         registrar.textures(),
                                         registrar.messenger()
        );
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        configure(binding.getApplicationContext(),
                  binding.getTextureRegistry(),
                  binding.getBinaryMessenger()
        );
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        mChannel.setMethodCallHandler(null);
        mChannel = null;
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
                method.equals("receiveVideoForCall") ||
                method.equals("getCallDuration");
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
