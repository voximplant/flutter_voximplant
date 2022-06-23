/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.voximplant.sdk.call.CallException;
import com.voximplant.sdk.call.CallSettings;
import com.voximplant.sdk.call.CallStats;
import com.voximplant.sdk.call.ICall;
import com.voximplant.sdk.call.ICallCompletionHandler;
import com.voximplant.sdk.call.ICallListener;
import com.voximplant.sdk.call.IEndpoint;
import com.voximplant.sdk.call.IEndpointListener;
import com.voximplant.sdk.call.ILocalVideoStream;
import com.voximplant.sdk.call.IQualityIssueListener;
import com.voximplant.sdk.call.IRemoteAudioStream;
import com.voximplant.sdk.call.IRemoteVideoStream;
import com.voximplant.sdk.call.QualityIssueLevel;
import com.voximplant.sdk.call.RejectMode;
import com.voximplant.sdk.call.RenderScaleType;
import com.voximplant.sdk.call.VideoFlags;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class CallModule implements ICallListener, IEndpointListener, EventChannel.StreamHandler, IQualityIssueListener {
    private final String TAG_NAME = "VOXFLUTTER";
    private final CallManager mCallManager;
    private final ICall mCall;
    private EventChannel mEventChannel;
    private EventChannel mQualityIssuesEventChannel;
    private EventChannel.EventSink mEventSink;
    private EventChannel.EventSink mIssuesEventSink;
    private Handler mHandler = new Handler(Looper.getMainLooper());
    private final BinaryMessenger mMessenger;
    private final TextureRegistry mTextures;

    private ILocalVideoStream mLocalVideoStream;
    private Map<String, IRemoteVideoStream> mRemoteVideoStreams = new HashMap<>();
    private Map<String, VoximplantRenderer> mRenderers = new HashMap<>();

    CallModule(BinaryMessenger messenger, TextureRegistry textures, CallManager callManager, ICall call) {
        mCallManager = callManager;
        mTextures = textures;
        mMessenger = messenger;
        mCall = call;
        mEventChannel = new EventChannel(messenger, "plugins.voximplant.com/call_" + mCall.getCallId());
        mQualityIssuesEventChannel = new EventChannel(messenger, "plugins.voximplant.com/call_quality_issues");
        mEventChannel.setStreamHandler(this);
        mQualityIssuesEventChannel.setStreamHandler(this);
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "answerCall":
                answerCall(call, result);
                break;
            case "rejectCall":
                rejectCall(call, result);
                break;
            case "hangupCall":
                hangupCall(call, result);
                break;
            case "sendAudioForCall":
                sendAudio(call, result);
                break;
            case "sendInfoForCall":
                sendInfo(call, result);
                break;
            case "sendMessageForCall":
                sendMessage(call, result);
                break;
            case "sendToneForCall":
                sendTone(call, result);
                break;
            case "holdCall":
                holdCall(call, result);
                break;
            case "addVideoRenderer":
                addVideoRenderer(call, result);
                break;
            case "removeVideoRenderer":
                removeVideoRenderer(call, result);
                break;
            case "sendVideoForCall":
                sendVideo(call, result);
                break;
            case "receiveVideoForCall":
                receiveVideo(call, result);
                break;
            case "getCallDuration":
                getCallDuration(call, result);
                break;
            case "startReceivingRemoteVideoStream":
                startReceiving(call, result);
                break;
            case "stopReceivingRemoteVideoStream":
                stopReceiving(call, result);
                break;
            case "requestVideoSizeRemoteVideoStream":
                requestVideoSize(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void answerCall(MethodCall call, MethodChannel.Result result) {
        String customData = call.argument("customData");
        Map<String, String> headers = call.argument("extraHeaders");
        Boolean sendVideo = call.argument("sendVideo");
        Boolean receiveVideo = call.argument("receiveVideo");
        String videoCodec = call.argument("videoCodec");

        CallSettings callSettings = new CallSettings();
        callSettings.customData = customData;
        callSettings.extraHeaders = headers;
        callSettings.videoFlags = new VideoFlags(receiveVideo != null ? receiveVideo : false,
                sendVideo != null ? sendVideo : false);
        if (videoCodec != null) {
            callSettings.preferredVideoCodec = Utils.convertStringToVideoCodec(videoCodec);
        }

        try {
            mCall.answer(callSettings);
            mHandler.post(() -> result.success(null));
        } catch (CallException e) {
            Log.e(TAG_NAME, "VoximplantPlugin: call: exception on call answer: " + e.getMessage());
            mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                    Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
        }
    }

    private void rejectCall(MethodCall call, MethodChannel.Result result) {
        RejectMode rejectMode = RejectMode.DECLINE;
        String rejectModeArg = call.argument("rejectMode");
        if (rejectModeArg != null && rejectModeArg.equals("reject")) {
            rejectMode = RejectMode.BUSY;
        }
        Map<String, String> headers = call.argument("headers");
        try {
            mCall.reject(rejectMode, headers);
            mHandler.post(() -> result.success(null));
        } catch (CallException e) {
            Log.e(TAG_NAME, "VoximplantPlugin: call: exception on call reject/decline: " + e.getMessage());
            mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                    Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
        }
    }

    private void hangupCall(MethodCall call, MethodChannel.Result result) {
        Map<String, String> headers = call.argument("headers");
        mCall.hangup(headers);
        mHandler.post(() -> result.success(null));
    }

    private void sendAudio(MethodCall call, MethodChannel.Result result) {
        Boolean value = call.argument("enable");
        if (value == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendAudio: Failed to get enable parameter", null));
            return;
        }
        mCall.sendAudio(value);
        mHandler.post(() -> result.success(null));
    }

    private void sendMessage(MethodCall call, MethodChannel.Result result) {
        String message = call.argument("message");
        if (message == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendMessage: Failed to get message parameter", null));
            return;
        }
        mCall.sendMessage(message);
        mHandler.post(() -> result.success(null));
    }

    private void sendInfo(MethodCall call, MethodChannel.Result result) {
        String mimeType = call.argument("mimetype");
        String body = call.argument("body");
        Map<String, String> headers = call.argument("headers");
        if (mimeType == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendInfo: Failed to get mimeType parameter", null));
            return;
        }
        if (body == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendInfo: Failed to get body parameter", null));
            return;
        }
        mCall.sendInfo(mimeType, body, headers);
        mHandler.post(() -> result.success(null));
    }

    private void sendTone(MethodCall call, MethodChannel.Result result) {
        String tone = call.argument("tone");
        if (tone == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendTone: Failed to get tone parameter", null));
            return;
        }
        mCall.sendDTMF(tone);
        mHandler.post(() -> result.success(null));
    }

    private void holdCall(MethodCall call, MethodChannel.Result result) {
        Boolean value = call.argument("enable");
        if (value == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.hold: Failed to get enable parameter", null));
            return;
        }
        mCall.hold(value, new ICallCompletionHandler() {
            @Override
            public void onComplete() {
                mHandler.post(() -> result.success(null));
            }

            @Override
            public void onFailure(CallException e) {
                mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                        Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
            }
        });
    }

    private void sendVideo(MethodCall call, MethodChannel.Result result) {
        Boolean value = call.argument("enable");
        if (value == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendVideo: Failed to get enable parameter", null));
            return;
        }
        mCall.sendVideo(value, new ICallCompletionHandler() {
            @Override
            public void onComplete() {
                mHandler.post(() -> result.success(null));
            }

            @Override
            public void onFailure(CallException e) {
                mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                        Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
            }
        });
    }

    private void receiveVideo(MethodCall call, MethodChannel.Result result) {
        mCall.receiveVideo(new ICallCompletionHandler() {
            @Override
            public void onComplete() {
                mHandler.post(() -> result.success(null));
            }

            @Override
            public void onFailure(CallException e) {
                mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                        Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
            }
        });
    }

    boolean hasVideoStreamId(String videoStreamId) {
        return (mLocalVideoStream != null && mLocalVideoStream.getVideoStreamId().equals(videoStreamId)) ||
                mRemoteVideoStreams.containsKey(videoStreamId);
    }

    private void addVideoRenderer(MethodCall call, MethodChannel.Result result) {
        String streamId = call.argument("streamId");
        if (streamId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, "Call.addVideoRenderer: Invalid streamId", null));
            return;
        }
        if (mLocalVideoStream != null && mLocalVideoStream.getVideoStreamId().equals(streamId)) {
            VoximplantRenderer renderer = new VoximplantRenderer(mMessenger, mTextures);
            mRenderers.put(streamId, renderer);
            mLocalVideoStream.addVideoRenderer(renderer.getRenderer(), RenderScaleType.SCALE_FIT);
            Map<String, Object> event = new HashMap<>();
            event.put("textureId", renderer.getTextureId());
            mHandler.post(() -> result.success(event));
            return;
        }
        if (mRemoteVideoStreams.containsKey(streamId)) {
            IRemoteVideoStream videoStream = mRemoteVideoStreams.get(streamId);
            if (videoStream != null) {
                VoximplantRenderer renderer = new VoximplantRenderer(mMessenger, mTextures);
                mRenderers.put(streamId, renderer);
                videoStream.addVideoRenderer(renderer.getRenderer(), RenderScaleType.SCALE_FIT);
                Map<String, Object> event = new HashMap<>();
                event.put("textureId", renderer.getTextureId());
                mHandler.post(() -> result.success(event));
                return;
            }
        }
        mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, "Call.addVideoRenderer: Failed to find video stream by id", null));
    }

    private void removeVideoRenderer(MethodCall call, MethodChannel.Result result) {
        String streamId = call.argument("streamId");
        if (streamId == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, "Call.removeVideoRenderer: Invalid streamId", null));
            return;
        }
        if (mLocalVideoStream != null && mLocalVideoStream.getVideoStreamId().equals(streamId)) {
            VoximplantRenderer renderer = mRenderers.remove(streamId);
            if (renderer != null) {
                mLocalVideoStream.removeVideoRenderer(renderer.getRenderer());
                renderer.release();
                mHandler.post(() -> result.success(null));
            }
            mLocalVideoStream = null;
        } else {
            for (Map.Entry<String, IRemoteVideoStream> entry : mRemoteVideoStreams.entrySet()) {
                if (entry.getKey().equals(streamId)) {
                    VoximplantRenderer renderer = mRenderers.remove(streamId);
                    if (renderer != null) {
                        entry.getValue().removeVideoRenderer(renderer.getRenderer());
                        renderer.release();
                        mHandler.post(() -> result.success(null));
                        break;
                    }
                }
            }
        }
    }

    private void getCallDuration(MethodCall call, MethodChannel.Result result) {
        result.success(mCall.getCallDuration());
    }

    private void cleanupResources() {
        if (mLocalVideoStream != null) {
            VoximplantRenderer renderer = mRenderers.remove(mLocalVideoStream.getVideoStreamId());
            if (renderer != null) {
                mLocalVideoStream.removeVideoRenderer(renderer.getRenderer());
                renderer.release();
            }
        }
        for (Map.Entry<String, IRemoteVideoStream> entry : mRemoteVideoStreams.entrySet()) {
            VoximplantRenderer renderer = mRenderers.remove(entry.getKey());
            if (renderer != null) {
                entry.getValue().removeVideoRenderer(renderer.getRenderer());
                renderer.release();
            }
        }
    }

    private void startReceiving(MethodCall call, MethodChannel.Result result) {
        String streamId = call.argument("streamId");
        IRemoteVideoStream videoStream = mRemoteVideoStreams.get(streamId);
        if (videoStream != null) {
            videoStream.startReceiving(new ICallCompletionHandler() {
                @Override
                public void onComplete() {
                    mHandler.post(() -> result.success(null));
                }

                @Override
                public void onFailure(CallException exception) {
                    mHandler.post(() -> result.error(exception.getErrorCode().toString(), exception.getMessage(), null));
                }
            });
        }
    }

    private void stopReceiving(MethodCall call, MethodChannel.Result result) {
        String streamId = call.argument("streamId");
        IRemoteVideoStream videoStream = mRemoteVideoStreams.get(streamId);
        if (videoStream != null) {
            videoStream.stopReceiving(new ICallCompletionHandler() {
                @Override
                public void onComplete() {
                    mHandler.post(() -> result.success(null));
                }

                @Override
                public void onFailure(CallException exception) {
                    mHandler.post(() -> result.error(exception.getErrorCode().toString(), exception.getMessage(), null));
                }
            });
        }
    }

    private void requestVideoSize(MethodCall call, MethodChannel.Result result) {
        String streamId = call.argument("streamId");
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        IRemoteVideoStream videoStream = mRemoteVideoStreams.get(streamId);
        if (videoStream != null) {
           videoStream.requestVideoSize(width, height);
            mHandler.post(() -> result.success(null));
        } else {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, "Failed to find remote video stream by provided video stream id", null));
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("plugins.voximplant.com/call_" + mCall.getCallId())) {
                mCall.addCallListener(this);
                mEventSink = eventSink;
            }
            for (IEndpoint endpoint : mCall.getEndpoints()) {
                endpoint.setEndpointListener(this);

            }
            if (type.equals("plugins.voximplant.com/call_quality_issues")) {
                mCall.setQualityIssueListener(this);
                mIssuesEventSink = eventSink;
            }
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("plugins.voximplant.com/call_" + mCall.getCallId())) {
                mEventSink = null;
            }
            if (type.equals("plugins.voximplant.com/call_quality_issues")) {
                mIssuesEventSink = null;
            }
        }
    }


    @Override
    public void onCallConnected(ICall call, Map<String, String> headers) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callConnected");
        event.put("headers", headers);
        sendCallEvent(event);
    }

    @Override
    public void onCallDisconnected(ICall call, Map<String, String> headers, boolean answeredElsewhere) {
        for (IEndpoint endpoint : mCall.getEndpoints()) {
            endpoint.setEndpointListener(null);
        }
        cleanupResources();
        mCall.removeCallListener(this);
        mLocalVideoStream = null;
        mCallManager.callHasEnded(call.getCallId());
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callDisconnected");
        event.put("headers", headers);
        event.put("answeredElsewhere", answeredElsewhere);
        sendCallEvent(event);
    }

    @Override
    public void onCallRinging(ICall call, Map<String, String> headers) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callRinging");
        event.put("headers", headers);
        sendCallEvent(event);
    }

    @Override
    public void onCallFailed(ICall call, int code, String description, Map<String, String> headers) {
        for (IEndpoint endpoint : mCall.getEndpoints()) {
            endpoint.setEndpointListener(null);
        }
        cleanupResources();
        mCall.removeCallListener(this);
        mLocalVideoStream = null;
        mCallManager.callHasEnded(call.getCallId());
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callFailed");
        event.put("code", code);
        event.put("description", description);
        event.put("headers", headers);
        sendCallEvent(event);
    }

    @Override
    public void onCallAudioStarted(ICall call) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callAudioStarted");
        sendCallEvent(event);
    }

    @Override
    public void onSIPInfoReceived(ICall call, String type, String content, Map<String, String> headers) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "sipInfoReceived");
        event.put("type", type);
        event.put("body", content);
        event.put("headers", headers);
        sendCallEvent(event);
    }

    @Override
    public void onMessageReceived(ICall call, String text) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "messageReceived");
        event.put("message", text);
        sendCallEvent(event);
    }

    @Override
    public void onLocalVideoStreamAdded(ICall call, ILocalVideoStream videoStream) {
        if (mLocalVideoStream == null) {
            mLocalVideoStream = videoStream;
            Map<String, Object> event = new HashMap<>();
            event.put("event", "localVideoStreamAdded");
            event.put("videoStreamId", videoStream.getVideoStreamId());
            event.put("videoStreamType", Utils.convertVideoStreamTypeToInt(videoStream.getVideoStreamType()));
            sendCallEvent(event);
        } else {
            Log.w(TAG_NAME, "VoximplantPlugin: call: onLocalVideoStreamAdded: local video " +
                    "stream has been already reported");
        }
    }

    @Override
    public void onLocalVideoStreamRemoved(ICall call, ILocalVideoStream videoStream) {
        if (mLocalVideoStream.getVideoStreamId().equals(videoStream.getVideoStreamId())) {
            Map<String, Object> event = new HashMap<>();
            event.put("event", "localVideoStreamRemoved");
            event.put("videoStreamId", videoStream.getVideoStreamId());
            sendCallEvent(event);
        } else {
            Log.w(TAG_NAME, "VoximplantPlugin: call: onLocalVideoStreamRemoved: video stream id " +
                    "does not match to previously added video stream");
        }
    }

    @Override
    public void onICETimeout(ICall call) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "iceTimeout");
        sendCallEvent(event);
    }

    @Override
    public void onICECompleted(ICall call) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "iceCompleted");
        sendCallEvent(event);
    }

    @Override
    public void onEndpointAdded(ICall call, IEndpoint endpoint) {
        if (mEventSink != null) {
            endpoint.setEndpointListener(this);
        }
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointAdded");
        event.put("endpointId", endpoint.getEndpointId());
        event.put("endpointUserName", endpoint.getUserName());
        event.put("endpointDisplayName", endpoint.getUserDisplayName());
        event.put("endpointSipUri", endpoint.getSipUri());
        event.put("endpointPlace", endpoint.getPlace());
        sendCallEvent(event);
    }

    @Override
    public void onCallStatsReceived(ICall call, CallStats callStats) {

    }

    @Override
    public void onCallReconnecting(ICall call) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callReconnecting");
        sendCallEvent(event);
    }

    @Override
    public void onCallReconnected(ICall call) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "callReconnected");
        sendCallEvent(event);
    }

    @Override
    public void onRemoteVideoStreamAdded(IEndpoint endpoint, IRemoteVideoStream videoStream) {
        mRemoteVideoStreams.put(videoStream.getVideoStreamId(), videoStream);
        Map<String, Object> event = new HashMap<>();
        event.put("event", "remoteVideoStreamAdded");
        event.put("endpointId", endpoint.getEndpointId());
        event.put("videoStreamId", videoStream.getVideoStreamId());
        event.put("videoStreamType", Utils.convertVideoStreamTypeToInt(videoStream.getVideoStreamType()));
        sendCallEvent(event);
    }

    @Override
    public void onRemoteVideoStreamRemoved(IEndpoint endpoint, IRemoteVideoStream videoStream) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "remoteVideoStreamRemoved");
        event.put("endpointId", endpoint.getEndpointId());
        event.put("videoStreamId", videoStream.getVideoStreamId());
        sendCallEvent(event);
    }

    @Override
    public void onEndpointRemoved(IEndpoint endpoint) {
        endpoint.setEndpointListener(null);
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointRemoved");
        event.put("endpointId", endpoint.getEndpointId());
        sendCallEvent(event);
    }

    @Override
    public void onEndpointInfoUpdated(IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointInfoUpdated");
        event.put("endpointId", endpoint.getEndpointId());
        event.put("endpointUserName", endpoint.getUserName());
        event.put("endpointDisplayName", endpoint.getUserDisplayName());
        event.put("endpointSipUri", endpoint.getSipUri());
        event.put("endpointPlace", endpoint.getPlace());
        sendCallEvent(event);
    }

    @Override
    public void onVoiceActivityStarted(IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointVoiceActivityStarted");
        event.put("endpointId", endpoint.getEndpointId());
        sendCallEvent(event);
    }

    @Override
    public void onVoiceActivityStopped(IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointVoiceActivityStopped");
        event.put("endpointId", endpoint.getEndpointId());
        sendCallEvent(event);
    }

    @Override
    public void onPacketLoss(@NonNull ICall call, @NonNull QualityIssueLevel level, double packetLoss) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypePacketLoss");
        event.put("packetLoss", packetLoss);
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onCodecMismatch(@NonNull ICall call, @NonNull QualityIssueLevel level, @Nullable String sendCodec) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeCodecMismatch");
        event.put("codec", sendCodec);
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onLocalVideoDegradation(@NonNull ICall call, @NonNull QualityIssueLevel level, int targetWidth, int targetHeight, int actualWidth, int actualHeight) {
        Map<String, Object> event = new HashMap<>();

        Map<String, Object> actualSizeStruct = new HashMap<>();
        actualSizeStruct.put("width", actualWidth);
        actualSizeStruct.put("height", actualHeight);

        Map<String, Object> targetSizeStruct = new HashMap<>();
        actualSizeStruct.put("width", targetWidth);
        actualSizeStruct.put("height", targetHeight);

        event.put("event", "VIQualityIssueTypeLocalVideoDegradation");
        event.put("actualSizeStruct", actualSizeStruct);
        event.put("targetSizeStruct", targetSizeStruct);
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onIceDisconnected(@NonNull ICall call, @NonNull QualityIssueLevel level) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeIceDisconnected");
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onHighMediaLatency(@NonNull ICall call, @NonNull QualityIssueLevel level, double latency) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeHighMediaLatency");
        event.put("latency", latency);
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onNoAudioSignal(@NonNull ICall call, @NonNull QualityIssueLevel level) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeNoAudioSignal");
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onNoAudioReceive(@NonNull ICall call, @NonNull QualityIssueLevel level, @NonNull IRemoteAudioStream audioStream, @NonNull IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeNoAudioReceive");
        event.put("audiostreamId", audioStream.getAudioStreamId());
        event.put("endpointId", endpoint.getEndpointId());
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    @Override
    public void onNoVideoReceive(@NonNull ICall call, @NonNull QualityIssueLevel level, @NonNull IRemoteVideoStream videoStream, @NonNull IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "VIQualityIssueTypeNoVideoReceive");
        event.put("videostreamId", videoStream.getVideoStreamId());
        event.put("endpointId", endpoint.getEndpointId());
        event.put("issueLevel", Utils.convertQualityIssueLevelToInt(level));
        sendQualityIssueEvent(event);
    }

    private void sendCallEvent(Map<String, Object> event) {
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }

    private void sendQualityIssueEvent(Map<String, Object> event) {
        if (mIssuesEventSink != null) {
            mHandler.post(() -> mIssuesEventSink.success(event));
        }
    }

}
