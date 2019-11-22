/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

class Voximplant {
  factory Voximplant() => _instance;
  Voximplant.private();

  static final Voximplant _instance = Voximplant.private();
  Client _client;
  AudioDeviceManager _audioDeviceManager;
  static const MethodChannel _channel =
      MethodChannel('plugins.voximplant.com/client');

  Client getClient([ClientConfig clientConfig]) {
    if (_client == null) {
      if (clientConfig == null) {
        clientConfig = ClientConfig();
      }
      _client = Client._(_channel, clientConfig);
    }
    return _client;
  }

  AudioDeviceManager getAudioDeviceManager() {
    if (_audioDeviceManager == null) {
      _audioDeviceManager = AudioDeviceManager._(_channel);
    }
    return _audioDeviceManager;
  }
}
