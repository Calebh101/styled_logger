import 'dart:convert';

String _transformObject(Object? input) {
  try {
    return jsonEncode(input);
  } catch (e) {
    return input.toString();
  }
}

List<String> _effectsToString(List<int> effects) {
  return effects.map((x) => "\\x1b${x}m").toList();
}

void _output(String prefix, List<Object?> input, List<int>? effects) {
  print("> ${_effectsToString([0, if (effects != null) ...effects])}${prefix.toUpperCase()} ${Logger.dateStringFunction(DateTime.now())} ${input.map((x) => _transformObject(x)).join(" ")}${_effectsToString([0])}");
}

class Settings {
  static bool enabled = false;
  static bool verbose = false;
  static int publicLogLevel = _publicLogLevelToInt(PublicLogLevel.warning);
}

class Logger {
  static bool get enabled => Settings.enabled;
  static bool get verboseEnabled => Settings.verbose;
  static PublicLogLevel get publicLogLevel => _intToPublicLogLevel(Settings.publicLogLevel);

  static String Function(DateTime) dateStringFunction = (DateTime now) {
    return now.toIso8601String();
  };

  static void print(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled) return;
    _output("LOG", [input, if (attachments != null) ...attachments], null);
  }

  static void warn(Object? input, [List<Object?>? attachments]) {
    if (!(Settings.enabled || Settings.publicLogLevel >= 2)) return;
    _output("WRN", [input, if (attachments != null) ...attachments], [33]);
  }

  static void error(Object? input, [List<Object?>? attachments]) {
    if (!(Settings.enabled || Settings.publicLogLevel >= 1)) return;
    _output("ERR", [input, if (attachments != null) ...attachments], [31]);
  }

  static void verbose(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled || !Settings.verbose) return;
    _output("VBS", [input, if (attachments != null) ...attachments], [2]);
  }

  static void important(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled) return;
    _output("IPT", [input, if (attachments != null) ...attachments], [1]);
  }

  static void enable() {
    Settings.enabled = true;
  }

  static void disable() {
    Settings.enabled = false;
  }

  static void enableVerbose() {
    Settings.verbose = true;
  }

  static void disableVerbose() {
    Settings.verbose = false;
  }

  static void setPublicLogLevel(PublicLogLevel level) {
    Settings.publicLogLevel = _publicLogLevelToInt(level);
  }
}

enum PublicLogLevel {
  /// No logs will be shown if logging is not explicitly enabled.
  none,

  /// Warning and error logs will be shown if logging is not explicitly enabled.
  warning,

  /// Only error logs will be shown if logging is not explicitly enabled.
  error,
}

PublicLogLevel _intToPublicLogLevel(int x) {
  if (x == 0) return PublicLogLevel.none;
  if (x == 1) return PublicLogLevel.error;
  if (x == 2) return PublicLogLevel.warning;
  throw RangeError("Invalid log level: $x");
}

int _publicLogLevelToInt(PublicLogLevel level) {
  switch (level) {
    case PublicLogLevel.none: return 0;
    case PublicLogLevel.warning: return 2;
    case PublicLogLevel.error: return 1;
  }
}