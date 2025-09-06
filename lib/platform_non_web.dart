/// Loaded when the platform is not on web.
library;

import 'dart:io';

import 'main.dart';

/// False, because platform_web is only loaded if the dart:html library is available.
final bool isWeb = false;

/// Represents the terminal width of the console.
final int terminalWidth = stdout.terminalColumns;

/// Custom manager for how to print to the console.
void output(LoggerType type, String prefix, List<Object?> input, List<int>? effects, Object? code) {
  String text = input.map((x) => transformObject(x)).join(" ");
  List<String> lines = text.split("\n");
  bool multiline = lines.length > 1;
  int width = terminalWidth - 2;
  String effect = _effectsToString([0, if (effects != null) ...effects]).join("");
  String reset = _effectsToString([0]).join("");
  String title = ["$prefix ${Logger.dateStringFunction(DateTime.now())}", if (code != null) "Code ${transformObject(code)}"].join(" - ");

  if (type == LoggerType.warn || type == LoggerType.error) {
    multiline = true;
  }

  if (!multiline) {
    print("$reset> $effect$title $text$reset");
  } else {
    String dashes(int Function(double value) rounder) => "-" * (rounder(width / 2) - (1 + rounder(title.length / 2)));
    print("$reset> $effect${dashes((x) => x.floor())} $title ${dashes((x) => x.ceil())}$reset");

    for (String line in lines) {
      print(">$effect $line$reset");
    }

    print("$reset> $effect${"-" * width}$reset");
  }
}

List<String> _effectsToString(List<int> effects) {
  return effects.map((x) => "\x1b[${x}m").toList();
}