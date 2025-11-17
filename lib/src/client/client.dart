// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

/// Signature for callbacks reporting that there is a new incoming call
/// to the current user.
///
/// Used in [VIClient].
///
/// It provides a [VICall] instance for the incoming call and optional
/// SIP [headers], and indicates if the caller initiated a [video] call.
///
/// `client` - VIClient instance initiated the event
///
/// `call` - Incoming call represented by VICall instance
///
/// `video` - Whether the caller initiated a video call
///
/// `headers` - Optional SIP headers
typedef void VIIncomingCall(
  VIClient client,
  VICall call,
  bool video,
  Map<String, String>? headers,
);

/// Signature for callbacks reporting that previously received VoIP push
/// notification is expired on iOS.
///
/// Used in [VIClient].
///
/// This callback can be used for CallKit integration on iOS.
///
/// It is recommended to end CXCall with associated [uuid].
///
/// `client` - VIClient instance initiated the event
///
/// `uuid` - CallKit UUID associated with the VoIP push
typedef void VIPushDidExpire(VIClient client, String uuid);

/// Interface that may be used to connect, login to the Voximplant cloud, make
/// and receive audio and video calls.
class VIClient {
  /// Callback for getting notified about new incoming call.
  VIIncomingCall? onIncomingCall;

  /// Triggered when push notification is expired.
  VIPushDidExpire? onPushDidExpire;

  final MethodChannel _channel;
  late EventChannel _incomingCallEventChannel;
  StreamSubscription<dynamic>? _incomingCallEventSubscription;
  late StreamController<VIClientState> _clientStateStreamController;

  /// Receive [VIClientState] each time the state is changed.
  Stream<VIClientState> get clientStateStream =>
      _clientStateStreamController.stream;

  VIClient._(this._channel, VIClientConfig clientConfig) {
    _incomingCallEventChannel =
        EventChannel('plugins.voximplant.com/incoming_calls');
    EventChannel('plugins.voximplant.com/connection_events')
        .receiveBroadcastStream('connection_events')
        .listen(_connectionEventListener);

    Map<String, dynamic> platformConfig = {};
    if (Platform.isAndroid) {
      platformConfig['bundleId'] = clientConfig.bundleId;
      platformConfig['enableDebugLogging'] = clientConfig.enableDebugLogging;
      platformConfig['enableLogcatLogging'] = clientConfig.enableLogcatLogging;
      platformConfig['audioFocusMode'] = clientConfig.audioFocusMode.index;
      platformConfig['forceRelayTraffic'] = clientConfig.forceRelayTraffic;
    }
    if (Platform.isIOS) {
      platformConfig['bundleId'] = clientConfig.bundleId;
      platformConfig['logLevel'] = clientConfig.logLevel.index;
      platformConfig['forceRelayTraffic'] = clientConfig.forceRelayTraffic;
    }
    _channel.invokeMethod("Client.initClient", platformConfig);

    _clientStateStreamController = StreamController.broadcast();
  }

  /// Returns the current client state
  Future<VIClientState> getClientState() async {
    String? result =
        await (_channel.invokeMethod<String>('Client.getClientState'));
    if (result == null) {
      _VILog._e(
          'VIClient: getClientState: result was null, returning disconnected');
      throw VIClientError.ERROR_INTERNAL;
    }

    switch (result) {
      case "Disconnected":
        return VIClientState.Disconnected;
      case "Connecting":
        return VIClientState.Connecting;
      case "Reconnecting":
        return VIClientState.Reconnecting;
      case "Connected":
        return VIClientState.Connected;
      case "LoggingIn":
        return VIClientState.LoggingIn;
      case "LoggedIn":
        return VIClientState.LoggedIn;
      default:
        _VILog._e(
            'VIClient: getClientState: result was undefined, returning disconnected');
        return VIClientState.Disconnected;
    }
  }

