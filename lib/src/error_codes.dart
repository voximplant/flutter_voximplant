

part of voximplant;

class VIException implements Exception {
  final String code;
  final String message;

  VIException(this.code, this.message);

  @override
  String toString() => '$runtimeType($code, $message)';
}

class VIClientError {
  static const String ERROR_ACCOUNT_FROZEN = 'ERROR_ACCOUNT_FROZEN';
  static const String ERROR_INTERNAL = 'ERROR_INTERNAL';
  static const String ERROR_INVALID_PASSWORD = 'ERROR_INVALID_PASSWORD';
  static const String ERROR_INVALID_STATE = 'ERROR_INVALID_STATE';
  static const String ERROR_INVALID_USERNAME = 'ERROR_INVALID_USERNAME';
  static const String ERROR_NETWORK_ISSUES = 'ERROR_NETWORK_ISSUES';
  static const String ERROR_TIMEOUT = 'ERROR_TIMEOUT';
  static const String ERROR_TOKEN_EXPIRED = 'ERROR_TOKEN_EXPIRED';
  static const String ERROR_CONNECTION_FAILED = 'ERROR_CONNECTION_FAILED';
  static const String ERROR_INVALID_ARGUMENTS = 'ERROR_INVALID_ARGUMENTS';
}

class VICallError {
  static const String ERROR_CLIENT_NOT_LOGGED_IN = 'ERROR_CLIENT_NOT_LOGGED_IN';
  static const String ERROR_REJECTED = 'ERROR_REJECTED';
  static const String ERROR_TIMEOUT = 'ERROR_TIMEOUT';
  static const String ERROR_MEDIA_IS_ON_HOLD = 'ERROR_MEDIA_IS_ON_HOLD';
  static const String ERROR_ALREADY_IN_THIS_STATE = 'ERROR_ALREADY_IN_THIS_STATE';
  static const String ERROR_INCORRECT_OPERATION = 'ERROR_INCORRECT_OPERATION';
  static const String ERROR_INTERNAL = 'ERROR_INTERNAL';
  static const String ERROR_MISSING_PERMISSION = 'ERROR_MISSING_PERMISSION';
  static const String ERROR_INVALID_ARGUMENTS = 'ERROR_INVALID_ARGUMENTS';
}

