/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

class CallSettings {
  String customData;
  Map<String, String> extraHeaders;
}

typedef void CallConnected(Map<String, String> headers);
typedef void CallDisconnected(Map<String, String> headers, bool answeredElsewhere);
typedef void CallRinging(Map<String, String> headers);
typedef void CallFailed(int code, String description, Map<String, String> headers);
typedef void CallAudioStarted();
typedef void SIPInfoReceived(String type, String content, Map<String, String> headers);
typedef void MessageReceived(String message);
typedef void ICETimeout();
typedef void ICECompleted();
typedef void EndpointAdded(Endpoint endpoint);

class Call {
  CallConnected onCallConnected;
  CallDisconnected onCallDisconnected;
  CallRinging onCallRinging;
  CallFailed onCallFailed;
  CallAudioStarted onCallAudioStarted;
  SIPInfoReceived onSIPInfoReceived;
  MessageReceived onMessageReceived;
  ICETimeout onICETimeout;
  ICECompleted onICECompleted;
  EndpointAdded onEndpointAdded;

  String _callId;
  MethodChannel _channel;
  StreamSubscription<dynamic> _eventSubscription;
  List<Endpoint> _endpoints;


  Call._(this._callId, this._channel) {
    _endpoints = List();
    _eventSubscription = EventChannel('plugins.voximplant.com/call_$_callId')
        .receiveBroadcastStream('plugins.voximplant.com/call_$_callId')
        .listen(_eventListener);
  }

  Call._withEndpoint(this._callId, this._channel, Endpoint endpoint) {
    _endpoints = List();
    _endpoints.add(endpoint);
    _eventSubscription = EventChannel('plugins.voximplant.com/call_$_callId')
        .receiveBroadcastStream('plugins.voximplant.com/call_$_callId')
        .listen(_eventListener);
  }

  String get callId => _callId;
  List<Endpoint> get endpoints => _endpoints;

  Future<void> answer([CallSettings callSettings]) async {
    await _channel.invokeMethod<void>('answerCall', <String, dynamic> {
      'callId': _callId,
      'customData': callSettings?.customData,
      'extraHeaders': callSettings?.extraHeaders
    });
  }

  Future<void> decline([Map<String, String> headers]) async {
    await _channel.invokeMethod<void>('rejectCall', <String, dynamic> {
      'callId': _callId,
      'headers': headers,
      'rejectMode': 'decline'
    });
  }

  Future<void> reject([Map<String, String> headers]) async {
    await _channel.invokeMethod<void>('rejectCall', <String, dynamic> {
      'callId': _callId,
      'headers': headers,
      'rejectMode': 'reject'
    });
  }

  Future<void> hangup([Map<String, String> headers]) async {
    await _channel.invokeMethod<void>('hangupCall', <String, dynamic>{
      'callId': _callId,
      'headers': headers
    });
  }

  Future<void> hold(bool enable) async {
    await _channel.invokeMethod<void>('holdCall', <String, dynamic> {
      'callId': _callId,
      'enable': enable
    });
  }

  Future<void> sendAudio(bool enable) async {
    await _channel.invokeMethod<void>('sendAudioForCall', <String, dynamic>{
      'callId': _callId,
      'enable': enable
    });
  }

  Future<void> sendInfo(String mimeType, String body, Map<String, String> headers) async {
    await _channel.invokeMethod<void>('sendInfoForCall', <String, dynamic>{
      'callId': _callId,
      'mimetype': mimeType,
      'body': body,
      'headers': headers
    });
  }

  Future<void> sendMessage(String message) async {
    await _channel.invokeMethod<void>('sendMessageForCall', <String, dynamic>{
      'callId': _callId,
      'message': message
    });
  }

  Future<void> sendTone(String key) async {
    await _channel.invokeMethod<void>('sendToneForCall', <String, String> {
      'callId': _callId,
      'tone': key
    });
  }

  void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'callConnected':
        Map<String, String> headers = new Map();
        map['headers'].forEach((key,value) => {
          headers[key as String] = value as String
        });
        if (onCallConnected != null) {
          onCallConnected(headers);
        }
        break;
      case 'callDisconnected':
        _eventSubscription.cancel();
        Map<String, String> headers = new Map();
        map['headers'].forEach((key,value) => {
          headers[key as String] = value as String
        });
        bool answeredElsewhere = map['answeredElsewhere'];
        if (onCallDisconnected != null) {
          onCallDisconnected(headers, answeredElsewhere);
        }
        break;
      case 'callRinging':
        Map<String, String> headers = new Map();
        map['headers'].forEach((key,value) => {
          headers[key as String] = value as String
        });
        if (onCallRinging != null) {
          onCallRinging(headers);
        }
        break;
      case 'callFailed':
        _eventSubscription.cancel();
        int code = map['code'];
        String description = map['description'];
        Map<String, String> headers = new Map();
        map['headers'].forEach((key,value) => {
          headers[key as String] = value as String
        });
        if (onCallFailed != null) {
          onCallFailed(code, description, headers);
        }
        break;
      case 'callAudioStarted':
        if (onCallAudioStarted != null) {
          onCallAudioStarted();
        }
        break;
      case 'sipInfoReceived':
        String type = map['type'];
        String content = map['content'];
        Map<String, String> headers = new Map();
        map['headers'].forEach((key,value) => {
          headers[key as String] = value as String
        });
        if (onSIPInfoReceived != null) {
          onSIPInfoReceived(type, content, headers);
        }
        break;
      case 'messageReceived':
        String message = map['message'];
        if (onMessageReceived != null) {
          onMessageReceived(message);
        }
        break;
      case 'iceTimeout':
        if (onICETimeout != null) {
          onICETimeout();
        }
        break;
      case 'iceCompleted':
        if (onICECompleted != null) {
          onICECompleted();
        }
        break;
      case 'endpointAdded':
        String endpointId = map['endpointId'];
        Endpoint endpoint;
        for (Endpoint callEndpoint in _endpoints) {
          if (callEndpoint.endpointId == endpointId) {
            endpoint = callEndpoint;
            break;
          }
        }
        if (endpoint == null) {
          String userName = map['userName'];
          String displayName = map['displayName'];
          String sipUri = map['sipUri'];
          endpoint = Endpoint._(
              endpointId, userName, displayName, sipUri);
          _endpoints.add(endpoint);
        }
        if (onEndpointAdded != null) {
          onEndpointAdded(endpoint);
        }
        break;
      case 'endpointInfoUpdated':
        String endpointId = map['endpointId'];
        Endpoint endpoint;
        for (Endpoint callEndpoint in _endpoints) {
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
    }
  }
}
