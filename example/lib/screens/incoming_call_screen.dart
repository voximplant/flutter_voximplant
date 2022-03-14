/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

import 'dart:io';

import 'package:audio_call/screens/call_screen.dart';
import 'package:audio_call/screens/main_screen.dart';
import 'package:audio_call/services/call_service.dart';
import 'package:audio_call/services/navigation_service.dart';
import 'package:audio_call/theme/voximplant_theme.dart';
import 'package:audio_call/utils/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class IncomingCallScreen extends StatelessWidget {
  static const routeName = '/incomingCall';
  final VICall call;

  IncomingCallScreen({Key key, @required this.call}) : super(key: key) {
    call.onCallDisconnected = _onCallDisconnected;
  }

  _onCallDisconnected(
      VICall call, Map<String, String> headers, bool answeredElsewhere) {
    CallService().notifyCallIsEnded(call.callId);
    GetIt locator = GetIt.instance;
    locator<NavigationService>().navigateTo(MainScreen.routeName);
  }

  _answerCall(BuildContext context) async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.microphone.status;
      if (permission != PermissionStatus.granted) {
        Map<Permission, PermissionStatus> result =
            await ([Permission.microphone]).request();
        if (result[Permission.microphone] != PermissionStatus.granted) {
          return;
        }
      }
    }
    await call.answer();
    Navigator.pushReplacementNamed(context, CallScreen.routeName,
        arguments: CallArguments(call));
  }

  _declineCall(BuildContext context) async {
    await call.decline();
    Navigator.pushReplacementNamed(context, MainScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Incoming call from ',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                '${call.endpoints.first.displayName}',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
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
                        onPressed: () {
                          _answerCall(context);
                        },
                        iconSize: 40,
                        icon: Icon(Icons.call, color: VoximplantColors.button),
                        tooltip: 'Answer',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
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
                        onPressed: () {
                          _declineCall(context);
                        },
                        iconSize: 40,
                        icon: Icon(Icons.call_end, color: VoximplantColors.red),
                        tooltip: 'Decline',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
