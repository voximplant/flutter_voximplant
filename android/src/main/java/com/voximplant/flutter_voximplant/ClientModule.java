/*
 * Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
 */

package com.voximplant.flutter_voximplant;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.voximplant.sdk.Voximplant;
import com.voximplant.sdk.call.CallError;
import com.voximplant.sdk.call.CallException;
import com.voximplant.sdk.call.CallSettings;
import com.voximplant.sdk.call.ICall;
import com.voximplant.sdk.call.IEndpoint;
import com.voximplant.sdk.call.VideoFlags;
import com.voximplant.sdk.client.AuthParams;
import com.voximplant.sdk.client.ClientConfig;
import com.voximplant.sdk.client.IClient;
import com.voximplant.sdk.client.IClientIncomingCallListener;
import com.voximplant.sdk.client.IClientLoginListener;
import com.voximplant.sdk.client.IClientSessionListener;
import com.voximplant.sdk.client.LoginError;
import com.voximplant.sdk.client.RequestAudioFocusMode;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_CONNECTION_FAILED;
import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INTERNAL;
import static com.voximplant.flutter_voximplant.VoximplantErrors.ERROR_INVALID_ARGUMENTS;

class ClientModule implements IClientSessionListener, IClientLoginListener, IClientIncomingCallListener, EventChannel.StreamHandler {
    final String TAG_NAME = "VOXFLUTTER";
    private IClient mClient;
    private CallManager mCallManager;

    private Handler mHandler = new Handler(Looper.getMainLooper());

    private EventChannel mIncomingCallEventChannel;
    private EventChannel.EventSink mIncomingCallEventSink;
    private EventChannel mConnectionEventChannel;
    private EventChannel.EventSink mConnectionEventSink;

    private HashMap<String, MethodChannel.Result> mClientMethodCallResults = new HashMap<>();

    private final Context mContext;
    private final BinaryMessenger mMessenger;
    private final TextureRegistry mTextures;

    ClientModule(BinaryMessenger messenger, Context context, TextureRegistry textures, CallManager callManager) {
        mCallManager = callManager;
        mMessenger = messenger;
        mContext = context;
        mTextures = textures;

        mIncomingCallEventChannel = new EventChannel(messenger, "plugins.voximplant.com/incoming_calls");
        mIncomingCallEventChannel.setStreamHandler(this);
        mConnectionEventChannel = new EventChannel(messenger, "plugins.voximplant.com/connection_events");
        mConnectionEventChannel.setStreamHandler(this);
    }

