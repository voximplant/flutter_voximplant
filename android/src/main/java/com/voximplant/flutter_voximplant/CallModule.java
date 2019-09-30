/*
 * Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.voximplant.sdk.call.CallException;
import com.voximplant.sdk.call.CallSettings;
import com.voximplant.sdk.call.CallStats;
import com.voximplant.sdk.call.ICall;
import com.voximplant.sdk.call.ICallCompletionHandler;
import com.voximplant.sdk.call.ICallListener;
import com.voximplant.sdk.call.IEndpoint;
import com.voximplant.sdk.call.IEndpointListener;
import com.voximplant.sdk.call.IVideoStream;
import com.voximplant.sdk.call.RejectMode;
import com.voximplant.sdk.call.VideoFlags;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CallModule implements ICallListener, IEndpointListener, EventChannel.StreamHandler {
    private final String TAG_NAME = "VOXFLUTTER";
    private final VoximplantPlugin mPlugin;
    private final ICall mCall;
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;
    private Handler mHandler = new Handler(Looper.getMainLooper());

    CallModule(VoximplantPlugin plugin, ICall call) {
        mPlugin = plugin;
        mCall = call;
        mEventChannel = new EventChannel(mPlugin.registrar().messenger(), "plugins.voximplant.com/call_" + mCall.getCallId());
        mEventChannel.setStreamHandler(this);
    }

    void answerCall(MethodCall call, MethodChannel.Result result) {
        CallSettings callSettings = new CallSettings();
        callSettings.videoFlags = new VideoFlags(false, false);
        callSettings.customData = call.argument("customData");
        callSettings.extraHeaders = call.argument("extraHeaders");

        try {
            mCall.answer(callSettings);
            mHandler.post(() -> result.success(null));
        } catch (CallException e) {
            Log.e(TAG_NAME, "VoximplantPlugin: call: exception on call answer: " + e.getMessage());
            mHandler.post(() -> result.error(Utils.convertCallErrorToString(e.getErrorCode()),
                    Utils.getErrorDescriptionForCallError(e.getErrorCode()), null));
        }
    }

    void rejectCall(MethodCall call, MethodChannel.Result result) {
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

    void hangupCall(MethodCall call, MethodChannel.Result result) {
        Map<String, String> headers = call.argument("headers");
        mCall.hangup(headers);
        mHandler.post(() -> result.success(null));
    }

    void sendAudio(MethodCall call, MethodChannel.Result result) {
        Boolean value = call.argument("enable");
        if (value == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendAudio: Failed to get enable parameter", null));
            return;
        }
        mCall.sendAudio(value);
        mHandler.post(() -> result.success(null));
    }

    void sendMessage(MethodCall call, MethodChannel.Result result) {
        String message = call.argument("message");
        if (message == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendMessage: Failed to get message parameter", null));
            return;
        }
        mCall.sendMessage(message);
        mHandler.post(() -> result.success(null));
    }

    void sendInfo(MethodCall call, MethodChannel.Result result) {
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

    void sendTone(MethodCall call, MethodChannel.Result result) {
        String tone = call.argument("tone");
        if (tone == null) {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS,   "Call.sendTone: Failed to get tone parameter", null));
            return;
        }
        mCall.sendDTMF(tone);
        mHandler.post(() -> result.success(null));
    }

    void holdCall(MethodCall call, MethodChannel.Result result) {
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
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("plugins.voximplant.com/call_" + mCall.getCallId())) {
                mEventSink = null;
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
        mCall.removeCallListener(this);
        mPlugin.callHasEnded(call.getCallId());
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
        mCall.removeCallListener(this);
        mPlugin.callHasEnded(call.getCallId());
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
        event.put("content", content);
        event.put("headers", headers);
        sendCallEvent(event);
    }

    @Override
    public void onMessageReceived(ICall call, String text) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "messageReceived");
        event.put("text", text);
        sendCallEvent(event);
    }

    @Override
    public void onLocalVideoStreamAdded(ICall call, IVideoStream videoStream) {

    }

    @Override
    public void onLocalVideoStreamRemoved(ICall call, IVideoStream videoStream) {

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
        sendCallEvent(event);
    }

    @Override
    public void onCallStatsReceived(ICall call, CallStats callStats) {

    }

    @Override
    public void onRemoteVideoStreamAdded(IEndpoint endpoint, IVideoStream videoStream) {

    }

    @Override
    public void onRemoteVideoStreamRemoved(IEndpoint endpoint, IVideoStream videoStream) {

    }

    @Override
    public void onEndpointRemoved(IEndpoint endpoint) {

    }

    @Override
    public void onEndpointInfoUpdated(IEndpoint endpoint) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "endpointInfoUpdated");
        event.put("endpointId", endpoint.getEndpointId());
        event.put("endpointUserName", endpoint.getUserName());
        event.put("endpointDisplayName", endpoint.getUserDisplayName());
        event.put("endpointSipUri", endpoint.getSipUri());
        sendCallEvent(event);
    }


    private void sendCallEvent(Map<String, Object> event) {
        if (mEventSink != null) {
            mHandler.post(() -> mEventSink.success(event));
        }
    }


}
