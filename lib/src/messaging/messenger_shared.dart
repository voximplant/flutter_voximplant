/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.

part of voximplant;

class _MessengerShared {
  static String _me;

  static void _saveMe(String me) =>
      _me = me == null ? null : me.replaceAll(".voximplant.com", "");
}
