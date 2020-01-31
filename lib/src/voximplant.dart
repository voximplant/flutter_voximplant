/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// The entry point of the Voximplant Flutter SDK.
class Voximplant {
  factory Voximplant() => _instance;
  Voximplant.private();

  static final Voximplant _instance = Voximplant.private();
  VIClient _client;
  VIAudioDeviceManager _audioDeviceManager;
  VICameraManager _cameraManager;
  static const MethodChannel _channel =
      MethodChannel('plugins.voximplant.com/client');

  /// Get [VIClient] instance to connect and login to the Voximplant Cloud,
  /// make and receive calls
  VIClient getClient([VIClientConfig clientConfig]) {
    if (_client == null) {
      if (clientConfig == null) {
        clientConfig = VIClientConfig();
      }
      _client = VIClient._(_channel, clientConfig);
    }
    return _client;
  }

  /// Get [VIAudioDeviceManager] instance to control audio hardware settings
  VIAudioDeviceManager getAudioDeviceManager() {
    if (_audioDeviceManager == null) {
      _audioDeviceManager = VIAudioDeviceManager._(_channel);
    }
    return _audioDeviceManager;
  }

  /// Get [VICameraManager] instance to control camera hardware settings
  VICameraManager getCameraManager() {
    if (_cameraManager == null) {
      _cameraManager = VICameraManager._(_channel);
    }
    return _cameraManager;
  }
}
