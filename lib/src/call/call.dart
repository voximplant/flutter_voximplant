/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Represents supported video codecs.
enum VIVideoCodec {
  AUTO,
  H264,
  VP8
}

/// Specifies video direction for a call.
class VIVideoFlags {
  bool sendVideo;
  bool receiveVideo;

  VIVideoFlags({bool receiveVideo = false, bool sendVideo = false}) {
    this.sendVideo = receiveVideo;
    this.receiveVideo = sendVideo;
  }
}

/// Call settings with additional parameters for a call, such as preferred video
/// codec, custom data, video directions and extra headers.
class VICallSettings {
  /// Specifies video direction for a call.
  ///
  /// Video is disabled by default.
  VIVideoFlags videoFlags = VIVideoFlags();

  /// Preferred video codec for a call.
  ///
  /// [VIVideoCodec.AUTO] by default.
  VIVideoCodec preferredVideoCodec = VIVideoCodec.AUTO;

  /// Custom string associated with the call session.
  ///
  /// It can be passed to the Voximplant Cloud to be obtained from
  /// the [CallAlerting](https://voximplant.com/docs/references/voxengine/appevents#callalerting)
  /// event or Call History using HTTP API.
  ///
  /// Maximum size is 200 bytes.
  ///
  /// Use [VICall.sendMessage] to pass a string over the limit; in order to pass
  /// a large data use
  /// [media_session_access_url](https://voximplant.com/docs/references/httpapi/managing_scenarios#startscenarios)
  /// on your backend.
  String customData;

  /// Optional set of headers to be sent to the Voximplant cloud.
  ///
  /// Names must begin with "X-" to be processed by SDK.
  Map<String, String> extraHeaders;
}

/// Signature for callbacks reporting that the call is connected.
///
/// Used in [VICall].
typedef void VICallConnected(VICall call, Map<String, String> headers);

/// Signature for callbacks reporting that the call is disconnected.
///
/// Check if the call was answered on another device with [answeredElsewhere].
///
/// Used in [VICall].
typedef void VICallDisconnected(VICall call,
    Map<String, String> headers, bool answeredElsewhere);

/// Signature for callbacks reporting when progress signal is received
/// from the endpoint.
///
/// Used in [VICall].
typedef void VICallRinging(VICall call, Map<String, String> headers);

/// Signature for callbacks reporting that the call was failed.
///
/// Failure reason is described by [code] and [description].
///
/// Used in [VICall].
typedef void VICallFailed(VICall call,
    int code, String description, Map<String, String> headers);

/// Signature for callbacks reporting that the endpoint answered the call.
///
/// Used in [VICall].
typedef void VICallAudioStarted(VICall call);

/// Signature for callbacks reporting that INFO message is received.
///
/// Used in [VICall].
typedef void VISIPInfoReceived(VICall call,
    String type, String content, Map<String, String> headers);

/// Signature for callbacks reporting that [message] is received within the call.
///
/// Implemented atop SIP INFO for communication between call endpoint and the
/// Voximplant Cloud, and is separated from Voximplant messaging API.
///
/// Used in [VICall].
typedef void VIMessageReceived(VICall call, String message);

/// Signature for callbacks reporting that the connection was not established
/// due to a network connection problem between 2 peers.
///
/// Used in [VICall].
typedef void VIICETimeout(VICall call);

/// Signature for callbacks reporting that ICE connection is complete.
///
/// Used in [VICall].
typedef void VIICECompleted(VICall call);

/// Signature for callbacks reporting that new endpoint is added to the call.
///
/// Used in [VICall].
typedef void VIEndpointAdded(VICall call, VIEndpoint endpoint);

/// Signature for callbacks reporting that local video is added to the call.
///
/// Used in [VICall].
typedef void VILocalVideoStreamAdded(VICall call, VIVideoStream videoStream);

/// Signature for callbacks reporting that local video is removed from the call.
///
/// Used in [VICall].
typedef void VILocalVideoStreamRemoved(VICall call, VIVideoStream videoStream);

