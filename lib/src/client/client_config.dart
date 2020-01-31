/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Request audio focus mode for Android.
///
/// Used in [VIClientConfig].
enum VIRequestAudioFocusMode {
  /// Request of audio focus is performed when a call is established.
  onCallStart,
  /// Request of audio focus is performed when a call is started.
  onCallConnected,
}

/// Log levels for iOS.
///
/// Used in [VIClientConfig].
enum VILogLevel {
  /// Include only error messages.
  error,
  /// Include only error and warning messages.
  warning,
  /// Include error, warning, and info messages.
  info,
  /// Include error, warning, info, and debug messages.
  debug,
  /// Include all log messages.
  verbose
}

/// Configuration information for [VIClient] instance.
class VIClientConfig {
  /// Application bundle id.
  ///
  /// You need to set this only if you are going to send push notification across
  /// several Android or several iOS apps using a single Voximplant application.
  String bundleId;

  /// Enables debug logging on Android. False by default.
  bool enableDebugLogging;

  /// Enables log output to logcat on Android. True by default.
  bool enableLogcatLogging;

  /// Specifies when the audio focus request is performed: when a call is started
  /// or established.
  ///
  /// [VIRequestAudioFocusMode.onCallStart] by default.
  ///
  /// If the application plays some audio, it may result in audio interruptions.
  /// To avoid this behavior, this option should be set to
  /// [VIRequestAudioFocusMode.onCallConnected] and application's audio should
  /// be stopped/paused on [VICallAudioStarted] callback.
  VIRequestAudioFocusMode audioFocusMode;

  /// Specifies log level on iOS.
  VILogLevel logLevel;

  VIClientConfig() {
    bundleId = null;
    enableDebugLogging = false;
    enableLogcatLogging = true;
    audioFocusMode = VIRequestAudioFocusMode.onCallStart;
    logLevel = VILogLevel.info;
  }
}

/// Authentication parameters that may be used for login with access token.
class VILoginTokens {
  /// Time in seconds to access token expire.
  int accessExpire;
  /// Access token.
  String accessToken;
  /// Time in seconds to refresh token expire.
  int refreshExpire;
  /// Refresh token.
  String refreshToken;
}

/// Represents the result of successful login.
class VIAuthResult {
  /// Display name of the logged in user.
  String displayName;
  /// Authentication parameters that may be used for login with access token.
  VILoginTokens loginTokens;

  VIAuthResult._(this.displayName, this.loginTokens);
}

/// Represents client states.
enum VIClientState {
  /// The client is currently disconnected.
  Disconnected,
  /// The client is currently connecting.
  Connecting,
  /// The client is currently connected.
  Connected,
  /// The client is currently logging in.
  LoggingIn,
  /// The client is currently logged in.
  LoggedIn,
}
