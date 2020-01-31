/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.hardware.AudioDevice;
import com.voximplant.sdk.hardware.IAudioDeviceEventsListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class AudioDeviceModule implements IAudioDeviceEventsListener, EventChannel.StreamHandler {
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private final PluginRegistry.Registrar mRegistrar;
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;

    AudioDeviceModule(PluginRegistry.Registrar registar) {
        mRegistrar = registar;
        mEventChannel = new EventChannel(registar.messenger(), "plugins.voximplant.com/audio_device_events");
        mEventChannel.setStreamHandler(this);
        Voximplant.getAudioDeviceManager().addAudioDeviceEventsListener(this);
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "selectAudioDevice":
                selectAudioDevice(call, result);
                break;
            case "getActiveDevice":
                getActiveDevice(call, result);
                break;
            case "getAudioDevices":
                getAudioDevices(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void selectAudioDevice(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,  "AudioDeviceManager.selectAudioDevice: Invalid arguments", null));
            return;
        }
        Integer audioDevice = call.argument("audioDevice");
        if (audioDevice == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,  "AudioDeviceManager.selectAudioDevice: audioDevice is null", null));
            return;
        }
        Voximplant.getAudioDeviceManager().selectAudioDevice(convertIntToAudioDevice(audioDevice));
        mHandler.post(() -> result.success(null));
    }

    private void getActiveDevice(MethodCall call,  MethodChannel.Result result) {
        AudioDevice device = Voximplant.getAudioDeviceManager().getActiveDevice();
        mHandler.post(() -> result.success(convertAudioDeviceToInt(device)));
    }

    private void getAudioDevices(MethodCall call,  MethodChannel.Result result) {
        List<AudioDevice> audioDevices = Voximplant.getAudioDeviceManager().getAudioDevices();
        List<Integer> audioDeviceList = new ArrayList<>();
        for (AudioDevice device : audioDevices) {
            audioDeviceList.add(convertAudioDeviceToInt(device));
        }
        mHandler.post(() -> result.success(audioDeviceList));
    }

    private AudioDevice convertIntToAudioDevice(int device) {
        switch (device) {
            case 0:
                return AudioDevice.BLUETOOTH;
            case 1:
                return AudioDevice.EARPIECE;
            case 2:
                return AudioDevice.SPEAKER;
            case 3:
                return AudioDevice.WIRED_HEADSET;
            case 4:
            default:
                return AudioDevice.NONE;
        }
    }

    private int convertAudioDeviceToInt(AudioDevice device) {
        switch (device) {
            case BLUETOOTH:
                return 0;
            case EARPIECE:
                return 1;
            case SPEAKER:
                return 2;
            case WIRED_HEADSET:
                return 3;
            case NONE:
            default:
                return 4;
        }
    }


    @Override
    public void onAudioDeviceChanged(AudioDevice audioDevice) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "audioDeviceChanged");
        event.put("audioDevice", convertAudioDeviceToInt(audioDevice));
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }

    @Override
    public void onAudioDeviceListChanged(List<AudioDevice> list) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "audioDeviceListChanged");
        List<Integer> audioDeviceList = new ArrayList<>();
        for (AudioDevice device : list) {
            audioDeviceList.add(convertAudioDeviceToInt(device));
        }
        event.put("audioDeviceList", audioDeviceList);
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        mEventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        mEventSink = null;
    }
}
