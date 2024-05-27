// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../flutter_voximplant.dart';

class _VILog {
  static void _e(String message) {
    _log(_error, message);
  }

  static void _w(String message) {
    _log(_warning, message);
  }

  static void _i(String message) {
    _log(_info, message);
  }

  static const String _prefix = "VOXFLUTTER";
  static const String _error = "Error";
  static const String _warning = "Warning";
  static const String _info = "Info";

  static void _log(String level, String message) {
    print('$_prefix:$level > $message');
  }
}
