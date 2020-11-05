package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;

import com.voximplant.sdk.hardware.IAudioFile;
import com.voximplant.sdk.hardware.IAudioFileListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AudioFileModule implements EventChannel.StreamHandler, IAudioFileListener {
    final IAudioFile mAudioFile;
    private final String mFileId;
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private MethodChannel.Result mLoadFileCompletion;
    private MethodChannel.Result mPlayCompletion;
    private MethodChannel.Result mStopCompletion;
    private boolean mIsPlaying;

    AudioFileModule(BinaryMessenger messenger, IAudioFile file, String fileId, MethodChannel.Result loadFileCompletion) {
        mLoadFileCompletion = loadFileCompletion;
        mEventChannel = new EventChannel(messenger, "plugins.voximplant.com/audio_file_events_" + fileId);
        mEventChannel.setStreamHandler(this);
        mFileId = fileId;
        mAudioFile = file;
        mAudioFile.setAudioFileListener(this);
        mIsPlaying = false;
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "play":
                play(call, result);
                break;
            case "stop":
                stop(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    void play(MethodCall call, MethodChannel.Result result) {
        Object looped = call.argument("looped");
        if (looped instanceof Boolean) {
            if (mAudioFile != null) {
                mPlayCompletion = result;
                mAudioFile.play((Boolean)looped);
            }
        } else {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, call.method + ": looped is null", null));
        }
    }

    void stop(MethodChannel.Result result) {
        if (mAudioFile != null) {
            if (mIsPlaying) {
                mStopCompletion = result;
                mAudioFile.stop(false);
            } else {
                result.success(null);
            }
        }
    }

    @Override
    public void onStart(IAudioFile audioFile) {
        mIsPlaying = true;
        if (mPlayCompletion != null) {
            mHandler.post(() -> {
                mPlayCompletion.success(null);
                mPlayCompletion = null;
            });
        }
    }

    @Override
    public void onStop(IAudioFile audioFile) {
        mIsPlaying = false;
        if (mStopCompletion != null) {
            mHandler.post(() -> {
                mStopCompletion.success(null);
                mStopCompletion = null;
            });
        } else if (mFileId != null) {
            Map<String, Object> params = new HashMap<>();
            params.put("name", "didStopPlaying");
            sendEvent(params);
        }
    }

    @Override
    public void onPrepared(IAudioFile audioFile) {
        if (mLoadFileCompletion != null) {
            mHandler.post(() -> {
                mLoadFileCompletion.success(mFileId);
                mLoadFileCompletion = null;
            });
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        mEventSink = null;
    }

    private void sendEvent(Map<String, Object> event) {
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }
}