/// Represents a call.
class VICall {
  /// Callback for getting notified when the call is connected.
  VICallConnected onCallConnected;
  /// Callback for getting notified when the call is disconnected.
  VICallDisconnected onCallDisconnected;
  /// Callback for getting notified when progress signal is received
  /// from the endpoint.
  VICallRinging onCallRinging;
  /// Callback for getting notified when the call is failed.
  VICallFailed onCallFailed;
  /// Callback for getting notified when the endpoint answered the call.
  VICallAudioStarted onCallAudioStarted;
  /// Callback for getting notified when INFO message in received.
  VISIPInfoReceived onSIPInfoReceived;
  /// Callback for getting notified when message is received.
  VIMessageReceived onMessageReceived;
  /// Callback for getting notified about failure to connect peers.
  VIICETimeout onICETimeout;
  /// Callback for getting notified when ICE connection is completed.
  VIICECompleted onICECompleted;
  /// Callback for getting notified when new endpoint is added to the call.
  VIEndpointAdded onEndpointAdded;
  /// Callback for getting notified when local video is added to the call.
  VILocalVideoStreamAdded onLocalVideoStreamAdded;
  /// Callback for getting notified when local video is removed from the call.
  VILocalVideoStreamRemoved onLocalVideoStreamRemoved;

  String _callId;
  String _callKitUUID;
  MethodChannel _channel;
  StreamSubscription<dynamic> _eventSubscription;
  List<VIEndpoint> _endpoints;

  VIVideoStream _localVideoStream;

  VICall._(this._callId, this._channel) {
    _endpoints = List();
    _eventSubscription = EventChannel('plugins.voximplant.com/call_$_callId')
        .receiveBroadcastStream('plugins.voximplant.com/call_$_callId')
        .listen(_eventListener);
  }

  VICall._withEndpoint(this._callId, this._channel, VIEndpoint endpoint) {
    _endpoints = List();
    _endpoints.add(endpoint);
    _eventSubscription = EventChannel('plugins.voximplant.com/call_$_callId')
        .receiveBroadcastStream('plugins.voximplant.com/call_$_callId')
        .listen(_eventListener);
  }

  /// The call id.
  String get callId => _callId;
  /// The CallKit UUID that may be used to match an incoming call with a push
  /// notification received before.
  ///
  /// Implemented for iOS only.
  ///
  /// Always null for outgoing call on [VICall] instance creation.
  ///
  /// For outgoing calls it is recommended to set CXStartCallAction.callUUID
  /// value to this property on handling CXStartCallAction.
  String get callKitUUID => _callKitUUID;
  set callKitUUID(String uuid) {
    _callKitUUID = uuid.toUpperCase();
    if (Platform.isIOS) {
      _channel.invokeMethod<void>('setCallKitUUID',
          <String, dynamic>{'callId': _callId, 'uuid': _callKitUUID});
    }
  }

  /// The endpoints associated with the call.
  List<VIEndpoint> get endpoints => _endpoints;
  /// The active local video stream.
  VIVideoStream get localVideoStream => _localVideoStream;

