// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:audio_call/screens/main_screen.dart';
import 'package:audio_call/services/call_service.dart';
import 'package:audio_call/theme/voximplant_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';

class CallScreen extends StatefulWidget {
  static const routeName = '/callScreen';
  final VICall call;

  const CallScreen({super.key, required this.call});

  @override
  State<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  String? _endpointName;
  String _callStatus = 'Connecting...';
  bool _isAudioMuted = false;
  bool _isOnHold = false;
  late final VICall _call;
  IconData _audioDeviceIcon = Icons.hearing;
  final VIAudioDeviceManager _audioDeviceManager =
      Voximplant().audioDeviceManager;

  @override
  void initState() {
    super.initState();
    _call = widget.call;
    _audioDeviceManager.onAudioDeviceChanged = _onAudioDeviceChange;
    _call.onCallDisconnected = _onCallDisconnected;
    _call.onCallFailed = _onCallFailed;
    _call.onCallConnected = _onCallConnected;
    _call.onCallRinging = _onCallRinging;
    _call.onEndpointAdded = _onEndpointAdded;
    _call.onCallReconnecting = _onReconnecting;
    _call.onCallReconnected = _onReconnected;
    if (_call.endpoints.isNotEmpty) {
      _endpointName = _call.endpoints.first.userName ?? 'Unknown';
    }
    if (kDebugMode) {
      debugPrint('CallScreen: received callId: ${_call.callId}');
    }
  }

  void _onAudioDeviceChange(
      VIAudioDeviceManager audioManager, VIAudioDevice audioDevice) {
    setState(() {
      switch (audioDevice) {
        case VIAudioDevice.Bluetooth:
          _audioDeviceIcon = Icons.bluetooth_audio;
          break;
        case VIAudioDevice.Earpiece:
          _audioDeviceIcon = Icons.hearing;
          break;
        case VIAudioDevice.Speaker:
          _audioDeviceIcon = Icons.volume_up;
          break;
        case VIAudioDevice.WiredHeadset:
          _audioDeviceIcon = Icons.headset;
          break;
        case VIAudioDevice.None:
          break;
      }
    });
  }

  void _onCallDisconnected(
      VICall call, Map<String, String>? headers, bool answeredElsewhere) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallDisconnected');
    }
    CallService().notifyCallIsEnded(_call.callId);
    Navigator.pushReplacementNamed(context, MainScreen.routeName);
  }

  void _onCallFailed(
      VICall call, int code, String description, Map<String, String>? headers) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallFailed');
    }
    CallService().notifyCallIsEnded(_call.callId);
    Navigator.pushReplacementNamed(context, MainScreen.routeName);
  }

  void _onCallConnected(VICall call, Map<String, String>? headers) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallConnected');
    }
    setState(() {
      _callStatus = 'Call in progress';
      if (_call.endpoints.isNotEmpty) {
        _endpointName = _call.endpoints.first.userName ?? 'Unknown';
      }
    });
  }

  void _onReconnecting(VICall call) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallReconnecting');
    }
    setState(() {
      _callStatus = 'Reconnecting...';
    });
  }

  void _onReconnected(VICall call) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallReconnected');
    }
    setState(() {
      _callStatus = 'Call in progress';
    });
  }

  void _onCallRinging(VICall call, Map<String, String>? headers) {
    if (kDebugMode) {
      debugPrint('CallScreen: onCallRinging');
    }
    setState(() {
      _callStatus = 'Ringing...';
    });
  }

  void _onEndpointAdded(VICall call, VIEndpoint endpoint) {
    if (kDebugMode) {
      debugPrint('CallScreen: onEndpointAdded');
    }
    endpoint.onEndpointUpdated = _onEndpointUpdated;
    setState(() {
      _endpointName = endpoint.userName ?? 'Unknown';
    });
  }

  void _onEndpointUpdated(VIEndpoint endpoint) {
    if (kDebugMode) {
      debugPrint('CallScreen: onEndpointUpdated');
    }
    setState(() {
      _endpointName = endpoint.userName;
    });
  }

  Future<void> _muteAudio() async {
    try {
      await _call.sendAudio(_isAudioMuted);
      setState(() {
        _isAudioMuted = !_isAudioMuted;
      });
    } catch (e) {
      //TODO: show error
    }
  }

  Future<void> _hold() async {
    try {
      await _call.hold(!_isOnHold);
      setState(() {
        _isOnHold = !_isOnHold;
      });
    } catch (e) {
      //TODO: show error
    }
  }

  Future<void> _selectAudioDevice(VIAudioDevice device) async {
    await _audioDeviceManager.selectAudioDevice(device);
  }

  Future<void> _showAvailableAudioDevices() async {
    List<VIAudioDevice> availableAudioDevices =
        await _audioDeviceManager.getAudioDevices();
    if (!mounted) {
      return;
    }
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select audio device'),
            content: SingleChildScrollView(
                child: SizedBox(
              width: 100,
              height: 100,
              child: ListView.builder(
                  itemCount: availableAudioDevices.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return TextButton(
                      child: Text(
                        availableAudioDevices[index].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        _selectAudioDevice(availableAudioDevices[index]);
                      },
                    );
                  }),
            )),
          );
        });
  }

  Future<void> _hangup() async {
    await _call.hangup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Text(
                    '$_endpointName',
                    style: TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  Text(
                    _callStatus,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: VoximplantColors.white,
                            shape: CircleBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: VoximplantColors.button,
                                    style: BorderStyle.solid)),
                          ),
                          child: IconButton(
                            onPressed: _muteAudio,
                            iconSize: 40,
                            icon: Icon(
                                _isAudioMuted ? Icons.mic_off : Icons.mic,
                                color: VoximplantColors.button),
                            tooltip: 'Mute',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, right: 20, left: 20),
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: VoximplantColors.white,
                            shape: CircleBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: VoximplantColors.button,
                                    style: BorderStyle.solid)),
                          ),
                          child: IconButton(
                            onPressed: _hold,
                            iconSize: 40,
                            icon: Icon(
                                _isOnHold ? Icons.play_arrow : Icons.pause,
                                color: VoximplantColors.button),
                            tooltip: 'Hold',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: VoximplantColors.white,
                            shape: CircleBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: VoximplantColors.button,
                                    style: BorderStyle.solid)),
                          ),
                          child: IconButton(
                            onPressed: _showAvailableAudioDevices,
                            iconSize: 40,
                            icon: Icon(_audioDeviceIcon,
                                color: VoximplantColors.button),
                            tooltip: 'Select audio device',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Ink(
                  decoration: ShapeDecoration(
                    color: VoximplantColors.white,
                    shape: CircleBorder(
                        side: BorderSide(
                            width: 2,
                            color: VoximplantColors.red,
                            style: BorderStyle.solid)),
                  ),
                  child: IconButton(
                    onPressed: _hangup,
                    iconSize: 40,
                    icon: Icon(
                      Icons.call_end,
                      color: VoximplantColors.red,
                    ),
                    tooltip: 'Hang up',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
