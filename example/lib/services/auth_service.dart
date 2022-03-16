/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef void ConnectionClosed();

class AuthService {
  VIClient _client;
  String _displayName;

  String get displayName => _displayName;
  ConnectionClosed onConnectionClosed;

  static final AuthService _singleton = AuthService._();
  factory AuthService() {
    return _singleton;
  }

  AuthService._() {
    _client = Voximplant().getClient();
    _client.clientStateStream.listen((state) {
      print('AuthService: client state is changed: $state');
      if (state == VIClientState.Disconnected && onConnectionClosed != null) {
        onConnectionClosed();
      }
    });
  }

  Future<String> loginWithPassword(String username, String password) async {
    print('AuthService: loginWithPassword');
    await _client.disconnect();
    await _client.connect();
    VIAuthResult authResult = await _client.login(username, password);
    await _saveAuthDetails(username, authResult.loginTokens);
    _displayName = authResult.displayName;
    return _displayName;
  }

  Future<String> loginWithAccessToken([String username]) async {
    print('AuthService: loginWithAccessToken');
    await _client.disconnect();
    await _client.connect();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    VILoginTokens loginTokens = _getAuthDetails(prefs);
    String user = username ?? prefs.getString('username');

    VIAuthResult authResult =
        await _client.loginWithAccessToken(user, loginTokens.accessToken);
    await _saveAuthDetails(user, authResult.loginTokens);
    _displayName = authResult.displayName;
    return _displayName;
  }

  Future<void> logout() async {
    return await _client.disconnect();
  }

  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username')?.replaceAll('.voximplant.com', '');
  }

  Future<void> _saveAuthDetails(
      String username, VILoginTokens loginTokens) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('accessToken', loginTokens.accessToken);
    prefs.setString('refreshToken', loginTokens.refreshToken);
    prefs.setInt('accessExpire', loginTokens.accessExpire);
    prefs.setInt('refreshExpire', loginTokens.refreshExpire);
  }

  VILoginTokens _getAuthDetails(SharedPreferences prefs) => VILoginTokens(
        accessToken: prefs.getString('accessToken'),
        accessExpire: prefs.getInt('accessExpire'),
        refreshToken: prefs.getString('refreshToken'),
        refreshExpire: prefs.getInt('refreshExpire'),
      );
}
