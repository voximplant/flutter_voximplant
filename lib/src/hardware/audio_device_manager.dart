// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

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
  /// device selection
  ///
  /// This type should not be used with [VIAudioDeviceManager.selectAudioDevice]
  /// API.
  None
}

/// Signature for callbacks reporting that the active audio device or audio
/// device that is used for a further call is changed.
///
/// If the event is triggered during a call, [device] is the audio device that
/// is currently used.
///
/// If the event is triggered when there is no call, [device] is the audio device
/// that is used for the next call.
///
/// `audioManager` - VIAudioDeviceManager instance initiated the event
///
/// `device` - Audio device to be used
typedef void VIAudioDeviceChanged(
  VIAudioDeviceManager audioManager,
  VIAudioDevice device,
);

/// Signature for callbacks reporting that a new audio device is connected or
/// a previously connected audio device is disconnected.
///
/// For iOS: if the disconnected device has not been selected before via
/// [VIAudioDeviceManager.selectAudioDevice] API, this callback may be not
/// invoked.
///
/// `audioManager` - VIAudioDeviceManager instance initiated the event
///
/// `deviceList` - List of currently available audio devices.
typedef void VIAudioDeviceListChanged(
  VIAudioDeviceManager audioManager,
  List<VIAudioDevice> deviceList,
);

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
///   if a connection to the Voximplant cloud is active.
class VIAudioDeviceManager {
  final MethodChannel _channel;

  /// Callback for getting notified about active audio device changes.
  VIAudioDeviceChanged? onAudioDeviceChanged;

  /// Callback for getting notified about new connected or disconnected audio
  /// devices.
  VIAudioDeviceListChanged? onAudioDeviceListChanged;

  VIAudioDeviceManager._(this._channel) {
    EventChannel('plugins.voximplant.com/audio_device_events')
        .receiveBroadcastStream()
        .listen(_eventListener);
  }

  /// Changes selection of the current active audio device.
  ///
  /// Before a call. This API does not activate [audioDevice], it just selects
  /// the audio device that is to be activated.
  ///
  /// During a call. If the [audioDevice] is available, the API activates
  /// [audioDevice].
  ///
  /// Active audio device can be later changed if a new device is connected.
  /// In this case [VIAudioDeviceManager.onAudioDeviceChanged]
  /// is triggered.
  ///
  /// For iOS.
  /// If the application uses CallKit, you should take into consideration:
  /// * In case if Bluetooth headset is connected, audio routing depends on
  ///   where a call is answered (from the Bluetooth headset or from the phone
  ///   screen). Bluetooth hedset is activated only in case if a call
  ///   is answered via Bluetooth hedset controls. In other cases the audio is
  ///   played via Earpiece.
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

  /// Returns active audio device during the call or audio device that is
  /// used for a call if there is no call at this moment.
  ///
  /// Active audio device can be later changed if a new device is connected.
  /// In this case [VIAudioDeviceManager.onAudioDeviceChanged]
  /// is triggered.
  Future<VIAudioDevice> getActiveDevice() async {
    int? device =
        await _channel.invokeMethod<int>('AudioDevice.getActiveDevice');
    if (device == null) {
      _VILog._e('AudioDeviceManager: getActiveDevice: data was null, skipping');
      throw VIException(
        VIClientError.ERROR_INTERNAL,
        'AudioDeviceManager:getActiveDevice: data was null',
      );
    }
    VIAudioDevice audioDevice = VIAudioDevice.values[device];
    return audioDevice;
  }

  /// Returns the list of available audio devices.
  Future<List<VIAudioDevice>> getAudioDevices() async {
    List<int>? data =
        await _channel.invokeListMethod<int>('AudioDevice.getAudioDevices');
    if (data == null) {
      _VILog._e(
          'VIAudioDeviceManager: getAudioDevices: devices were null, skipping');
      throw VIException(
        VIClientError.ERROR_INTERNAL,
        'VIAudioDeviceManager:getAudioDevices: devices were null',
      );
    }
    List<VIAudioDevice> newAudioDevices = [];
    for (int device in data) {
      newAudioDevices.add(VIAudioDevice.values[device]);
    }
    return newAudioDevices;
  }

  //#region CallKit

  /// Initializes AVAudioSession for use with CallKit integration. iOS only.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise do not use this method.
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

  /// Restores default AVAudioSession initialization routines. iOS only.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise do not use this method.
  ///
  /// Should be called if CallKit becomes disabled.
  Future<void> callKitReleaseAudioSession() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitReleaseAudioSession');
    } else {
      _VILog._w('callKitReleaseAudioSession: invalid call for platform');
    }
  }

  /// Starts AVAudioSession. iOS only.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise do not use this method.
  ///
  /// Should be called in CXProviderDelegate.didActivateAudioSession.
  Future<void> callKitStartAudio() async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('AudioDevice.callKitStartAudioSession');
    } else {
      _VILog._w('callKitStartAudio: invalid call for platform');
    }
  }

  /// Stops AVAudioSession. iOS only.
  ///
  /// Required for the correct CallKIt integration only.
  /// Otherwise do not use this method.
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
        onAudioDeviceChanged?.call(this, device);
        break;
      case 'audioDeviceListChanged':
        List<int> devices = map['audioDeviceList']?.cast<int>() ?? [];
        List<VIAudioDevice> newAudioDevices = [];
        for (int device in devices) {
          newAudioDevices.add(VIAudioDevice.values[device]);
        }
        onAudioDeviceListChanged?.call(this, newAudioDevices);
        break;
    }
  }
}
