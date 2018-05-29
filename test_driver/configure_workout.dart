// This line imports the extension
import 'package:flutter_driver/driver_extension.dart';
import 'package:interval_timer/main.dart' as App;

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  // Call the `main()` of your app or call `runApp` with whatever widget
  // you are interested in testing.
  App.main();
}