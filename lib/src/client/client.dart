/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

typedef void IncomingCall(Call call, Map<String, String> headers);

enum ClientState {
  Disconnected,
  Connecting,
  Connected,
  LoggingIn,
  LoggedIn,
}

class Client {
  IncomingCall onIncomingCall;

  final MethodChannel _channel;
  EventChannel _incomingCallEventChannel;
  StreamSubscription<dynamic> _incomingCallEventSubscription;
  StreamController<ClientState> _clientStateStreamController;

  Stream<ClientState> get clientStateStream => _clientStateStreamController.stream;

  Client._(this._channel, ClientConfig clientConfig) {
    _incomingCallEventChannel = EventChannel('plugins.voximplant.com/incoming_calls');
    EventChannel('plugins.voximplant.com/connection_closed')
        .receiveBroadcastStream('connection_closed')
        .listen(_connectionClosedEventListener);

    Map<String, dynamic> platformConfig = Map();
    if (Platform.isAndroid) {
      platformConfig['bundleId'] = clientConfig.bundleId;
      platformConfig['enableDebugLogging'] = clientConfig.enableDebugLogging;
      platformConfig['enableLogcatLogging'] = clientConfig.enableLogcatLogging;
      platformConfig['audioFocusMode'] = clientConfig.audioFocusMode.index;
    }
    if (Platform.isIOS) {
      platformConfig['bundleId'] = clientConfig.bundleId;
      platformConfig['logLevel'] = clientConfig.logLevel.index;
    }
    _channel.invokeMethod("initClient", platformConfig);

    _clientStateStreamController = StreamController.broadcast();
  }

  Future<ClientState> getClientState() async {
    int result = await _channel.invokeMethod('getClientState');
    return ClientState.values[result];
  }

  Future<void> connect({bool connectivityCheck = false, List<String> servers}) async {
    _changeClientState(ClientState.Connecting);
    try {
      await _channel.invokeMethod<void>('connect', <String, dynamic>{
        'connectivityCheck': connectivityCheck,
        'servers': servers,
      });
      ClientState state = await getClientState();
      _changeClientState(state);
    } catch (e) {
      ClientState state = await getClientState();
      _changeClientState(state);
      throw e;
    }
  }

  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
    ClientState state = await getClientState();
    _changeClientState(state);
  }

  Future<AuthResult> login(String username, String password) async {
    _changeClientState(ClientState.LoggingIn);
    try {
      Map<String, dynamic> data = await _channel.invokeMapMethod(
          'login', <String, String>{
        'username': username,
        'password': password
      });
      return _processLoginSuccess(data);
    } catch (e) {
      ClientState state = await getClientState();
      _changeClientState(state);
      throw e;
    }
  }

  Future<AuthResult> loginWithOneTimeKey(String username, String hash) async {
    _changeClientState(ClientState.LoggingIn);
    try {
      Map<String, dynamic> data = await _channel.invokeMapMethod('loginWithKey', <String, dynamic> {
        'username': username,
        'hash': hash,
      });
      return _processLoginSuccess(data);
    } catch (e) {
      ClientState state = await getClientState();
      _changeClientState(state);
      throw e;
    }
  }

  Future<AuthResult> loginWithAccessToken(String username, String token) async {
    _changeClientState(ClientState.LoggingIn);
    try {
      Map<String, dynamic> data = await _channel.invokeMapMethod('loginWithToken', <String, String> {
        'username': username,
        'token': token
      });
      return _processLoginSuccess(data);
    } catch (e) {
      ClientState state = await getClientState();
      _changeClientState(state);
      throw e;
    }
  }

  Future<String> requestOneTimeLoginKey(String username) async {
    return await _channel.invokeMethod('requestOneTimeKey', username);
  }

  Future<LoginTokens> tokenRefresh(String username, String refreshToken) async {
    Map<String, dynamic> data = await _channel.invokeMapMethod('tokenRefresh', <String, String> {
      'username': username,
      'refreshToken': refreshToken,
    });
    LoginTokens loginTokens = LoginTokens();
    loginTokens.accessExpire = data['accessExpire'];
    loginTokens.accessToken = data['accessToken'];
    loginTokens.refreshToken = data['refreshToken'];
    loginTokens.refreshExpire = data['refreshExpire'];
    return loginTokens;
  }

  Future<Call> call(String number, [CallSettings callSettings]) async {
    Map<String, dynamic> data = await _channel.invokeMapMethod('call', <String, dynamic> {
      'number': number,
      'customData': callSettings?.customData,
      'extraHeaders': callSettings?.extraHeaders
    });
    Call call = Call._(data['callId'], _channel);
    return call;
  }

  Future<void> registerForPushNotifications(String pushToken) async {
    await _channel.invokeMethod('registerForPushNotifications', pushToken);
  }

  Future<void> unregisterFromPushNotifications(String pushToken) async {
    await _channel.invokeMethod('unregisterFromPushNotifications', pushToken);
  }

  Future<void> handlePushNotification(Map<String, dynamic> message) async {
    await _channel.invokeMethod('handlePushNotification', message);
  }

  Future<AuthResult> _processLoginSuccess(Map<String, dynamic> data) async {
    _incomingCallEventSubscription = _incomingCallEventChannel
        .receiveBroadcastStream('incoming_calls')
        .listen(_incomingCallEventListener);

    LoginTokens loginTokens = LoginTokens();
    loginTokens.accessExpire = data["accessExpire"];
    loginTokens.accessToken = data["accessToken"];
    loginTokens.refreshToken = data["refreshToken"];
    loginTokens.refreshExpire = data["refreshExpire"];
    AuthResult authResult = AuthResult._(data["displayName"], loginTokens);

    ClientState state = await getClientState();
    _changeClientState(state);

    return authResult;
  }

  void _incomingCallEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'incomingCall') {
      String endpointId = map['endpointId'];
      String userName = map['endpointUserName'];
      String displayName = map['endpointDisplayName'];
      String sipUri = map['endpoitnSipUri'];
      Endpoint endpoint = Endpoint._(endpointId, userName, displayName, sipUri);
      Call call = Call._withEndpoint(map['callId'], _channel, endpoint);
      Map<String, String> headers = new Map();
      map['headers'].forEach((key,value) => {
        headers[key as String] = value as String
      });
      if (onIncomingCall != null) {
        onIncomingCall(call, headers);
      }
    }
  }

  void _connectionClosedEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'connectionClosed') {
      _changeClientState(ClientState.Disconnected);
      if (_incomingCallEventSubscription != null) {
        _incomingCallEventSubscription.cancel();
        _incomingCallEventSubscription = null;
      }
    }
  }

  void _changeClientState(ClientState newState) {
    _clientStateStreamController.add(newState);
  }
}
