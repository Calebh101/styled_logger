/// Loaded when the platform is on web.
library;

import 'dart:js_interop';

import 'main.dart';
import 'package:web/web.dart';

/// True, because platform_web is only loaded if the dart:html library is available.
final bool isWeb = true;

/// Represents the "terminal width".
final int terminalWidth = 10;

/// Uses native console APIs to print to the console.
void output(LoggerType type, String prefix, List<Object?> input, List<int>? effects, Object? code) {
  String string = "$prefix: ${input.map((x) => transformObject(x)).join(" ")}";
  JSString data = string.toJS;

  if (type == LoggerType.print) {
    console.log(data);
  } else if (type == LoggerType.warn) {
    console.warn(data);
  } else if (type == LoggerType.error) {
    console.error(data);
  } else if (type == LoggerType.verbose) {
    console.debug(data);
  } else if (type == LoggerType.important) {
    console.info(data);
  }
}