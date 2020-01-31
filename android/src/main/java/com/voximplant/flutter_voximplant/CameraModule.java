/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.hardware.ICameraManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class CameraModule {
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private ICameraManager mCameraManager;

    private int mCameraResolutionWidth = 640;
    private int mCameraResolutionHeight = 480;
    private int mCameraIndex = 1;

    CameraModule(Context context) {
        mCameraManager = Voximplant.getCameraManager(context);
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "selectCamera":
                selectCamera(call, result);
                break;
            case "setCameraResolution":
                setCameraResolution(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void selectCamera(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,  "VICameraManager.selectCamera: Invalid arguments", null));
            return;
        }
        Integer cameraType = call.argument("cameraType");
        if (cameraType == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,  "VICameraManager.selectCamera: Invalid camera type", null));
            return;
        }
        mCameraIndex = cameraType;
        mCameraManager.setCamera(mCameraIndex, mCameraResolutionWidth, mCameraResolutionHeight);
        mHandler.post(() -> result.success(null));
    }

    private void setCameraResolution(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,  "VICameraManager.setCameraResolution: Invalid arguments", null));
            return;
        }
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        if (width == null || height == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,
                    "VICameraManager.selectCameraResolution: width or height is not specified", null));
            return;
        }
        mCameraResolutionWidth = width;
        mCameraResolutionHeight = height;
        mCameraManager.setCamera(mCameraIndex, mCameraResolutionWidth, mCameraResolutionHeight);
        mHandler.post(() -> result.success(null));
    }
}
