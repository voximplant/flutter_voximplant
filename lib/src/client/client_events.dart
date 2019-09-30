/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

class LoginTokens {
  int accessExpire;
  String accessToken;
  int refreshExpire;
  String refreshToken;
}

class ConnectionFailed {
  String message;

  ConnectionFailed._(this.message);
}

class AuthResult {
  String displayName;
  LoginTokens loginTokens;

  AuthResult._(this.displayName, this.loginTokens);
}