  /// Connects to the Voximplant cloud.
  ///
  /// Whether UDP traffic flows correctly between device and
  /// the Voximplant cloud if [connectivityCheck] is enabled (disabled by
  /// default).
  ///
  /// `node` - Specifies the node the Voximplant account belongs to.
  ///
  /// Optional `connectivityCheck` - Whether UDP traffic flows correctly
  /// between device and Voximplant cloud. This check reduces connection speed.
  ///
  /// Optional `servers` - List of server names of particular media gateways for connection.
  ///
  /// Throws [VIException] if the connection to the Voximplant cloud could not
  /// be established.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_CONNECTION_FAILED] - If the connection is currently
  ///   establishing or already established, or an error occurred.
  Future<void> connect({
    required VINode node,
    bool connectivityCheck = false,
    List<String>? servers,
  }) async {
    _changeClientState(VIClientState.Connecting);
    try {
      await _channel.invokeMethod<void>('Client.connect', <String, dynamic>{
        'connectivityCheck': connectivityCheck,
        'servers': servers,
        'node': node.name,
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

  /// Closes the connection with the Voximplant cloud.
  Future<void> disconnect() async {
    await _channel.invokeMethod('Client.disconnect');
    VIClientState state = await getClientState();
    _changeClientState(state);
  }

  /// Logs in a user with the given Voximplant username and password.
  ///
  /// `username` - Full user name, including Voximplant user, application, and
  ///  account name in the format `user@application.account.voximplant.com`.
  ///
  /// `password` - User password.
  ///
  /// Throws [VIException], if login process failed, otherwise returns [VIAuthResult].
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_MAU_ACCESS_DENIED] - Monthly Active Users (MAU) limit is reached. Payment is required.
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
      Map<String, dynamic>? data =
          await _channel.invokeMapMethod<String, dynamic>(
        'Client.login',
        <String, String>{'username': username, 'password': password},
      );
      if (data == null) {
        _VILog._e('VIClient: login: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:login: data was null',
        );
      }
      _saveUsername(username);
      return await _processLoginSuccess(data);
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
  /// that has been generated before.
  ///
  /// `username` - Full user name, including Voximplant user, application, and
  ///  account name in the format `user@application.account.voximplant.com`.
  ///
  /// `hash` - Hash that has been generated using following formula:
  /// MD5(oneTimeKey+"|"+MD5(user+":voximplant.com:"+password)).
  ///
  /// Throws [VIException], if login process failed, otherwise returns [VIAuthResult].
  ///
  /// Errors:
  /// * [VIClientError.ERROR_ACCOUNT_FROZEN] - If the account is frozen.
  /// * [VIClientError.ERROR_MAU_ACCESS_DENIED] - Monthly Active Users (MAU) limit is reached. Payment is required.
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
      Map<String, dynamic>? data = await _channel
          .invokeMapMethod('Client.loginWithKey', <String, dynamic>{
        'username': username,
        'hash': hash,
      });
      if (data == null) {
        _VILog._e('VIClient: login: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:login: data was null',
        );
      }
      _saveUsername(username);
      return await _processLoginSuccess(data);
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
  /// `username` - Full user name, including Voximplant user, application, and
  ///  account name in the format `user@application.account.voximplant.com`.
  ///
  /// `token` - Access token that has been obtained from [VIAuthResult.loginTokens] after
  ///  previous successful login.
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
    String username,
    String token,
  ) async {
    _changeClientState(VIClientState.LoggingIn);
    try {
      Map<String, dynamic>? data =
          await _channel.invokeMapMethod<String, dynamic>(
        'Client.loginWithToken',
        <String, String>{'username': username, 'token': token},
      );
      if (data == null) {
        _VILog._e('VIClient: login: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:login: data was null',
        );
      }
      _saveUsername(username);
      return await _processLoginSuccess(data);
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
  /// `username` - Full user name, including Voximplant user, application, and
  ///  account name in the format `user@application.account.voximplant.com`.
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
  ///   the Voximplant cloud is closed while the client is logging in.
  /// * [VIClientError.ERROR_TIMEOUT] - If timeout occurred.
  Future<String> requestOneTimeLoginKey(String username) async {
    try {
      return await _channel.invokeMethod('Client.requestOneTimeKey', username);
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Performs refresh of access token for the given Voximplant username via a
  /// refresh token.
  ///
  /// `username` - Full user name, including Voximplant user, application, and
  ///  account name in the format `user@application.account.voximplant.com`.
  ///
  /// `token` - Refresh token can be obtained from [VIAuthResult.loginTokens] after
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
  Future<VILoginTokens> tokenRefresh(String username, String token) async {
    try {
      Map<String, dynamic>? data = await _channel
          .invokeMapMethod<String, dynamic>(
              'Client.tokenRefresh', <String, String>{
        'username': username,
        'refreshToken': token,
      });
      if (data == null) {
        _VILog._e('VIClient: tokenRefresh: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:tokenRefresh: data was null',
        );
      }
      VILoginTokens loginTokens = VILoginTokens(
        accessExpire: data['accessExpire'] ?? 0,
        accessToken: data['accessToken'] ?? '',
        refreshExpire: data['refreshExpire'] ?? 0,
        refreshToken: data['refreshToken'] ?? '',
      );
      return loginTokens;
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Creates a new [VICall] instance and starts the outgoing call.
  ///
  /// `number` - The call destination that might be
  /// Voximplant username, phone number or SIP URI. Actual routing is then
  /// performed by a VoxEngine scenario.
  ///
  /// Optional `settings` - Additional call parameters like video direction
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
  Future<VICall> call(String number, {VICallSettings? settings}) async {
    try {
      settings ??= VICallSettings();
      Map<String, dynamic>? data = await _channel
          .invokeMapMethod<String, dynamic>('Client.call', <String, dynamic>{
        'number': number,
        'sendVideo': settings.videoFlags.sendVideo,
        'receiveVideo': settings.videoFlags.receiveVideo,
        'videoCodec': settings.preferredVideoCodec.toString(),
        'customData': settings.customData,
        'extraHeaders': settings.extraHeaders,
        'conference': false,
      });
      if (data == null) {
        _VILog._e('VIClient: call: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:call: data was null',
        );
      }
      VICall call = VICall._(data['callId'], _channel);
      return call;
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Creates a new [VICall] instance and starts the conference.
  ///
  /// `conference` - The call destination.
  /// For SIP compatibility reasons it should be a non-empty string even
  /// if the number itself is not used by a Voximplant cloud scenario.
  ///
  /// Optional `settings` - Additional call parameters like video direction
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
  Future<VICall> conference(
    String conference, {
    VICallSettings? settings,
  }) async {
    try {
      settings ??= VICallSettings();
      Map<String, dynamic>? data = await _channel
          .invokeMapMethod<String, dynamic>('Client.call', <String, dynamic>{
        'number': conference,
        'sendVideo': settings.videoFlags.sendVideo,
        'receiveVideo': settings.videoFlags.receiveVideo,
        'videoCodec': settings.preferredVideoCodec.toString(),
        'customData': settings.customData,
        'extraHeaders': settings.extraHeaders,
        'conference': true,
        'enableSimulcast': settings.enableSimulcast,
      });
      if (data == null) {
        _VILog._e('VIClient: conference: data was null, skipping');
        throw VIException(
          VIClientError.ERROR_INTERNAL,
          'VIClient:conference: data was null',
        );
      }
      VICall call = VICall._(data['callId'], _channel);
      return call;
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Registers for VoIP push notification with the given token.
  ///
  /// Application can receive push notifications from Voximplant Server after
  /// first login.
  ///
  /// `pushToken` - Push notification token.
  ///
  /// Throws [VIException], if [pushToken] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [pushToken] is null.
  Future<void> registerForPushNotifications(String pushToken) async {
    try {
      await _channel.invokeMethod(
        'Client.registerForPushNotifications',
        pushToken,
      );
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Registers an Apple Push Notifications token.
  ///
  /// After calling this function application can receive push notifications from Voximplant Server.
  /// If the provided token is not nil, but the client is not logged in, the token is registered just after login.
  ///
  /// iOS ONLY.
  ///
  /// `imToken` - The APNS token for IM push notification.
  Future<void> registerIMPushNotificationsTokenIOS(String imToken) async {
    try {
      await _channel.invokeMethod(
        'Client.registerIMPushNotificationsToken',
        imToken,
      );
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Unregisters an Apple Push Notifications token.
  ///
  /// After calling this function application stops receiving push notifications from Voximplant Server.
  /// If the provided token is not nil, but the client is not logged in, the token is unregistered just after login.
  ///
  /// iOS ONLY.
  ///
  /// `imToken` - The APNS token for IM push notification.
  Future<void> unregisterIMPushNotificationsTokenIOS(String imToken) async {
    try {
      await _channel.invokeMethod(
        'Client.unregisterIMPushNotificationsToken',
        imToken,
      );
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Unregisters from VoIP push notifications.
  ///
  /// Application can no longer receive push notifications from Voximplant
  /// Server.
  ///
  /// `pushToken` - Push notification token.
  ///
  /// Throws [VIException], if [pushToken] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [pushToken] is null.
  Future<void> unregisterFromPushNotifications(String pushToken) async {
    try {
      await _channel.invokeMethod(
        'Client.unregisterFromPushNotifications',
        pushToken,
      );
    } on PlatformException catch (e) {
      throw VIException(e.code, e.message);
    }
  }

  /// Handles incoming push notification.
  ///
  /// `message` - Incoming push notification payload
  ///
  /// Throws [VIException], if [message] is null.
  ///
  /// Errors:
  /// * [VIClientError.ERROR_INVALID_ARGUMENTS] - If [message] is null.
  Future<void> handlePushNotification(Map<String, dynamic> message) async {
    await _channel.invokeMethod('Client.handlePushNotification', message);
  }

  Future<VIAuthResult> _processLoginSuccess(Map<String, dynamic> data) async {
    _incomingCallEventSubscription = _incomingCallEventChannel
        .receiveBroadcastStream('incoming_calls')
        .listen(_incomingCallEventListener);

    VILoginTokens? loginTokens;
    if (data['accessToken'] != null &&
        data['accessExpire'] != null &&
        data['refreshToken'] != null &&
        data['refreshExpire'] != null) {
      loginTokens = VILoginTokens(
        accessExpire: data['accessExpire'],
        accessToken: data['accessToken'],
        refreshExpire: data['refreshExpire'],
        refreshToken: data['refreshToken'],
      );
    }
    VIAuthResult authResult =
        VIAuthResult._(data["displayName"] ?? '', loginTokens);

    VIClientState state = await getClientState();
    _changeClientState(state);

    return authResult;
  }

  void _incomingCallEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'incomingCall') {
      String endpointId = map['endpointId'];
      String? userName = map['endpointUserName'];
      String? displayName = map['endpointDisplayName'];
      String? sipUri = map['endpointSipUri'];
      int? place = map['endpointPlace'];
      String? uuid = map['uuid'];
      bool video = map['video'];
      VIEndpoint endpoint =
          VIEndpoint._(endpointId, userName, displayName, sipUri, place);
      VICall call = VICall._withEndpoint(map['callId'], _channel, endpoint);
      if (uuid != null) {
        call.callKitUUID = uuid;
      }
      Map<String, String> headers = {};
      map['headers'].forEach(
        (key, value) => {headers[key as String] = value as String},
      );
      onIncomingCall?.call(this, call, video, headers);
    } else if (map['event'] == 'pushDidExpire') {
      String uuid = map['uuid'];
      onPushDidExpire?.call(this, uuid);
    }
  }

  void _connectionEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'connectionClosed') {
      _changeClientState(VIClientState.Disconnected);
      _incomingCallEventSubscription?.cancel();
      _incomingCallEventSubscription = null;
      _saveUsername(null);
    }
    if (map['event'] == 'reconnecting') {
      _changeClientState(VIClientState.Reconnecting);
    }
    if (map['event'] == 'reconnected') {
      _changeClientState(VIClientState.LoggedIn);
    }
  }

  void _changeClientState(VIClientState newState) {
    _clientStateStreamController.add(newState);
  }

  void _saveUsername(String? username) {
    _MessengerShared._saveMe(username);
  }
}
