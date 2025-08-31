import 'dart:convert';
import 'dart:io';

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
  String text = input.map((x) => _transformObject(x)).join(" ");
  List<String> lines = text.split("\n");
  bool multiline = lines.length > 1;
  int width = stdout.terminalColumns;

  if (!multiline) {
    print("> ${_effectsToString([0, if (effects != null) ...effects])}${prefix.toUpperCase()} ${Logger.dateStringFunction(DateTime.now())} $text${_effectsToString([0])}");
  } else {
    //
  }
}

enum LoggerType {
  print,
  warn,
  error,
  verbose,
  important,
  any,
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

  static void Function(Object? input, List<Object?>? attachments)? onPrint;
  static void Function(Object? input, List<Object?>? attachments)? onWarn;
  static void Function(Object? input, List<Object?>? attachments)? onError;
  static void Function(Object? input, List<Object?>? attachments)? onVerbose;
  static void Function(Object? input, List<Object?>? attachments)? onImportant;
  static void Function(LoggerType event, Object? input, List<Object?>? attachments)? onAny;

  static void _onAny(LoggerType event, Object? input, List<Object?>? attachments) {
    if (onAny != null) onAny!.call(event, input, attachments);
  }

  static void print(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled) return; // If not enabled
    if (onPrint != null) onPrint!.call(input, attachments);
    _onAny(LoggerType.print, input, attachments);
    _output("LOG", [input, if (attachments != null) ...attachments], null);
  }

  static void warn(Object? input, [List<Object?>? attachments]) {
    if (!(Settings.enabled || Settings.publicLogLevel >= 2)) return; // If not (either enabled or allow public warns or above)
    if (onWarn != null) onWarn!.call(input, attachments);
    _onAny(LoggerType.warn, input, attachments);
    _output("WRN", [input, if (attachments != null) ...attachments], [33]);
  }

  static void error(Object? input, [List<Object?>? attachments]) {
    if (!(Settings.enabled || Settings.publicLogLevel >= 1)) return; // If not (either enabled or all public errors or above)
    if (onError != null) onError!.call(input, attachments);
    _onAny(LoggerType.error, input, attachments);
    _output("ERR", [input, if (attachments != null) ...attachments], [31]);
  }

  static void verbose(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled || !Settings.verbose) return; // If not enabled or if not verbose
    if (onVerbose != null) onVerbose!.call(input, attachments);
    _onAny(LoggerType.verbose, input, attachments);
    _output("VBS", [input, if (attachments != null) ...attachments], [2]);
  }

  static void important(Object? input, [List<Object?>? attachments]) {
    if (!Settings.enabled) return; // If not enabled
    if (onImportant != null) onImportant!.call(input, attachments);
    _onAny(LoggerType.important, input, attachments);
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