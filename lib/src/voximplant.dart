/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// The entry point of the Voximplant Flutter SDK.
class Voximplant {
  factory Voximplant() => _instance;
  static final Voximplant _instance = Voximplant.private();

  /// Get [VIClient] instance to connect and login to the Voximplant Cloud,
  /// make and receive calls
  ///
  /// Optional `clientConfig` - Configuration for VIClient instance
  VIClient getClient([VIClientConfig? clientConfig]) =>
      _client ??= VIClient._(_channel, clientConfig ?? VIClientConfig());
  VIClient? _client;

  /// Get [VIMessenger] instance of messaging subsystem
  VIMessenger get messenger => _messenger ??= VIMessenger._(_channel);
  VIMessenger? _messenger;

  /// Get [VIAudioDeviceManager] instance to control audio hardware settings
  VIAudioDeviceManager get audioDeviceManager =>
      _audioDeviceManager ??= VIAudioDeviceManager._(_channel);
  VIAudioDeviceManager? _audioDeviceManager;

  /// Get [VICameraManager] instance to control camera hardware settings
  VICameraManager get cameraManager =>
      _cameraManager ??= VICameraManager._(_channel);
  VICameraManager? _cameraManager;

  static const MethodChannel _channel =
      MethodChannel('plugins.voximplant.com/client');

  Voximplant.private();
}
