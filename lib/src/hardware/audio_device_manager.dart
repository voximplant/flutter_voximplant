/// Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.

part of voximplant;

enum AudioDevice {
  Bluetooth,
  Earpiece,
  Speaker,
  WiredHeadset,
  None
}

typedef void AudioDeviceChanged(AudioDevice device);
typedef void AudioDeviceListChanged(List<AudioDevice> deviceList);

class AudioDeviceManager {
  final MethodChannel _channel;

  AudioDeviceChanged onAudioDeviceChanged;
  AudioDeviceListChanged onAudioDeviceListChanged;

  AudioDeviceManager._(this._channel) {
    EventChannel('plugins.voximplant.com/audio_device_events')
        .receiveBroadcastStream()
        .listen(_eventListener);
  }

  Future<void> selectAudioDevice(AudioDevice audioDevice) async {
    await _channel.invokeMethod<void>('selectAudioDevice', <String, dynamic> {
      'audioDevice': audioDevice.index,
    });
  }

  Future<AudioDevice> getActiveDevice() async {
    Map<String, dynamic> data = await _channel.invokeMapMethod('getActiveDevice');
    AudioDevice audioDevice = AudioDevice.values[data['audioDevice']];
    return audioDevice;
  }

  Future<List<AudioDevice>> getAudioDevices() async {
    List<int> data = await _channel.invokeListMethod('getAudioDevices');
    List<AudioDevice> newAudioDevices = List();
    for(int device in data) {
      newAudioDevices.add(AudioDevice.values[device]);
    }
    return newAudioDevices;
  }

  void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'audioDeviceChanged':
        AudioDevice device = AudioDevice.values[map['audioDevice']];
        if (onAudioDeviceChanged != null) {
          onAudioDeviceChanged(device);
        }
        break;
      case 'audioDeviceListChanged':
        List<int> devices = map['audioDeviceList'].cast<int>();
        List<AudioDevice> newAudioDevices = List();
        for(int device in devices) {
          newAudioDevices.add(AudioDevice.values[device]);
        }
        if (onAudioDeviceListChanged != null) {
          onAudioDeviceListChanged(newAudioDevices);
        }
        break;
    }
  }

}
