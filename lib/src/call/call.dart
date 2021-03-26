/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Represents supported video codecs.
enum VIVideoCodec { AUTO, H264, VP8 }

/// Specifies video direction for a call.
class VIVideoFlags {
  bool sendVideo;
  bool receiveVideo;

  VIVideoFlags({this.sendVideo = false, this.receiveVideo = false});
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
  String? customData;

  /// Optional set of headers to be sent to the Voximplant cloud.
  ///
  /// Names must begin with "X-" to be processed by SDK.
  Map<String, String>? extraHeaders;
}

/// Signature for callbacks reporting that the call is connected.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `headers` - Optional SIP headers
typedef void VICallConnected(VICall call, Map<String, String>? headers);

/// Signature for callbacks reporting that the call is disconnected.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `headers` - Optional SIP headers
///
/// `answeredElsewhere` - Check if the call was answered on another device
typedef void VICallDisconnected(
  VICall call,
  Map<String, String>? headers,
  bool answeredElsewhere,
);

/// Signature for callbacks reporting when progress signal is received
/// from the endpoint.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `headers` - Optional SIP headers
typedef void VICallRinging(VICall call, Map<String, String>? headers);

/// Signature for callbacks reporting that the call was failed.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `code` - Error code
///
/// `description` - Error description
///
/// `headers` - Optional SIP headers
typedef void VICallFailed(
  VICall call,
  int code,
  String description,
  Map<String, String>? headers,
);

/// Signature for callbacks reporting that the endpoint answered the call.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
typedef void VICallAudioStarted(VICall call);

/// Signature for callbacks reporting that INFO message is received.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `type` - MIME type of INFO message
///
/// `content` - Body of INFO message
///
/// `headers` - Optional SIP headers
typedef void VISIPInfoReceived(
  VICall call,
  String type,
  String content,
  Map<String, String>? headers,
);

/// Signature for callbacks reporting that [message] is received within the call.
///
/// Implemented atop SIP INFO for communication between call endpoint and the
/// Voximplant Cloud, and is separated from Voximplant messaging API.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `message` - Content of the message
typedef void VIMessageReceived(VICall call, String message);

/// Signature for callbacks reporting that the connection was not established
/// due to a network connection problem between 2 peers.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
typedef void VIICETimeout(VICall call);

/// Signature for callbacks reporting that ICE connection is complete.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
typedef void VIICECompleted(VICall call);

/// Signature for callbacks reporting that new endpoint is added to the call.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `endpoint` - New endpoint
typedef void VIEndpointAdded(VICall call, VIEndpoint endpoint);

/// Signature for callbacks reporting that local video is added to the call.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `videoStream` - Local video stream
typedef void VILocalVideoStreamAdded(VICall call, VIVideoStream videoStream);

/// Signature for callbacks reporting that local video is removed from the call.
///
/// Used in [VICall].
///
/// `call` - VICall instance initiated the event
///
/// `videoStream` - Local video stream
typedef void VILocalVideoStreamRemoved(VICall call, VIVideoStream videoStream);

/// Represents a call.
class VICall {
  /// Callback for getting notified when the call is connected.
  VICallConnected? onCallConnected;

  /// Callback for getting notified when the call is disconnected.
  VICallDisconnected? onCallDisconnected;

  /// Callback for getting notified when progress signal is received
  /// from the endpoint.
  VICallRinging? onCallRinging;

  /// Callback for getting notified when the call is failed.
  VICallFailed? onCallFailed;

  /// Callback for getting notified when the endpoint answered the call.
  VICallAudioStarted? onCallAudioStarted;

  /// Callback for getting notified when INFO message in received.
  VISIPInfoReceived? onSIPInfoReceived;

  /// Callback for getting notified when message is received.
  VIMessageReceived? onMessageReceived;

  /// Callback for getting notified about failure to connect peers.
  VIICETimeout? onICETimeout;

  /// Callback for getting notified when ICE connection is completed.
  VIICECompleted? onICECompleted;

  /// Callback for getting notified when new endpoint is added to the call.
  VIEndpointAdded? onEndpointAdded;

  /// Callback for getting notified when local video is added to the call.
  VILocalVideoStreamAdded? onLocalVideoStreamAdded;

  /// Callback for getting notified when local video is removed from the call.
  VILocalVideoStreamRemoved? onLocalVideoStreamRemoved;

  final String _callId;
  String? _callKitUUID;
  final MethodChannel _channel;
  late StreamSubscription<dynamic> _eventSubscription;
  List<VIEndpoint> _endpoints = [];

