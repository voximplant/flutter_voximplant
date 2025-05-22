// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

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

/// Configuration information for a [VIClient] instance.
class VIClientConfig {
  /// Application bundle id.
  ///
  /// Set this only if you are going to send push notification across
  /// several Android or several iOS apps within a single Voximplant application.
  String? bundleId;

  /// Whether to enable debug logging on Android. The default value is false.
  bool enableDebugLogging;

  /// Whether to enables log output to logcat on Android. The default value is true.
  bool enableLogcatLogging;

  /// Specifies when the audio focus request is performed: when a call is started
  /// or established.
  ///
  /// The default value is [VIRequestAudioFocusMode.onCallStart].
  ///
  /// If the application plays some audio, it may result in audio interruptions.
  /// To avoid this behavior, this option should be set to
  /// [VIRequestAudioFocusMode.onCallConnected] and application's audio should
  /// be stopped/paused on [VICallAudioStarted] callback.
  VIRequestAudioFocusMode audioFocusMode;

  /// Specifies the log level on iOS.
  VILogLevel logLevel;

  /// Whether to force traffic to go through TURN servers. The default value is false.
  bool forceRelayTraffic;

  VIClientConfig({
    this.bundleId,
    this.enableDebugLogging = false,
    this.enableLogcatLogging = true,
    this.audioFocusMode = VIRequestAudioFocusMode.onCallStart,
    this.logLevel = VILogLevel.info,
    this.forceRelayTraffic = false,
  });
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

  VILoginTokens({
    required this.accessExpire,
    required this.accessToken,
    required this.refreshExpire,
    required this.refreshToken,
  });
}

/// Represents the result of successful login.
class VIAuthResult {
  /// Display name of the logged in user.
  final String displayName;

  /// Authentication parameters that may be used for login with access token.
  final VILoginTokens? loginTokens;

  VIAuthResult._(this.displayName, [this.loginTokens]);
}

/// Represents client states.
enum VIClientState {
  /// Client is currently disconnected.
  Disconnected,

  /// Client is currently connecting.
  Connecting,

  /// Client is currently reconnecting.
  Reconnecting,

  /// Client is currently connected.
  Connected,

  /// Client is currently logging in.
  LoggingIn,

  /// Client is currently logged in.
  LoggedIn,
}

/// Nodes the Voximplant account may belong to.
enum VINode {
  Node1,
  Node2,
  Node3,
  Node4,
  Node5,
  Node6,
  Node7,
  Node8,
  Node9,
  Node10,
  Node11,
}