  /// Answers the incoming call.
  ///
  /// Additional call parameters are set up via [callSettings]: video direction
  /// for the call, preferred video codec, custom data.
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_MISSING_PERMISSION] - Android only. If permissions
  ///   are not granted for the call:
  ///   audio calls - RECORD_AUDIO
  ///   video calls - RECORD_AUDIO and CAMERA
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - Android only. If the call is
  ///   already answered.
  Future<void> answer([VICallSettings callSettings]) async {
    try {
      await _channel.invokeMethod<void>('answerCall', <String, dynamic>{
        'callId': _callId,
        'sendVideo': callSettings?.videoFlags?.sendVideo ?? false,
        'receiveVideo': callSettings?.videoFlags?.receiveVideo ?? false,
        'videoCodec': callSettings?.preferredVideoCodec.toString() ??
            VIVideoCodec.AUTO.toString(),
        'customData': callSettings?.customData,
        'extraHeaders': callSettings?.extraHeaders
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Declines the incoming call.
  ///
  /// Should be used only for incoming calls.
  ///
  /// Indicates that the user can't answer the call right now, and VoxEngine
  /// will terminate the call and any pending calls to other devices of
  /// the current user.
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - Android only. If the call is
  ///   already answered or ended.
  Future<void> decline([Map<String, String> headers]) async {
    try {
      await _channel.invokeMethod<void>('rejectCall', <String, dynamic>{
        'callId': _callId,
        'headers': headers,
        'rejectMode': 'decline'
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Rejects the incoming call.
  ///
  /// Should be used only for incoming calls.
  ///
  /// Indicates that the user is not available only at a particular device.
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - Android only. If the call is
  ///   already answered or ended.
  Future<void> reject([Map<String, String> headers]) async {
    try {
      await _channel.invokeMethod<void>('rejectCall', <String, dynamic>{
        'callId': _callId,
        'headers': headers,
        'rejectMode': 'reject'
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Disconnects the call.
  Future<void> hangup([Map<String, String> headers]) async {
    try {
      await _channel.invokeMethod<void>(
          'hangupCall',
          <String, dynamic>{'callId': _callId, 'headers': headers});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Puts the call on/off hold.
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_REJECTED] - If the operation is rejected.
  /// * [VICallError.ERROR_ALREADY_IN_THIS_STATE] - If the call is already in
  ///   the requested state.
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - If the call is not connected.
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VICallError.ERROR_TIMEOUT] - If the operation is not completed in time.
  Future<void> hold(bool enable) async {
    try {
      await _channel.invokeMethod<void>(
          'holdCall', <String, dynamic>{'callId': _callId, 'enable': enable});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Enables or disables audio transfer from microphone into the call.
  Future<void> sendAudio(bool enable) async {
    try {
      await _channel.invokeMethod<void>('sendAudioForCall',
          <String, dynamic>{'callId': _callId, 'enable': enable});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Send INFO message within the call.
  ///
  /// INFO message will be sent, if the call is establishing or established.
  Future<void> sendInfo(
      String mimeType, String body, Map<String, String> headers) async {
    try {
      await _channel.invokeMethod<void>('sendInfoForCall', <String, dynamic>{
        'callId': _callId,
        'mimetype': mimeType,
        'body': body,
        'headers': headers
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends [message] within the call.
  ///
  /// Implemented atop SIP INFO for communication between call endpoint and the
  /// Voximplant Cloud, and is separated from Voximplant messaging API.
  Future<void> sendMessage(String message) async {
    try {
      await _channel.invokeMethod<void>('sendMessageForCall',
          <String, dynamic>{'callId': _callId, 'message': message});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends DTMFs in the call.
  ///
  /// DTMFs will be sent only if the call is connected.
  Future<void> sendTone(String key) async {
    try {
      await _channel.invokeMethod<void>(
          'sendToneForCall', <String, String>{'callId': _callId, 'tone': key});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Starts or stops sending video for the call.
  ///
  /// Fot the non-conference video call it stops or starts video send (video
  /// stream is removed or added).
  ///
  /// For the conference call it mutes or un-mutes video send (video stream in
  /// the 'muted' state will still consume a small bandwidth).
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_REJECTED] - If the operation is rejected.
  /// * [VICallError.ERROR_ALREADY_IN_THIS_STATE] - If the call is already in
  ///   the requested state.
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - If the call is not connected.
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VICallError.ERROR_TIMEOUT] - If the operation is not completed in time.
  /// * [VICallError.ERROR_MISSING_PERMISSION] - Android only. If CAMERA
  ///   permission is not granted.
  /// * [VICallError.ERROR_MEDIA_IS_ON_HOLD] - If the call is currently on hold.
  ///   Put the call off hold and repeat the operation.
  Future<void> sendVideo(bool enable) async {
    try {
      await _channel.invokeMethod('sendVideoForCall', <String, dynamic>{
        'callId': _callId,
        'enable': enable,
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Starts to receive video if video receive was disabled before.
  ///
  /// Stop receiving video during the call is not supported.
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_REJECTED] - If the operation is rejected.
  /// * [VICallError.ERROR_ALREADY_IN_THIS_STATE] - If the call is already in
  ///   the requested state.
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - If the call is not connected.
  /// * [VICallError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VICallError.ERROR_TIMEOUT] - If the operation is not completed in time.
  /// * [VICallError.ERROR_MISSING_PERMISSION] - Android only. If CAMERA
  ///   permission is not granted.
  /// * [VICallError.ERROR_MEDIA_IS_ON_HOLD] - If the call is currently on hold.
  ///   Put the call off hold and repeat the operation.
  Future<void> receiveVideo() async {
    try {
      await _channel.invokeMethod('receiveVideoForCall', <String, String>{
        'callId': callId,
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }


  /// Returns the call duration in milliseconds.
  Future<int> getCallDuration() async {
    try {
      return await _channel.invokeMethod('getCallDuration', <String, String>{
        'callId': callId,
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'callConnected':
        Map<String, String> headers = new Map();
        map['headers'].forEach(
            (key, value) => {headers[key as String] = value as String});
        if (onCallConnected != null) {
          onCallConnected(this, headers);
        }
        break;
      case 'callDisconnected':
        _eventSubscription.cancel();
        Map<String, String> headers = new Map();
        map['headers'].forEach(
            (key, value) => {headers[key as String] = value as String});
        bool answeredElsewhere = map['answeredElsewhere'];
        if (onCallDisconnected != null) {
          onCallDisconnected(this, headers, answeredElsewhere);
        }
        break;
      case 'callRinging':
        Map<String, String> headers = new Map();
        map['headers'].forEach(
            (key, value) => {headers[key as String] = value as String});
        if (onCallRinging != null) {
          onCallRinging(this, headers);
        }
        break;
      case 'callFailed':
        _eventSubscription.cancel();
        int code = map['code'];
        String description = map['description'];
        Map<String, String> headers = new Map();
        map['headers'].forEach(
            (key, value) => {headers[key as String] = value as String});
        if (onCallFailed != null) {
          onCallFailed(this, code, description, headers);
        }
        break;
      case 'callAudioStarted':
        if (onCallAudioStarted != null) {
          onCallAudioStarted(this);
        }
        break;
      case 'sipInfoReceived':
        String type = map['type'];
        String content = map['content'];
        Map<String, String> headers = new Map();
        map['headers'].forEach(
            (key, value) => {headers[key as String] = value as String});
        if (onSIPInfoReceived != null) {
          onSIPInfoReceived(this, type, content, headers);
        }
        break;
      case 'messageReceived':
        String message = map['message'];
        if (onMessageReceived != null) {
          onMessageReceived(this, message);
        }
        break;
      case 'iceTimeout':
        if (onICETimeout != null) {
          onICETimeout(this);
        }
        break;
      case 'iceCompleted':
        if (onICECompleted != null) {
          onICECompleted(this);
        }
        break;
      case 'endpointAdded':
        String endpointId = map['endpointId'];
        VIEndpoint endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint == null) {
          String userName = map['userName'];
          String displayName = map['displayName'];
          String sipUri = map['sipUri'];
          endpoint = VIEndpoint._(endpointId, userName, displayName, sipUri);
          _endpoints.add(endpoint);
        }
        if (onEndpointAdded != null) {
          onEndpointAdded(this, endpoint);
        }
        break;
      case 'endpointInfoUpdated':
        String endpointId = map['endpointId'];
        VIEndpoint endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint != null) {
          String userName = map['endpointUserName'];
          String displayName = map['endpointDisplayName'];
          String sipUri = map['endpointSipUri'];
          endpoint._invokeEndpointUpdatedEvent(userName, displayName, sipUri);
        }
        break;
      case 'localVideoStreamAdded':
        String videoStreamId = map['videoStreamId'];
        int type = map['videoStreamType'];
        VIVideoStreamType videoStreamType = VIVideoStreamType.values[type];
        _localVideoStream = VIVideoStream._(videoStreamId, videoStreamType);
        if (onLocalVideoStreamAdded != null) {
          onLocalVideoStreamAdded(this, _localVideoStream);
        }
        break;
      case 'localVideoStreamRemoved':
        String videoStreamId = map['videoStreamId'];
        if (_localVideoStream.streamId == videoStreamId &&
            onLocalVideoStreamRemoved != null) {
          onLocalVideoStreamRemoved(this, _localVideoStream);
          _localVideoStream = null;
        }
        break;
      case 'remoteVideoStreamAdded':
        String endpointId = map['endpointId'];
        String videoStreamId = map['videoStreamId'];
        int type = map['videoStreamType'];
        VIVideoStreamType videoStreamType = VIVideoStreamType.values[type];
        VIEndpoint endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint != null) {
          endpoint._remoteVideoStreamAdded(
              VIVideoStream._(videoStreamId, videoStreamType));
        }
        break;
      case 'remoteVideoStreamRemoved':
        String endpointId = map['endpointId'];
        String videoStreamId = map['videoStreamId'];
        VIEndpoint endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint != null) {
          endpoint._remoteVideoStreamRemoved(videoStreamId);
        }
        break;
    }
  }
}