    void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "initClient":
                initClient(call);
                break;
            case "connect":
                connect(call, result);
                break;
            case "disconnect":
                disconnect(result);
                break;
            case "login":
                login(call, result);
                break;
            case "loginWithToken":
                loginWithToken(call, result);
                break;
            case "getClientState":
                if (mClient != null) {
                    switch (mClient.getClientState()) {
                        case DISCONNECTED:
                            result.success("Disconnected");
                        case CONNECTING:
                            result.success("Connecting");
                        case CONNECTED:
                            result.success("Connected");
                        case LOGGING_IN:
                            result.success("LoggingIn");
                        case LOGGED_IN:
                            result.success("LoggedIn");
                        case RECONNECTING:
                            result.success("Reconnecting");
                        default:
                            result.error(ERROR_INTERNAL, "Unknown state", null);
                    }
                } else {
                    result.error(ERROR_INTERNAL, "Client does not exist", null);
                }
                break;
            case "requestOneTimeKey":
                requestOneTimeKey(call, result);
                break;
            case "tokenRefresh":
                refreshToken(call, result);
                break;
            case "loginWithKey":
                loginWithKey(call, result);
                break;
            case "call":
                call(call, result);
                break;
            case "registerForPushNotifications":
                registerForPushNotifications(call, result);
                break;
            case "unregisterFromPushNotifications":
                unregisterFromPushNotifications(call, result);
                break;
            case "handlePushNotification":
                handlePushNotification(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    private void initClient(MethodCall call) {
        ClientConfig clientConfig = new ClientConfig();
        clientConfig.eglBase = SharedContext.getSharedEglBase();
        if (call.hasArgument("bundleId")) {
            clientConfig.packageName = call.argument("bundleId");
        }
        if (call.hasArgument("enableDebugLogging")) {
            Boolean value = call.argument("enableDebugLogging");
            if (value != null) {
                clientConfig.enableDebugLogging = value;
            }
        }
        if (call.hasArgument("enableLogcatLogging")) {
            Boolean value = call.argument("enableLogcatLogging");
            if (value != null) {
                clientConfig.enableLogcatLogging = value;
            }
        }
        if (call.hasArgument("audioFocusMode")) {
            Integer value = call.argument("audioFocusMode");
            if (value != null) {
                clientConfig.requestAudioFocusMode = (value == 0 ? RequestAudioFocusMode.REQUEST_ON_CALL_START : RequestAudioFocusMode.REQUEST_ON_CALL_CONNECTED);
            }
        }
        if (call.hasArgument("forceRelayTraffic")) {
            Boolean value = call.argument("forceRelayTraffic");
            clientConfig.forceRelayTraffic = value;
        }
        mClient = Voximplant.getClientInstance(Executors.newSingleThreadExecutor(), mContext, clientConfig);
        mClient.setClientSessionListener(this);
        mClient.setClientLoginListener(this);
        mClient.setClientIncomingCallListener(this);
    }

    private void connect(MethodCall call, MethodChannel.Result result) {
        if (call.arguments != null) {
            boolean connectivityCheck = false;
            if (call.hasArgument("connectivityCheck")) {
                Boolean value = call.argument("connectivityCheck");
                connectivityCheck = value != null ? value : false;
            }

            List<String> servers = null;
            if (call.hasArgument("servers")) {
                servers = call.argument("servers");
            }
            try {
                mClient.connect(connectivityCheck, servers);
            } catch (IllegalStateException e) {
                result.error(ERROR_CONNECTION_FAILED, "Invalid state", null);
                return;
            }
        } else {
            try {
                mClient.connect();
            } catch (IllegalStateException e) {
                result.error(ERROR_CONNECTION_FAILED, "Invalid state", null);
                return;
            }
        }

        mClientMethodCallResults.put(call.method, result);
    }

    private void disconnect(MethodChannel.Result result) {
        mClient.disconnect();
        mClientMethodCallResults.put("disconnect", result);
    }

    private void login(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        String password = call.argument("password");
        mClient.login(username, password);
        mClientMethodCallResults.put("login", result);
    }

    private void loginWithToken(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        String token = call.argument("token");
        mClient.loginWithAccessToken(username, token);
        mClientMethodCallResults.put("login", result);
    }

    private void loginWithKey(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        String hash = call.argument("hash");
        if (username == null || hash == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "Client.loginWithOneTimeKey: username and/or hash is null", null);
            return;
        }
        mClient.loginWithOneTimeKey(username, hash);
        mClientMethodCallResults.put("login", result);
    }

    private void requestOneTimeKey(MethodCall call, MethodChannel.Result result) {
        String username = (String) call.arguments;
        mClient.requestOneTimeKey(username);
        mClientMethodCallResults.put("requestOneTimeKey", result);
    }

