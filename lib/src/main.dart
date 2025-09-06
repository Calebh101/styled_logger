/// Main source file for styled_logger.
library;

import 'dart:convert';

import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';

/// Stringify any object.
String transformObject(Object? input) {
  try {
    if (!(input is Map || input is List)) throw Exception();
    return jsonEncode(input);
  } catch (e) {
    return input.toString();
  }
}

/// Different types of logs.
enum LoggerType {
  /// General logs.
  print,

  /// Warning logs.
  warn,

  /// Error logs.
  error,

  /// Verbose logs.
  verbose,

  /// Important (bold) logs.
  important,

  /// Any type of log.
  any,
}

/// Global settings for the logger.
class Settings {
  Settings._();

  /// Decides if non-public logging can be shown.
  static bool enabled = false;

  /// Decides if verbose messages can be shown. Verbose messages cannot be shown if [enabled] is false.
  static bool verbose = false;

  /// Decides what logs will be shown even when logging has not been enabled.
  static int publicLogLevel = _publicLogLevelToInt(PublicLogLevel.warning);
}

/// Main class for providing APIs for logging to the console.
class Logger {
  Logger._();

  /// Decides if non-public logging can be shown.
  static bool get enabled => Settings.enabled;

  /// Decides if verbose messages can be shown. Verbose messages cannot be shown if [enabled] is false.
  static bool get verboseEnabled => Settings.verbose;

  /// Decides what logs will be shown even when logging has not been enabled.
  static PublicLogLevel get publicLogLevel => _intToPublicLogLevel(Settings.publicLogLevel);

  /// Function used to determine how to format a date. Defaults to [DateTime.toIso8601String].
  static String Function(DateTime) dateStringFunction = (DateTime now) => now.toIso8601String();

  /// Called when [print] is called. Logging has to be enabled.
  static void Function(Object? input, List<Object?>? attachments)? onPrint;

  /// Called when [warn] is called. Logging has to be enabled.
  static void Function(Object? input, List<Object?>? attachments, Object? code)? onWarn;

  /// Called when [error] is called. Logging has to be enabled.
  static void Function(Object? input, List<Object?>? attachments, Object? code)? onError;

  /// Called when [verbose] is called. Logging and verbose both have to be enabled.
  static void Function(Object? input, List<Object?>? attachments)? onVerbose;

  /// Called when [important] is called. Logging has to be enabled.
  static void Function(Object? input, List<Object?>? attachments)? onImportant;

  /// Called when any logging function is called. Logging has to be enabled.
  static void Function(LoggerType event, Object? input, List<Object?>? attachments)? onAny;

  static void _onAny(LoggerType event, Object? input, List<Object?>? attachments) {
    if (onAny != null) onAny!.call(event, input, attachments);
  }

  /// Prints a message.
  static void print(Object? input, {List<Object?>? attachments}) {
    if (!Settings.enabled) return; // If not enabled
    if (onPrint != null) onPrint!.call(input, attachments);
    _onAny(LoggerType.print, input, attachments);
    output(LoggerType.print, "LOG", [input, if (attachments != null) ...attachments], null, null);
  }

  /// Prints a warning message.
  static void warn(Object? input, {List<Object?>? attachments, Object? code}) {
    if (!(Settings.enabled || Settings.publicLogLevel >= _publicLogLevelToInt(PublicLogLevel.warning))) return; // If not (either enabled or allow public warns or above)
    if (onWarn != null) onWarn!.call(input, attachments, code);
    _onAny(LoggerType.warn, input, attachments);
    output(LoggerType.warn, "WRN", [input, if (attachments != null) ...attachments], [33], code);
  }

  /// Prints an error message.
  static void error(Object? input, {List<Object?>? attachments, Object? code}) {
    if (!(Settings.enabled || Settings.publicLogLevel >= _publicLogLevelToInt(PublicLogLevel.error))) return; // If not (either enabled or all public errors or above)
    if (onError != null) onError!.call(input, attachments, code);
    _onAny(LoggerType.error, input, attachments);
    output(LoggerType.error, "ERR", [input, if (attachments != null) ...attachments], [31], code);
  }

  /// Prints a verbose message, if verbose is enabled.
  static void verbose(Object? input, {List<Object?>? attachments}) {
    if (!Settings.enabled || !Settings.verbose) return; // If not enabled or if not verbose
    if (onVerbose != null) onVerbose!.call(input, attachments);
    _onAny(LoggerType.verbose, input, attachments);
    output(LoggerType.verbose, "VBS", [input, if (attachments != null) ...attachments], [2], null);
  }

  /// Prints a bold message.
  static void important(Object? input, {List<Object?>? attachments}) {
    if (!(Settings.enabled || Settings.publicLogLevel >= _publicLogLevelToInt(PublicLogLevel.important))) return; // If not (either enabled or allow public important logs or above)
    if (onImportant != null) onImportant!.call(input, attachments,);
    _onAny(LoggerType.important, input, attachments);
    output(LoggerType.important, "IPT", [input, if (attachments != null) ...attachments], [1], null);
  }

  /// enable all non-public logging (except for verbose).
  static void enable() {
    Settings.enabled = true;
  }

  /// Disable all non-public logging.
  static void disable() {
    Settings.enabled = false;
  }

  /// Enable verbose logs.
  static void enableVerbose() {
    Settings.verbose = true;
  }

  /// Disable verbose logs.
  static void disableVerbose() {
    Settings.verbose = false;
  }

  /// Decides what logs will be shown even when logging has not been enabled.
  static void setPublicLogLevel(PublicLogLevel level) {
    Settings.publicLogLevel = _publicLogLevelToInt(level);
  }
}

/// Decides what logs will be shown even when logging has not been enabled.
enum PublicLogLevel {
  /// No logs will be shown if logging is not explicitly enabled.
  none,

  /// Warning, error, and important logs will be shown if logging is not explicitely enabled.
  important,

  /// Warning and error logs will be shown if logging is not explicitly enabled.
  warning,

  /// Only error logs will be shown if logging is not explicitly enabled.
  error,
}

PublicLogLevel _intToPublicLogLevel(int x) {
  if (x == 0) return PublicLogLevel.none;
  if (x == 1) return PublicLogLevel.error;
  if (x == 2) return PublicLogLevel.warning;
  if (x == 3) return PublicLogLevel.important;
  throw RangeError("Invalid log level: $x");
}

int _publicLogLevelToInt(PublicLogLevel level) {
  switch (level) {
    case PublicLogLevel.none: return 0;
    case PublicLogLevel.important: return 3;
    case PublicLogLevel.warning: return 2;
    case PublicLogLevel.error: return 1;
  }
}
