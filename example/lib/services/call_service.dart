// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'package:audio_call/screens/incoming_call_screen.dart';
import 'package:audio_call/services/navigation_service.dart';
import 'package:audio_call/utils/screen_arguments.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:get_it/get_it.dart';

class CallService {
  final VIClient _client = Voximplant().getClient();
  VICall? _call;

  static final CallService _singleton = CallService._();
  factory CallService() {
    return _singleton;
  }

  CallService._() {
    _client.onIncomingCall = _onIncomingCall;
  }

  void notifyCallIsEnded(String callId) {
    if (_call?.callId == callId) {
      _call = null;
    }
  }

  Future<VICall> makeAudioCall(String number) async {
    final call = await _client.call(number);
    _call = call;
    print('CallService: created call: ${_call?.callId}');
    return call;
  }

  _onIncomingCall(VIClient client, VICall call, bool video,
      Map<String, String>? headers) async {
    if (_call != null) {
      await call.decline();
      return;
    }
    _call = call;
    GetIt locator = GetIt.instance;
    locator<NavigationService>().navigateTo(IncomingCallScreen.routeName,
        arguments: CallArguments(call));
  }
}
