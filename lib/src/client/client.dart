/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Signature for callbacks reporting that there is a new incoming call
/// to the current user.
///
/// Used in [VIClient].
///
/// It provides a [VICall] instance for the incoming call and optional
/// SIP [headers], and indicates if the caller initiated a [video] call.
typedef void VIIncomingCall(
    VIClient client, VICall call, bool video, Map<String, String> headers);

/// Signature for callbacks reporting that previously received VoIP push
/// notification is expired on iOS.
///
/// Used in [VIClient].
///
/// This callback can be used for CallKit integration on iOS.
///
/// It is recommended to end CXCall with associated [uuid].
typedef void VIPushDidExpire(VIClient client, String uuid);

/// Interface that may be used to connect, login to the Voximplant CLoud, make
/// and receive audio and video calls.
class VIClient {
  /// Callback for getting notified about new incoming call.
  VIIncomingCall onIncomingCall;
  /// Callback for getting notified when push notification is expired.
  VIPushDidExpire onPushDidExpire;

  final MethodChannel _channel;
  EventChannel _incomingCallEventChannel;
  StreamSubscription<dynamic> _incomingCallEventSubscription;
  StreamController<VIClientState> _clientStateStreamController;

  /// Receive [VIClientState] each time the state is changed.
  Stream<VIClientState> get clientStateStream =>
      _clientStateStreamController.stream;

  VIClient._(this._channel, VIClientConfig clientConfig) {
    _incomingCallEventChannel =
        EventChannel('plugins.voximplant.com/incoming_calls');
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

  /// Returns the current client state
  Future<VIClientState> getClientState() async {
    int result = await _channel.invokeMethod('getClientState');
    return VIClientState.values[result];
  }

  /// Connects to the Voximplant Cloud.
  ///
  /// Checks whether UDP traffic will flow correctly between device and
  /// the Voximplant Cloud if [connectivityCheck] is enabled (disabled by
  /// default). This check reduces connection speed.
  ///
  /// Throws [VIException] if the connection to the Voximplant Cloud could not
  /// be established.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_CONNECTION_FAILED] - If the connection is currently
  ///   establishing or already established, or an error occurred.
  Future<void> connect(
      {bool connectivityCheck = false, List<String> servers}) async {
    _changeClientState(VIClientState.Connecting);
    try {
      await _channel.invokeMethod<void>('connect', <String, dynamic>{
        'connectivityCheck': connectivityCheck,
        'servers': servers,
      });
      VIClientState state = await getClientState();
      _changeClientState(state);
    } on PlatformException catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      throw VIException(e.code, e.message);
    } catch (e) {
      _VILog._e('VIClient.connect: catch: $e');
      VIClientState state = await getClientState();
      _changeClientState(state);
      rethrow;
    }
  }

