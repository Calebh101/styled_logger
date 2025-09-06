/// A file specifically made for running tests. To run these tests, run this command:
/// 
/// `dart run lib/src/test.dart`
library;

import 'main.dart';

void main(List<String> arguments) {
  Logger.enable();
  Logger.print("Hello, world!");
  Logger.print("Hello,\nworld!");
  Logger.verbose("You shouldn't see this.");

  Logger.enableVerbose();
  Logger.verbose("You should see this.");

  Logger.warn("Uh oh!");
  Logger.warn("Uh oh, with a code!", code: 3);
  Logger.error("Uh oh!");
  Logger.error("Uh oh, with a code!", code: "ERR_0");
  Logger.important("This is a bold message.");

  Logger.disable();
  Logger.setPublicLogLevel(PublicLogLevel.important);
  Logger.important("This is another bold message.");
  Logger.setPublicLogLevel(PublicLogLevel.warning);
  Logger.important("This is a hidden bold message.");
  Logger.warn("This is a warning!");
  Logger.setPublicLogLevel(PublicLogLevel.error);
  Logger.warn("This is a hidden warning!");
  Logger.error("This is an error!");
  Logger.setPublicLogLevel(PublicLogLevel.none);
  Logger.error("This is a hidden error!");

  Logger.print("This is a hidden log!");
  Logger.verbose("This is a hidden verbose log!");
  Logger.warn("This is a hidden warning, again!");
}