    private void refreshToken(MethodCall call, MethodChannel.Result result) {
        String username = call.argument("username");
        String refreshToken = call.argument("refreshToken");
        if (username == null || refreshToken == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "Client.tokenRefresh: username and/or refreshToken is null", null);
            return;
        }
        mClient.refreshToken(username, refreshToken);
        mClientMethodCallResults.put("refreshToken", result);
    }

    private void call(MethodCall call, MethodChannel.Result result) {
        if (call.arguments != null) {
            String number = call.argument("number");
            if (number == null) {
                mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Client.call: Number parameter can not be null", null));
                return;
            }
            String customData = call.argument("customData");
            Map<String, String> headers = call.argument("extraHeaders");
            Boolean sendVideo = call.argument("sendVideo");
            Boolean receiveVideo = call.argument("receiveVideo");
            String videoCodec = call.argument("videoCodec");
            Boolean conference = call.argument("conference");
            if (conference == null) {
                conference = false;
            }
            CallSettings callSettings = new CallSettings();
            callSettings.customData = customData;
            callSettings.extraHeaders = headers;
            callSettings.videoFlags = new VideoFlags(receiveVideo != null ? receiveVideo : false,
                    sendVideo != null ? sendVideo : false);
            if (videoCodec != null) {
                callSettings.preferredVideoCodec = Utils.convertStringToVideoCodec(videoCodec);
            }
            ICall voxCall = conference
                    ? mClient.callConference(number, callSettings)
                    : mClient.call(number, callSettings);
            if (voxCall != null) {
                try {
                    voxCall.start();
                } catch (CallException e) {
                    Log.e(TAG_NAME, "VoximplantPlugin: call: exception on call start: " + e.getMessage());
                    if (e.getErrorCode() == CallError.INCORRECT_OPERATION) {
                        mHandler.post(() -> result.error(VoximplantErrors.ERROR_INCORRECT_OPERATION, "Client.call: Call is already started", null));
                    } else if (e.getErrorCode() == CallError.MISSING_PERMISSION) {
                        mHandler.post(() -> result.error(VoximplantErrors.ERROR_MISSING_PERMISSION, "Client.call: RECORD_AUDIO permission is missing", null));
                    } else {
                        mHandler.post(() -> result.error(ERROR_INTERNAL, "Client.call: Internal error occurred", e.getMessage()));
                    }
                    return;
                }

                CallModule callModule = new CallModule(mMessenger, mTextures, mCallManager, voxCall);
                mCallManager.addNewCall(voxCall.getCallId(), callModule);

                Map<String, Object> returnParams = new HashMap<>();
                returnParams.put("callId", voxCall.getCallId());
                mHandler.post(() -> result.success(returnParams));
            } else {
                mHandler.post(() -> result.error(VoximplantErrors.ERROR_CLIENT_NOT_LOGGED_IN, "Client.call: Client is not logged in", null));
            }
        } else {
            mHandler.post(() -> result.error(VoximplantErrors.ERROR_INVALID_ARGUMENTS, "Client.call: Invalid arguments", null));
        }
    }

    private void registerForPushNotifications(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Client.registerForPushNotifications: Invalid arguments", null));
            return;
        }
        String pushToken = (String) call.arguments;
        mClient.registerForPushNotifications(pushToken, null);
        mHandler.post(() -> result.success(null));
    }

    private void unregisterFromPushNotifications(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Client.unregisterFromPushNotifications: Invalid arguments", null));
            return;
        }
        String pushToken = (String) call.arguments;
        mClient.unregisterFromPushNotifications(pushToken, null);
        mHandler.post(() -> result.success(null));
    }

    @SuppressWarnings("unchecked")
    private void handlePushNotification(MethodCall call, MethodChannel.Result result) {
        if (call.arguments == null) {
            mHandler.post(() -> result.error(ERROR_INVALID_ARGUMENTS, "Client.handlePushNotification: Invalid arguments", null));
            return;
        }
        Map<String, String> payload = (Map<String, String>) call.arguments;
        mClient.handlePushNotification(payload);
        mHandler.post(() -> result.success(null));
    }

    //region IClientSessionListener
    @Override
    public void onConnectionEstablished() {
        Log.i(TAG_NAME, "VoximplantPlugin: onConnectionEstablished");
        final MethodChannel.Result result = mClientMethodCallResults.remove("connect");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onConnectionEstablished: result is null");
            return;
        }
        mHandler.post(() -> result.success(null));

    }

    @Override
    public void onConnectionFailed(String error) {
        Log.i(TAG_NAME, "VoximplantPlugin: onConnectionFailed");
        final MethodChannel.Result result = mClientMethodCallResults.remove("connect");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onConnectionFailed: result is null");
            return;
        }
        mHandler.post(() -> result.error(ERROR_CONNECTION_FAILED, error, null));

    }

    @Override
    public void onConnectionClosed() {
        Log.i(TAG_NAME, "VoximplantPlugin: onConnectionClosed");
        final MethodChannel.Result result = mClientMethodCallResults.remove("disconnect");
        if (result != null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onConnectionClosed: result is null");
            mHandler.post(() -> result.success(null));
        }
        if (mConnectionEventSink != null) {
            Map<String, String> params = new HashMap<>();
            params.put("event", "connectionClosed");
            mHandler.post(() -> mConnectionEventSink.success(params));
        }
    }

    @Override
    public void onLoginSuccessful(String displayName, AuthParams authParams) {
        Log.i(TAG_NAME, "VoximplantPlugin: onLoginSuccessful");
        final MethodChannel.Result result = mClientMethodCallResults.remove("login");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onLoginSuccessful: result is null");
            return;
        }
        Map<String, Object> returnParams = new HashMap<>();
        returnParams.put("displayName", displayName);
        returnParams.put("accessToken", authParams.getAccessToken());
        returnParams.put("accessExpire", authParams.getAccessTokenTimeExpired());
        returnParams.put("refreshToken", authParams.getRefreshToken());
        returnParams.put("refreshExpire", authParams.getRefreshTokenTimeExpired());
        mHandler.post(() -> result.success(returnParams));
    }

    @Override
    public void onLoginFailed(LoginError loginError) {
        Log.i(TAG_NAME, "VoximplantPlugin: onLoginFailed");
        final MethodChannel.Result result;
        if (mClientMethodCallResults.containsKey("login")) {
            result = mClientMethodCallResults.remove("login");
        } else if (mClientMethodCallResults.containsKey("requestOneTimeKey")) {
            result = mClientMethodCallResults.remove("requestOneTimeKey");
        } else {
            result = null;
        }

        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onLoginFailed: result is null");
            return;
        }
        mHandler.post(() -> result.error(Utils.convertLoginErrorToString(loginError),
                Utils.getErrorDescriptionForLoginError(loginError), null));

    }

    @Override
    public void onRefreshTokenFailed(LoginError loginError) {
        Log.i(TAG_NAME, "VoximplantPlugin: onRefreshTokenFailed");
        final MethodChannel.Result result = mClientMethodCallResults.remove("refreshToken");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onRefreshTokenFailed: result is null");
            return;
        }
        mHandler.post(() -> result.error(Utils.convertLoginErrorToString(loginError),
                Utils.getErrorDescriptionForLoginError(loginError), null));
    }

    @Override
    public void onRefreshTokenSuccess(AuthParams authParams) {
        Log.i(TAG_NAME, "VoximplantPlugin: onRefreshTokenSuccess");
        final MethodChannel.Result result = mClientMethodCallResults.remove("refreshToken");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onRefreshTokenSuccess: result is null");
            return;
        }
        Map<String, Object> returnParams = new HashMap<>();
        returnParams.put("accessToken", authParams.getAccessToken());
        returnParams.put("accessExpire", authParams.getAccessTokenTimeExpired());
        returnParams.put("refreshToken", authParams.getRefreshToken());
        returnParams.put("refreshExpire", authParams.getRefreshTokenTimeExpired());
        mHandler.post(() -> result.success(returnParams));
    }

    @Override
    public void onOneTimeKeyGenerated(String key) {
        Log.i(TAG_NAME, "VoximplantPlugin: onOneTimeKeyGenerated");
        final MethodChannel.Result result = mClientMethodCallResults.remove("requestOneTimeKey");
        if (result == null) {
            Log.e(TAG_NAME, "VoximplantPlugin: onOneTimeKeyGenerated: result is null");
            return;
        }
        mHandler.post(() -> result.success(key));

    }

    @Override
    public void onIncomingCall(ICall call, boolean video, Map<String, String> headers) {
        if (mIncomingCallEventSink != null) {
            CallModule callModule = new CallModule(mMessenger, mTextures, mCallManager, call);
            mCallManager.addNewCall(call.getCallId(), callModule);
            Map<String, Object> params = new HashMap<>();
            params.put("event", "incomingCall");
            params.put("callId", call.getCallId());
            params.put("video", video);
            params.put("headers", headers);
            IEndpoint endpoint = call.getEndpoints().get(0);
            if (endpoint != null) {
                params.put("endpointId", endpoint.getEndpointId());
                params.put("endpointUserName", endpoint.getUserName());
                params.put("endpointDisplayName", endpoint.getUserDisplayName());
                params.put("endpointSipUri", endpoint.getSipUri());
                params.put("endpointPlace", endpoint.getPlace());
            }
            mHandler.post(() -> mIncomingCallEventSink.success(params));
        }
    }

    @Override
    public void onReconnecting() {
        if (mConnectionEventSink != null) {
            Map<String, String> params = new HashMap<>();
            params.put("event", "reconnecting");
            mHandler.post(() -> mConnectionEventSink.success(params));
        }
    }

    @Override
    public void onReconnected() {
        if (mConnectionEventSink != null) {
            Map<String, String> params = new HashMap<>();
            params.put("event", "reconnected");
            mHandler.post(() -> mConnectionEventSink.success(params));
        }
    }

    //endregion

    @Override
    public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("connection_events")) {
                mConnectionEventSink = eventSink;
            }
            if (type.equals("incoming_calls")) {
                mIncomingCallEventSink = eventSink;
            }
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (arguments instanceof String) {
            String type = (String) arguments;
            if (type.equals("connection_events")) {
                mConnectionEventSink = null;
            }
            if (type.equals("incoming_calls")) {
                mIncomingCallEventSink = null;
            }
        }
    }
}
