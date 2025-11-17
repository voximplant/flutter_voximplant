/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.content.Context;

import androidx.annotation.NonNull;

import com.voximplant.sdk.Voximplant;

import java.util.regex.Pattern;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;

public class VoximplantPlugin implements MethodCallHandler, FlutterPlugin {
    private MethodChannel mChannel;
    private AudioDeviceModule mAudioDeviceModule;
    private ClientModule mClientModule;
    private CallManager mCallManager;
    private CameraModule mCameraModule;
    private MessagingModule mMessagingModule;
    private AudioFileManager mAudioFileManager;
    private final LoggerModule mLoggerModule = LoggerModule.getInstance();

    public VoximplantPlugin() {
        Voximplant.subVersion = "flutter-3.16.1";
    }

    private void configure(Context context, TextureRegistry textures, BinaryMessenger messenger) {
        mChannel = new MethodChannel(messenger, "plugins.voximplant.com/client");
        mCallManager = new CallManager();
        mAudioDeviceModule = new AudioDeviceModule(messenger);
        mClientModule = new ClientModule(messenger, context, textures, mCallManager);
        mCameraModule = new CameraModule(context);
        mChannel.setMethodCallHandler(this);
        mMessagingModule = new MessagingModule(messenger);
        mAudioFileManager = new AudioFileManager(messenger, context);
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        mLoggerModule.logInfo("VoximplantPlugin attached to engine");
        configure(binding.getApplicationContext(),
                  binding.getTextureRegistry(),
                  binding.getBinaryMessenger()
        );
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mLoggerModule.logInfo("VoximplantPlugin detached from engine");
        if (mCallManager != null) {
            mCallManager.endAllCalls();
        }
        if (mChannel != null) {
            mChannel.setMethodCallHandler(null);
            mChannel = null;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        mLoggerModule.logInfo("VoximplantPlugin method called: " + call.method + ", with arguments: " + call.arguments);

        String MESSAGING = "Messaging";
        String CLIENT = "Client";
        String CALL = "Call";
        String AUDIO_DEVICE = "AudioDevice";
        String VIDEO_STREAM = "VideoStream";
        String CAMERA = "Camera";
        String AUDIO_FILE = "AudioFile";
        String LOGGER = "Logger";

        if (isMethodCallOfType(MESSAGING, call)) {
            mMessagingModule.handleMethodCall(excludeMethodType(call), result);

        } else if (isMethodCallOfType(CLIENT, call)) {
            mClientModule.handleMethodCall(excludeMethodType(call), result);

        } else if (isMethodCallOfType(CALL, call)) {
            MethodCall method = excludeMethodType(call);
            CallModule callModule = mCallManager.checkCallEvent(method, result, "Call." + method);
            if (callModule != null) {
                callModule.handleMethodCall(method, result);
            }

        } else if (isMethodCallOfType(VIDEO_STREAM, call)) {
            MethodCall method = excludeMethodType(call);
            CallModule callModule = mCallManager.findCallByStreamId(method, result, "Call." + method);
            if (callModule != null) {
                callModule.handleMethodCall(method, result);
            }

        } else if (isMethodCallOfType(AUDIO_DEVICE, call)) {
            mAudioDeviceModule.handleMethodCall(excludeMethodType(call), result);

        } else if (isMethodCallOfType(CAMERA, call)) {
            mCameraModule.handleMethodCall(excludeMethodType(call), result);

        } else if (isMethodCallOfType(AUDIO_FILE, call)) {
            mAudioFileManager.handleMethodCall(excludeMethodType(call), result);

        } else if (isMethodCallOfType(LOGGER, call)) {
            mLoggerModule.handleMethodCall(excludeMethodType(call), result);
        } else {
            result.notImplemented();
        }
    }

    private boolean isMethodCallOfType(String type, MethodCall call) {
        String separator = ".";
        String methodName = call.method;
        String[] methodNameComponents = methodName.split(Pattern.quote(separator));
        return  methodNameComponents.length > 0 && methodNameComponents[0].equals(type);
    }

    private MethodCall excludeMethodType(MethodCall call) {
        String[] methodNameComponents = call.method.split(Pattern.quote("."));
        return new MethodCall(methodNameComponents.length > 0 ? methodNameComponents[1] : call.method, call.arguments);
    }
}
