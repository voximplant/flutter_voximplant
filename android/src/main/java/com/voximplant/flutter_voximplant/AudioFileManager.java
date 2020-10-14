package com.voximplant.flutter_voximplant;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.hardware.IAudioFile;
import com.voximplant.sdk.hardware.IAudioFileListener;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AudioFileManager {
    private final Map<String, AudioFileModule> mAudioFileModules;
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private final BinaryMessenger mMessenger;
    private final Context mAppContext;

    AudioFileManager(BinaryMessenger messenger, Context context) {
        this.mMessenger = messenger;
        this.mAudioFileModules = new HashMap<>();
        this.mAppContext = context;
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": Invalid arguments", null));
            return;
        }
        switch (call.method) {
            case "initWithFile":
                initWithFile(call, result);
                break;
            case "loadFile":
                loadFile(call, result);
                break;
            case "releaseResources":
                releaseResources(call, result);
                break;
            default:
                handleInModule(call, result);
                break;
        }
    }

    void initWithFile(MethodCall call, MethodChannel.Result result) {
        String fileName = call.argument("name");
        if (fileName == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": name is null", null));
            return;
        }
        String fileUsage = call.argument("usage");
        if (fileUsage == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": usage is null", null));
            return;
        }
        int rawId = mAppContext.getResources().getIdentifier(fileName, "raw", mAppContext.getPackageName());
        IAudioFile audioFile = Voximplant.createAudioFile(mAppContext, rawId, Utils.convertStringToAudioFileUsage(fileUsage));
        if (audioFile == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": failed to locate audio file", null));
            return;
        }
        String fileId = UUID.randomUUID().toString();
        AudioFileModule module = new AudioFileModule(mMessenger, audioFile, fileId, null);
        mAudioFileModules.put(fileId, module);
        mHandler.post(() -> result.success(fileId));
    }

    void loadFile(MethodCall call, MethodChannel.Result result) {
        String fileUrl = call.argument("url");
        if (fileUrl == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": url is null", null));
            return;
        }
        String fileUsage = call.argument("usage");
        if (fileUsage == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": usage is null", null));
            return;
        }
        IAudioFile audioFile = Voximplant.createAudioFile(fileUrl, Utils.convertStringToAudioFileUsage(fileUsage));
        if (audioFile == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": failed to load audio file", null));
            return;
        }
        String fileId = UUID.randomUUID().toString();
        AudioFileModule module = new AudioFileModule(mMessenger, audioFile, fileId, result);
        mAudioFileModules.put(fileId, module);
    }

    void releaseResources(MethodCall call, MethodChannel.Result result) {
        String fileId = call.argument("fileId");
        if (fileId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": fileId is null", null));
            return;
        }
        if (!mAudioFileModules.containsKey(fileId)) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": could'nt find audioFile", null));
            return;
        }
        AudioFileModule module = mAudioFileModules.get(fileId);
        if (module == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": could'nt find audioFile", null));
            return;
        }
        if (module.mAudioFile != null) {
            module.mAudioFile.setAudioFileListener(null);
            module.mAudioFile.release();
        }
        mAudioFileModules.remove(fileId);
        mHandler.post(() -> result.success(null));
    }

    void handleInModule(MethodCall call, MethodChannel.Result result) {
        String fileId = call.argument("fileId");
        if (fileId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": fileId is null", null));
            return;
        }
        if (!mAudioFileModules.containsKey(fileId)) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": could'nt find audioFile", null));
            return;
        }
        AudioFileModule module = mAudioFileModules.get(fileId);
        if (module == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": could'nt find audioFile", null));
            return;
        }
        module.handleMethodCall(call, result);
    }
}
