/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

/// android only
enum RequestAudioFocusMode {
  onCallStart,
  onCallConnected,
}

/// ios only
enum LogLevel {
  error,
  warning,
  info,
  debug,
  verbose
}


class ClientConfig {
  /// android and ios
  String bundleId;

  /// android only
  bool enableDebugLogging;

  ///android only
  bool enableLogcatLogging;

  ///android only
  RequestAudioFocusMode audioFocusMode;

  /// ios only
  LogLevel logLevel;

  ClientConfig() {
    bundleId = null;
    enableDebugLogging = false;
    enableLogcatLogging = true;
    audioFocusMode = RequestAudioFocusMode.onCallStart;
    logLevel = LogLevel.info;
  }
}
