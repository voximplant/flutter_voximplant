# flutter_voximplant

Voximplant Flutter SDK for embedding voice communication into Flutter applications.

## Demo
https://github.com/voximplant/flutter_demos

## Install
Add `flutter_voximplant` as a dependency in your pubspec.yaml file.

### iOS

Add the following entry to your `Info.plist` file, located in `<project root>/ios/Runner/Info.plist`:
```
<key>NSMicrophoneUsageDescription</key>
<string>Microphone is required to make audio calls</string>
```
This entry allows your app to access the microphone.

### Android
It is required to add Java 8 support.

Open `<project root>android/app/build.gradle` file and add the following lines to ‘android’ section:
```
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```

## Usage

To get started, you'll need to [register](https://voximplant.com) a free Voximplant developer account.

#### Initialization
Client is the main class of the SDK that provides access to Voximplant’s functions, 
the `Voximplant().getClient()` method is used to get its instance:
```dart
import 'package:flutter_voximplant/flutter_voximplant.dart';


Client client = Voximplant().getClient();
```

#### Connect and log in to the Voximplant Cloud
The `Client.getClientState()` method is used to get the current state of connection 
to the Voximplant cloud and perform the actions according to it.
```dart
  Future<String> loginWithPassword(String username, String password) async {
    ClientState clientState = await _client.getClientState();
    if (clientState == ClientState.LoggedIn) {
      return _displayName;
    }
    if (clientState == ClientState.Disconnected) {
      await _client.connect();
    }
    AuthResult authResult = await _client.login(username, password);
    _displayName = authResult.displayName;
    return _displayName;
  }
```

#### Make calls
To initiate a call we need the `Client.call` method. 
There is a `CallSettings` class which could contain custom data and extra headers (SIP headers).

Since the call can behave in different ways, there is a group of call events. 
They can be triggered by the `Call` class instance as the class contains all the functionality for call management.

```dart
  Future<Call> makeAudioCall(String number) async {
     Call call = await _client.call(number);
     call.onCallDisconnected = _onCallDisconnected;
     call.onCallFailed = _onCallFailed;
     call.onCallConnected = _onCallConnected;
     call.onCallRinging = _onCallRinging;
     call.onCallAudioStarted = _onCallAudioStarted;
     return call;
  }
   
  _onCallConnected(Map<String, String> headers) {
      print('Call connected');
  }
```

#### Receiving calls
`Client.onIncomingCall` is used to get incoming calls. 

There are three methods for an incoming call: answer, decline and reject. An audio stream can be sent only after the answer method call.
```dart
  CallService._() {
    _client = Voximplant().getClient();
    _client.onIncomingCall = _onIncomingCall;
  }

  _onIncomingCall(Call call, Map<String, String> headers) async {
    await call.answer();
  }
```

#### Mid-call operations
Audio call can be put on/off hold
```dart
  _hold() async {
    try {
      await _call.hold(!_isOnHold);
      setState(() {
        _isOnHold = !_isOnHold;
      });
    } catch (e) {
      
    }

  }
```

#### Audio device management
`AudioDeviceManager` class API allow to:
- get all available audio devices
- get currently selected audio device
- select audio device
- handle active audio device changes and new audio devices (for example, Bluetooth headset or wired headset connection). These changes trigger the appropriate events.

All types of audio devices are represented in the `AudioDevice` enum.

Note that there are platform specific nuances in audio device management.

To select an audio device:
```dart
  _selectAudioDevice(AudioDevice device) async{
    AudioDeviceManager audioDeviceManager = Voximplant().getAudioDeviceManager();
    audioDeviceManager.onAudioDeviceChanged = _onAudioDeviceChange;
    await audioDeviceManager.selectAudioDevice(device);
  }

  _onAudioDeviceChange(AudioDevice audioDevice) {
    // audio device is changed
  }
```
