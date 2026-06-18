// Copyright (c) 2011 - 2026, Voximplant, Inc. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ConnectionClosed = void Function();

class AuthService {
  VIClient _client;
  VINode node = VINode.Node1;
  String? _displayName;

  String? get displayName => _displayName;
  ConnectionClosed? onConnectionClosed;
  bool _logoutRequested = false;

  factory AuthService() {
    return _instance;
  }
  static final AuthService _instance = AuthService._();

  AuthService._() : _client = Voximplant().getClient() {
    _client.clientStateStream.listen((state) {
      if (kDebugMode) {
        debugPrint('AuthService: client state is changed: $state');
      }
      if (state == VIClientState.Disconnected && !_logoutRequested) {
        onConnectionClosed?.call();
      }
    });
  }

  Future<String?> loginWithPassword(String username, String password) async {
    if (kDebugMode) {
      debugPrint('AuthService: loginWithPassword');
    }
    // Connection to the Voximplant Cloud is stayed alive on reloading of the app's
    // Dart code. Calling "disconnect" API here makes the SDK and app states
    // synchronized.
    _logoutRequested = false;
    await _client.disconnect();
    await _client.connect(node: node);
    VIAuthResult authResult = await _client.login(username, password);
    await _saveAuthDetails(username, authResult.loginTokens);
    _displayName = authResult.displayName;
    return _displayName;
  }

  Future<String?> loginWithAccessToken() async {
    if (kDebugMode) {
      debugPrint('AuthService: loginWithAccessToken');
    }
    // Connection to the Voximplant Cloud is stayed alive on reloading of the app's
    // Dart code. Calling "disconnect" API here makes the SDK and app states
    // synchronized.
    _logoutRequested = false;
    await _client.disconnect();
    await _client.connect(node: node);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    VILoginTokens? loginTokens = _getAuthDetails(prefs);
    String? user = prefs.getString('username');
    if (user != null && loginTokens != null) {
      VIAuthResult authResult =
          await _client.loginWithAccessToken(user, loginTokens.accessToken);
      await _saveAuthDetails(user, authResult.loginTokens);
      _displayName = authResult.displayName;
    } else {
      throw Exception("Cannot log in with access token");
    }
    return _displayName;
  }

  Future<void> logout() async {
    _logoutRequested = true;
    _displayName = null;
    onConnectionClosed = null;
    await _clearAuthDetails();
    final state = await _client.getClientState();
    if (_shouldDisconnect(state)) {
      await _client.disconnect();
    }
  }

  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') != null &&
        _getAuthDetails(prefs) != null;
  }

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username')?.replaceAll('.voximplant.com', '');
  }

  bool _shouldDisconnect(VIClientState state) {
    return state != VIClientState.Disconnected;
  }

  Future<void> _clearAuthDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('accessExpire');
    await prefs.remove('refreshExpire');
  }

  Future<void> _saveAuthDetails(
      String username, VILoginTokens? loginTokens) async {
    if (loginTokens == null) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('accessToken', loginTokens.accessToken);
    prefs.setString('refreshToken', loginTokens.refreshToken);
    prefs.setInt('accessExpire', loginTokens.accessExpire);
    prefs.setInt('refreshExpire', loginTokens.refreshExpire);
  }

  VILoginTokens? _getAuthDetails(SharedPreferences prefs) {
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final refreshExpire = prefs.getInt('refreshExpire');
    final accessExpire = prefs.getInt('accessExpire');
    if (accessToken != null &&
        refreshToken != null &&
        refreshExpire != null &&
        accessExpire != null) {
      VILoginTokens loginTokens = VILoginTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          accessExpire: accessExpire,
          refreshExpire: refreshExpire);
      return loginTokens;
    }
    return null;
  }
}
