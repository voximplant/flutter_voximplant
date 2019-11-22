part of voximplant;

class Log {
  static void e(String message) {
    _log(_error, message);
  }

  static void w(String message) {
    _log(_warning, message);
  }

  static void i(String message) {
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
