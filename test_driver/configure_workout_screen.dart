import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

import 'incrementor_element.dart';
import 'test_screen.dart';

class ConfigureWorkoutScreen extends TestScreen {
  IncrementorElement intervalCountElement;
  IncrementorElement workDurationElement;
  IncrementorElement restDurationElement;

  ConfigureWorkoutScreen(FlutterDriver driver)
      : intervalCountElement =
            new IncrementorElement(driver, "interval-count-setter"),
        workDurationElement =
            new IncrementorElement(driver, "work-duration-setter"),
        restDurationElement =
            new IncrementorElement(driver, "rest-duration-setter"),
        super(driver);

  @override
  Future<bool> isReady({Duration timeout}) =>
      intervalCountElement.exists();
}
