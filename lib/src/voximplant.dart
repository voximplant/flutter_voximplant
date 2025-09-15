// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../flutter_voximplant.dart';

/// Signature for callbacks reporting that there is a new log message
/// from Voximplant SDK
///
/// Used in [Voximplant].
///
/// `level` - Level of log message
///
/// `logMessage` - Log message
@Deprecated("Use Voximplant.configureFileLogger on Android platform")
typedef void VILogListener(
  VILogLevel level,
  String logMessage,
);

/// Entry point of the Voximplant Flutter SDK.
class Voximplant {
  factory Voximplant() => _instance;
  static final Voximplant _instance = Voximplant.private();

  VILogListener? logListener;

  /// Gets a [VIClient] instance to connect and login to the Voximplant cloud,
  /// make and receive calls.
  ///
  /// Optional `clientConfig` - Configuration for VIClient instance
  VIClient getClient([VIClientConfig? clientConfig]) =>
      _client ??= VIClient._(_channel, clientConfig ?? VIClientConfig());
  VIClient? _client;

  /// Gets a [VIMessenger] instance of messaging subsystem.
  VIMessenger get messenger => _messenger ??= VIMessenger._(_channel);
  VIMessenger? _messenger;

  /// Gets a [VIAudioDeviceManager] instance to control audio hardware settings.
  VIAudioDeviceManager get audioDeviceManager =>
      _audioDeviceManager ??= VIAudioDeviceManager._(_channel);
  VIAudioDeviceManager? _audioDeviceManager;

  /// Gets a [VICameraManager] instance to control camera hardware settings.
  VICameraManager get cameraManager =>
      _cameraManager ??= VICameraManager._(_channel);
  VICameraManager? _cameraManager;

  static const MethodChannel _channel =
      MethodChannel('plugins.voximplant.com/client');

  static const EventChannel _logsEventChannel =
      EventChannel('plugins.voximplant.com/logs');

  Voximplant.private() {
    if (Platform.isIOS) {
      _logsEventChannel.receiveBroadcastStream('logs')
          .listen(_logsEventListener);
    }
  }

  /// Configures the logger to write log messages to a file.
  ///
  /// `path` - File path.
  /// `fileName` - File name.
  /// `fileSizeLimit` - File size limit in bytes. When the limit is reached, the file is overwritten.
  ///
  /// Throws [VIException], if an error occurred on the Android platform,
  /// or [UnimplementedError] on the iOS platform.
  ///
  /// Errors:
  /// * [VILoggerError.ERROR_FILE_OPEN] - If the file cannot be created or opened in the specified path.
  /// * [VILoggerError.ERROR_SYSTEM_SECURITY] - If SecurityException is thrown on Android platform.
  /// * [VILoggerError.ERROR_INVALID_ARGUMENTS] - If [path] or [fileName]
  ///   is an empty string or [fileSizeLimit] is less than or equal to 0.
  Future<void> configureFileLogger({
    required String path,
    required String fileName,
    int fileSizeLimit = 2097152,
  }) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('Logger.configureFileLogger', {
          'path': path,
          'fileName': fileName,
          'fileSizeLimit': fileSizeLimit,
        });
      } on PlatformException catch (e) {
        throw VIException(e.code, e.message);
      }
    } else {
      throw UnimplementedError('File logging is not supported on iOS');
    }
  }

  void _logsEventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    if (map['event'] == 'onLogMessage') {
      final logLevelString = map['level'];
      final logLevel = VILogLevel.values.firstWhere(
        (logLevel) => logLevel.toString().split('.').last == logLevelString,
        orElse: () => VILogLevel.verbose,
      );
      final logMessage = map['logMessage'];
      logListener?.call(logLevel, logMessage);
    }
  }
}
