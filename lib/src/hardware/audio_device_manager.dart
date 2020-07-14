/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

/// Represents supported audio device types.
enum VIAudioDevice {
  /// Bluetooth headset
  Bluetooth,

  /// Earpiece
  Earpiece,

  /// Speaker
  Speaker,

  /// Wired headset
  WiredHeadset,

  /// No audio device, generally indicates that something went wrong with audio
  /// device selection.
  ///
  /// This type should not be used with [VIAudioDeviceManager.selectAudioDevice]
  /// API.
  None
}

/// Signature for callbacks reporting that the active audio device or audio
/// device that will be used for a further call is changed.
///
/// If the event is triggered during a call, [device] is the audio device that
/// is currently used.
///
/// If the event is triggered when there is no call, [device] is the audio device
/// that will be used for the next call.
///
/// `audioManager` - VIAudioDeviceManager instance initiated the event
///
/// `device` - Audio device to be used
typedef void VIAudioDeviceChanged(
    VIAudioDeviceManager audioManager, VIAudioDevice device);

/// Signature for callbacks reporting that a new audio device is connected or
/// a previously connected audio device is disconnected.
///
/// For iOS: if the disconnected device was not selected before via
/// [VIAudioDeviceManager.selectAudioDevice] API, this callback may be not
/// invoked.
///
/// `audioManager` - VIAudioDeviceManager instance initiated the event
///
/// `deviceList` - List of currently available audio devices.
typedef void VIAudioDeviceListChanged(
    VIAudioDeviceManager audioManager, List<VIAudioDevice> deviceList);

/// Manages audio devices.
///
/// Limitations:
/// * It is not possible to select an [VIAudioDevice.Earpiece] while
///   wired headset is connected.
///
/// Limitations for iOS:
/// * Wired headsets without a microphone may be recognized and selected as
///   [VIAudioDevice.Earpiece].
/// * iOS 12 and AirPods: during an active call, [VIAudioDevice.Earpiece] or
///   [VIAudioDevice.Speaker] selection may fail if AirPods are used as current
///   active device.
///
/// Limitations for Android:
/// * The plug in/out of a wired headset and bluetooth devices is monitored only
///   if a connection to the Voximplant Cloud is active.
class VIAudioDeviceManager {
  final MethodChannel _channel;

  /// Callback for getting notified about active audio device changes.
  VIAudioDeviceChanged onAudioDeviceChanged;

  /// Callback for getting notified about new connected or disconnected audio
  /// devices.
  VIAudioDeviceListChanged onAudioDeviceListChanged;

  VIAudioDeviceManager._(this._channel) {
    EventChannel('plugins.voximplant.com/audio_device_events')
        .receiveBroadcastStream()
        .listen(_eventListener);
  }

  /// Changes selection of the current active audio device.
  ///
  /// Before a call. This API does nit activate [audioDevice], it just selects
  /// the audio device that will be activated.
  ///
  /// During a call. If the [audioDevice] is available, the API activates
  /// [audioDevice].
  ///
  /// Active audio device can be later changed if a new device is connected.
  /// In this case [onAudioDeviceChanged] will be triggered.
  ///
  /// For iOS.
  /// If the application uses CallKit, you should take into consideration:
  /// * In case if Bluetooth headset is connected, audio routing depends on
  ///   where a call is answered (from the Bluetooth headset or from the phone
  ///   screen). Bluetooth hedset will be activated only in case if a call
  ///   is answered via Bluetooth hedset controls. In other cases the audio will
  ///   be played via Earpiece.
  /// * Audio is always routed to Bluetooth headset only if the user selects
  ///   "Bluetooth headset" as Call Audio Routing in the phone preferences.
  /// * If audio device is selected before CallKit activates the audio session,
  ///   it is required to reselect this audio device after
  ///   CXProviderDelegate.didActivateAudioSession is called. Otherwise audio
  ///   routing may be reset to default.
  ///
  /// `audioDevice` - Audio device to be set active
  Future<void> selectAudioDevice(VIAudioDevice audioDevice) async {
    await _channel
        .invokeMethod<void>('AudioDevice.selectAudioDevice', <String, dynamic>{
      'audioDevice': audioDevice.index,
    });
  }

  /// Returns active audio device during the call or audio device that will be
  /// used for a call if there is no call at this moment.
  ///
  /// Active audio device can be later changed if a new device is connected.
  /// In this case [onAudioDeviceChanged] will be triggered.
  Future<VIAudioDevice> getActiveDevice() async {
    Map<String, dynamic> data =
        await _channel.invokeMapMethod('AudioDevice.getActiveDevice');
    VIAudioDevice audioDevice = VIAudioDevice.values[data['audioDevice']];
    return audioDevice;
  }

  /// Returns the list of available audio devices.
  Future<List<VIAudioDevice>> getAudioDevices() async {
    List<int> data =
        await _channel.invokeListMethod('AudioDevice.getAudioDevices');
    List<VIAudioDevice> newAudioDevices = List();
    for (int device in data) {
      newAudioDevices.add(VIAudioDevice.values[device]);
    }
    return newAudioDevices;
  }

  //#region CallKit

  /// iOS only. Initializes AVAudioSession for use with CallKit integration.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise don't use this method.
  ///
  /// Should be called in CXProviderDelegate.performStartCallAction and
  /// CXProviderDelegate.performAnswerCallAction.
  Future<void> callKitConfigureAudioSession() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitConfigureAudioSession');
    } else {
      _VILog._w('callKitConfigureAudioSession: invalid call for platform');
    }
  }

  /// iOS only. Restores default AVAudioSession initialization routines.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise don't use this method.
  ///
  /// Must be called if CallKit becomes disabled.
  Future<void> callKitReleaseAudioSession() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitReleaseAudioSession');
    } else {
      _VILog._w('callKitReleaseAudioSession: invalid call for platform');
    }
  }

  /// iOS only. Starts AVAudioSession.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise don't use this method.
  ///
  /// Should be called in CXProviderDelegate.didActivateAudioSession.
  Future<void> callKitStartAudio() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitStartAudioSession');
    } else {
      _VILog._w('callKitStartAudio: invalid call for platform');
    }
  }

  /// iOS only. Stops AVAudioSession.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise don't use this method.
  ///
  /// Should be called in CXProviderDelegate.didDeactivateAudioSession.
  Future<void> callKitStopAudio() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitStopAudio');
    } else {
      _VILog._w('callKitStopAudio: invalid call for platform');
    }
  }

  //#endregion

  void _eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'audioDeviceChanged':
        VIAudioDevice device = VIAudioDevice.values[map['audioDevice']];
        if (onAudioDeviceChanged != null) {
          onAudioDeviceChanged(this, device);
        }
        break;
      case 'audioDeviceListChanged':
        List<int> devices = map['audioDeviceList'].cast<int>();
        List<VIAudioDevice> newAudioDevices = List();
        for (int device in devices) {
          newAudioDevices.add(VIAudioDevice.values[device]);
        }
        if (onAudioDeviceListChanged != null) {
          onAudioDeviceListChanged(this, newAudioDevices);
        }
        break;
    }
  }
}