  /// Closes the connection with the Voximplant Cloud.
  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
    VIClientState state = await getClientState();
    _changeClientState(state);
  }

  /// Logs in a user with the given Voximplant username and password.
  ///
  /// Voximplant [username] must include Voximplant user, application, and
  /// account name in the format `user@application.account.voximplant.com`.
  ///
  /// Throws [VIException], if login process failed, otherwise returns [VIAuthResult].
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VIClientError.ERROR_INVALID_PASSWORD] - if the given password is invalid.
  /// * [VIClientError.ERROR_INVALID_STATE] - If the client is not connected,
  ///   already logged in, or currently logging in.
  /// * [VIClientError.ERROR_INVALID_USERNAME] - If the given username is invalid.
  /// * [VIClientError.ERROR_NETWORK_ISSUES] - If the connection to the Voximplant
  ///   Cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  Future<VIAuthResult> login(String username, String password) async {
    _changeClientState(VIClientState.LoggingIn);
    try {
      Map<String, dynamic> data = await _channel.invokeMapMethod('login',
          <String, String>{'username': username, 'password': password});
      return _processLoginSuccess(data);
    } on PlatformException catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      throw VIException(e.code, e.message);
    } catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      rethrow;
    }
  }

  /// Logs in a user with the given Voximplant username and one time key
  /// that was generated before.
  ///
  /// Voximplant [username] must include Voximplant user, application, and
  /// account name in the format `user@application.account.voximplant.com`.
  ///
  /// Throws [VIException], if login process failed, otherwise returns [VIAuthResult].
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VIClientError.ERROR_INVALID_PASSWORD] - if the given password is invalid.
  /// * [VIClientError.ERROR_INVALID_STATE] - If the client is not connected,
  ///   already logged in, or currently logging in.
  /// * [VIClientError.ERROR_INVALID_USERNAME] - If the given username is invalid.
  /// * [VIClientError.ERROR_NETWORK_ISSUES] - If the connection to the Voximplant
  ///   Cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  Future<VIAuthResult> loginWithOneTimeKey(String username, String hash) async {
    _changeClientState(VIClientState.LoggingIn);
    try {
      Map<String, dynamic> data =
          await _channel.invokeMapMethod('loginWithKey', <String, dynamic>{
        'username': username,
        'hash': hash,
      });
      return _processLoginSuccess(data);
    } on PlatformException catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      throw VIException(e.code, e.message);
    } catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      rethrow;
    }
  }

  /// Logs in a user with the given Voximplant username and access token.
  ///
  /// Voximplant [username] must include Voximplant user, application, and
  /// account name in the format `user@application.account.voximplant.com`.
  ///
  /// Access [token] can be obtained from [VIAuthResult.loginTokens] after
  /// previous successful login.
  ///
  /// Throws [VIException], if login process failed, otherwise returns [VIAuthResult].
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VIClientError.ERROR_INVALID_STATE] - If the client is not connected,
  ///   already logged in, or currently logging in.
  /// * [VIClientError.ERROR_INVALID_USERNAME] - If the given username is invalid.
  /// * [VIClientError.ERROR_NETWORK_ISSUES] - If the connection to the Voximplant
  ///   Cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  /// * [VIClientError.ERROR_TOKEN_EXPIRED] - If the access token is expired.
  Future<VIAuthResult> loginWithAccessToken(
      String username, String token) async {
    _changeClientState(VIClientState.LoggingIn);
    try {
      Map<String, dynamic> data = await _channel.invokeMapMethod(
          'loginWithToken',
          <String, String>{'username': username, 'token': token});
      return _processLoginSuccess(data);
    } on PlatformException catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      throw VIException(e.code, e.message);
    } catch (e) {
      VIClientState state = await getClientState();
      _changeClientState(state);
      rethrow;
    }
  }

  /// Generates one time login key for the given Voximplant username.
  ///
  /// Voximplant [username] must include Voximplant user, application, and
  /// account name in the format `user@application.account.voximplant.com`.
  ///
  /// Throws [VIException], if an error occurred, otherwise returns one time key.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VIClientError.ERROR_INVALID_STATE] - If the client is not connected,
  ///   already logged in, or currently logging in.
  /// * [VIClientError.ERROR_INVALID_USERNAME] - If the given username is invalid.
  /// * [VIClientError.ERROR_NETWORK_ISSUES] - If the connection to
  ///   the Voximplant Cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  Future<String> requestOneTimeLoginKey(String username) async {
    try {
      return await _channel.invokeMethod('requestOneTimeKey', username);
    } on PlatformException catch(e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Performs refresh of access token for the given Voximplant username using
  /// refresh token.
  ///
  /// Voximplant [username] must include Voximplant user, application, and
  /// account name in the format `user@application.account.voximplant.com`.
  ///
  /// Refresh [token] can be obtained from [VIAuthResult.loginTokens] after
  /// previous successful login.
  ///
  /// Throws [VIException], if refresh process failed, otherwise returns
  /// new tokens.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_INTERNAL] - If an internal error occurred.
  /// * [VIClientError.ERROR_INVALID_STATE] - If the client is not connected,
  ///   already logged in, or currently logging in.
  /// * [VIClientError.ERROR_INVALID_USERNAME] - If the given username is invalid.
  /// * [VIClientError.ERROR_NETWORK_ISSUES] - If the connection to the Voximplant
  ///   Cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  /// * [VIClientError.ERROR_TOKEN_EXPIRED] - If the refresh token is expired.
  Future<VILoginTokens> tokenRefresh(
      String username, String token) async {
    try {
      Map<String, dynamic> data =
      await _channel.invokeMapMethod('tokenRefresh', <String, String>{
        'username': username,
        'refreshToken': token,
      });
      VILoginTokens loginTokens = VILoginTokens();
      loginTokens.accessExpire = data['accessExpire'];
      loginTokens.accessToken = data['accessToken'];
      loginTokens.refreshToken = data['refreshToken'];
      loginTokens.refreshExpire = data['refreshExpire'];
      return loginTokens;
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Creates a new [VICall] instance and starts the outgoing call.
  ///
  /// The call destination should be provided via [number] that might be
  /// Voximplant username, phone number or SIP URI. Actual routing is then
  /// performed by a VoxEngine scenario.
  ///
  /// Additional call parameters are set up via [callSettings]: video direction
  /// for the call, preferred video codec, custom data.
  ///
  /// Throws [VIException], if the client is not logged in, otherwise returns
  /// [VICall] instance.
  ///
  /// Errors:
  /// * [VICallError.ERROR_CLIENT_NOT_LOGGED_IN] - If the client is not logged in
  /// * [VICallError.ERROR_MISSING_PERMISSION] - Android only. If permissions
  ///   are not granted for the call:
  ///   audio calls - RECORD_AUDIO
  ///   video calls - RECORD_AUDIO and CAMERA
  Future<VICall> call(String number, [VICallSettings callSettings]) async {
    try {
      Map<String, dynamic> data =
      await _channel.invokeMapMethod('call', <String, dynamic>{
        'number': number,
        'sendVideo': callSettings?.videoFlags?.sendVideo ?? false,
        'receiveVideo': callSettings?.videoFlags?.receiveVideo ?? false,
        'videoCodec': callSettings?.preferredVideoCodec.toString() ??
            VIVideoCodec.AUTO.toString(),
        'customData': callSettings?.customData,
        'extraHeaders': callSettings?.extraHeaders
      });
      VICall call = VICall._(data['callId'], _channel);
      return call;
    } on PlatformException catch(e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Registers for VoIP push notification with the given token.
  ///
  /// Application will receive push notifications from Voximplant Server after
  /// first login.
  ///
  /// Throws [VIException], if [pushToken] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [pushToken] is null.
  Future<void> registerForPushNotifications(String pushToken) async {
    try {
      await _channel.invokeMethod('registerForPushNotifications', pushToken);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Unregisters from VoIP push notifications.
  ///
  /// Application will no longer receive push notifications from Voximplant
  /// Server.
  ///
  /// Throws [VIException], if [pushToken] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [pushToken] is null.
  Future<void> unregisterFromPushNotifications(String pushToken) async {
    try {
      await _channel.invokeMethod('unregisterFromPushNotifications', pushToken);
    } on PlatformException catch(e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Handles incoming push notification.
  ///
  /// Throws [VIException], if [message] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [message] is null.
  Future<void> handlePushNotification(Map<String, dynamic> message) async {
    await _channel.invokeMethod('handlePushNotification', message);
  }

  Future<VIAuthResult> _processLoginSuccess(Map<String, dynamic> data) async {
    _incomingCallEventSubscription = _incomingCallEventChannel
        .receiveBroadcastStream('incoming_calls')
        .listen(_incomingCallEventListener);

    VILoginTokens loginTokens = VILoginTokens();
    loginTokens.accessExpire = data["accessExpire"];
    loginTokens.accessToken = data["accessToken"];
    loginTokens.refreshToken = data["refreshToken"];
    loginTokens.refreshExpire = data["refreshExpire"];
    VIAuthResult authResult = VIAuthResult._(data["displayName"], loginTokens);

    VIClientState state = await getClientState();
    _changeClientState(state);

    return authResult;
  }

  void _incomingCallEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'incomingCall') {
      String endpointId = map['endpointId'];
      String userName = map['endpointUserName'];
      String displayName = map['endpointDisplayName'];
      String sipUri = map['endpointSipUri'];
      String uuid = map['uuid'];
      bool video = map['video'];
      VIEndpoint endpoint =
          VIEndpoint._(endpointId, userName, displayName, sipUri);
      VICall call = VICall._withEndpoint(map['callId'], _channel, endpoint);
      if (uuid != null) {
        call.callKitUUID = uuid;
      }
      Map<String, String> headers = new Map();
      map['headers']
          .forEach((key, value) => {headers[key as String] = value as String});
      if (onIncomingCall != null) {
        onIncomingCall(this, call, video, headers);
      }
    } else if (map['event'] == 'pushDidExpire') {
      String uuid = map['uuid'];
      if (onPushDidExpire != null) {
        onPushDidExpire(this, uuid);
      }
    }
  }

  void _connectionClosedEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'connectionClosed') {
      _changeClientState(VIClientState.Disconnected);
      if (_incomingCallEventSubscription != null) {
        _incomingCallEventSubscription.cancel();
        _incomingCallEventSubscription = null;
      }
    }
  }

  void _changeClientState(VIClientState newState) {
    _clientStateStreamController.add(newState);
  }
}
