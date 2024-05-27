// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of '../../flutter_voximplant.dart';

class _MessengerShared {
  static String? _me;

  static void _saveMe(String? me) =>
      _me = me?.replaceAll(".voximplant.com", "");
}