  VIVideoStream? _localVideoStream;

  VICall._(this._callId, this._channel) {
    _setupEventSubscription();
  }

  VICall._withEndpoint(this._callId, this._channel, VIEndpoint endpoint) {
    _endpoints.add(endpoint);
    _setupEventSubscription();
  }

  void _setupEventSubscription() {
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
  String? get callKitUUID => _callKitUUID;

  set callKitUUID(String? uuid) {
    _callKitUUID = uuid?.toUpperCase();
    if (Platform.isIOS) {
      _channel.invokeMethod<void>('Call.setCallKitUUID',
          <String, dynamic>{'callId': _callId, 'uuid': _callKitUUID});
    }
  }

  /// The endpoints associated with the call.
  List<VIEndpoint> get endpoints => _endpoints;

  /// The active local video stream.
  VIVideoStream? get localVideoStream => _localVideoStream;

  /// Answers the incoming call.
  ///
  /// Additional call parameters are set up via [callSettings]: video direction
  /// for the call, preferred video codec, custom data.
  ///
  /// `settings` - Additional call parameters like video direction
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
  Future<void> answer({required VICallSettings settings}) async {
    try {
      await _channel.invokeMethod<void>('Call.answerCall', <String, dynamic>{
        'callId': _callId,
        'sendVideo': settings.videoFlags.sendVideo,
        'receiveVideo': settings.videoFlags.receiveVideo,
        'videoCodec': settings.preferredVideoCodec.toString(),
        'customData': settings.customData,
        'extraHeaders': settings.extraHeaders
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
  /// Optional `headers` - Optional SIP headers
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - Android only. If the call is
  ///   already answered or ended.
  Future<void> decline([Map<String, String>? headers]) async {
    await _reject('decline', headers);
  }

  /// Rejects the incoming call.
  ///
  /// Should be used only for incoming calls.
  ///
  /// Indicates that the user is not available only at a particular device.
  ///
  /// Optional `headers` - Optional SIP headers
  ///
  /// Throws [VIException], if an error occurred.
  ///
  /// Errors:
  /// * [VICallError.ERROR_INCORRECT_OPERATION] - Android only. If the call is
  ///   already answered or ended.
  Future<void> reject([Map<String, String>? headers]) async {
    await _reject('reject', headers);
  }

  Future<void> _reject(String mode, [Map<String, String>? headers]) async {
    try {
      await _channel.invokeMethod<void>('Call.rejectCall', <String, dynamic>{
        'callId': _callId,
        'headers': headers,
        'rejectMode': mode
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Disconnects the call.
  ///
  /// Optional `headers` - Optional SIP headers
  Future<void> hangup([Map<String, String>? headers]) async {
    try {
      await _channel.invokeMethod<void>('Call.hangupCall',
          <String, dynamic>{'callId': _callId, 'headers': headers});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Puts the call on/off hold.
  ///
  /// `enable` - True if the call should be put on hold, false for unhold
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
      await _channel.invokeMethod<void>('Call.holdCall',
          <String, dynamic>{'callId': _callId, 'enable': enable});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Enables or disables audio transfer from microphone into the call.
  ///
  /// `enable` - True if audio should be sent, false otherwise
  Future<void> sendAudio(bool enable) async {
    try {
      await _channel.invokeMethod<void>('Call.sendAudioForCall',
          <String, dynamic>{'callId': _callId, 'enable': enable});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Send INFO message within the call.
  ///
  /// INFO message will be sent, if the call is establishing or established.
  ///
  /// `mimeType` - MIME type of info
  ///
  /// `body` - Custom string data
  ///
  /// `headers` - Optional SIP headers
  Future<void> sendInfo(
    String mimeType,
    String body,
    Map<String, String>? headers,
  ) async {
    try {
      await _channel
          .invokeMethod<void>('Call.sendInfoForCall', <String, dynamic>{
        'callId': _callId,
        'mimetype': mimeType,
        'body': body,
        'headers': headers,
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends [message] within the call.
  ///
  /// Implemented atop SIP INFO for communication between call endpoint and the
  /// Voximplant Cloud, and is separated from Voximplant messaging API.
  ///
  /// `message` - Message text
  Future<void> sendMessage(String message) async {
    try {
      await _channel.invokeMethod<void>('Call.sendMessageForCall',
          <String, dynamic>{'callId': _callId, 'message': message});
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Sends DTMFs in the call.
  ///
  /// DTMFs can be sent only if the call is connected.
  ///
  /// `key` - DTMFs
  Future<void> sendTone(String key) async {
    try {
      await _channel.invokeMethod<void>('Call.sendToneForCall',
          <String, String?>{'callId': _callId, 'tone': key});
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
  /// `enable` - True if video should be sent, false otherwise
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
      await _channel.invokeMethod('Call.sendVideoForCall', <String, dynamic>{
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
      await _channel.invokeMethod('Call.receiveVideoForCall', <String, String>{
        'callId': callId,
      });
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Returns the call duration in milliseconds.
  Future<int?> getCallDuration() async {
    try {
      return await _channel
          .invokeMethod('Call.getCallDuration', <String, String>{
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
        Map<String, String> headers = {};
        map['headers'].forEach(
          (key, value) => {headers[key as String] = value as String},
        );
        onCallConnected?.call(this, headers);
        break;
      case 'callDisconnected':
        _eventSubscription.cancel();
        Map<String, String> headers = {};
        map['headers'].forEach(
          (key, value) => {headers[key as String] = value as String},
        );
        bool answeredElsewhere = map['answeredElsewhere'];
        onCallDisconnected?.call(this, headers, answeredElsewhere);
        break;
      case 'callRinging':
        Map<String, String> headers = {};
        map['headers'].forEach(
          (key, value) => {headers[key as String] = value as String},
        );
        onCallRinging?.call(this, headers);
        break;
      case 'callFailed':
        _eventSubscription.cancel();
        int code = map['code'];
        String description = map['description'];
        Map<String, String> headers = {};
        map['headers'].forEach(
          (key, value) => {headers[key as String] = value as String},
        );
        onCallFailed?.call(this, code, description, headers);
        break;
      case 'callAudioStarted':
        onCallAudioStarted?.call(this);
        break;
      case 'sipInfoReceived':
        String type = map['type'];
        String content = map['body'];
        Map<String, String> headers = {};
        map['headers'].forEach(
          (key, value) => {headers[key as String] = value as String},
        );
        onSIPInfoReceived?.call(this, type, content, headers);
        break;
      case 'messageReceived':
        String message = map['message'];
        onMessageReceived?.call(this, message);
        break;
      case 'iceTimeout':
        onICETimeout?.call(this);
        break;
      case 'iceCompleted':
        onICECompleted?.call(this);
        break;
      case 'endpointAdded':
        String endpointId = map['endpointId'];
        VIEndpoint? endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint == null) {
          String? userName = map['userName'];
          String? displayName = map['displayName'];
          String? sipUri = map['sipUri'];
          int? place = map['endpointPlace'];
          endpoint =
              VIEndpoint._(endpointId, userName, displayName, sipUri, place);
          _endpoints.add(endpoint);
        }
        onEndpointAdded?.call(this, endpoint);
        break;
      case 'endpointInfoUpdated':
        String endpointId = map['endpointId'];
        VIEndpoint? endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint != null) {
          String? userName = map['endpointUserName'];
          String? displayName = map['endpointDisplayName'];
          String? sipUri = map['endpointSipUri'];
          int? place = map['endpointPlace'];
          endpoint._invokeEndpointUpdatedEvent(
            userName,
            displayName,
            sipUri,
            place,
          );
        }
        break;
      case 'endpointRemoved':
        String endpointId = map['endpointId'];
        VIEndpoint? endpoint;
        for (VIEndpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        endpoint?._invokeEndpointRemovedEvent();
        break;
      case 'localVideoStreamAdded':
        String videoStreamId = map['videoStreamId'];
        int type = map['videoStreamType'];
        VIVideoStreamType videoStreamType = VIVideoStreamType.values[type];
        var videoStream = VIVideoStream._(videoStreamId, videoStreamType);
        _localVideoStream = videoStream;
        onLocalVideoStreamAdded?.call(this, videoStream);
        break;
      case 'localVideoStreamRemoved':
        String videoStreamId = map['videoStreamId'];
        var videoStream = _localVideoStream;
        if (videoStream != null && videoStream.streamId == videoStreamId) {
          onLocalVideoStreamRemoved?.call(this, videoStream);
          _localVideoStream = null;
        }
        break;
      case 'remoteVideoStreamAdded':
        String endpointId = map['endpointId'];
        String videoStreamId = map['videoStreamId'];
        int type = map['videoStreamType'];
        VIVideoStreamType videoStreamType = VIVideoStreamType.values[type];
        VIEndpoint? endpoint;
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
        VIEndpoint? endpoint;
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
