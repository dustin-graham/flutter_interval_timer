import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_driver/src/driver/driver.dart';

import 'test_element.dart';
import 'utils.dart';

class IncrementorElement extends TestElement {
  final String baseKeyName;
  SerializableFinder get _valueLabelFinder {
    return find.byValueKey("$baseKeyName-value-label");
  }
  SerializableFinder get _upButtonFinder {
    return find.byValueKey("$baseKeyName-more-button");
  }
  SerializableFinder get _downButtonFinder {
    return find.byValueKey("$baseKeyName-less-button");
  }

  IncrementorElement(FlutterDriver driver, this.baseKeyName)
      : super(driver);

  Future<bool> exists() async => await widgetExists(driver, _valueLabelFinder);
  Future<Null> tapMore() async => await driver.tap(_upButtonFinder);
  Future<Null> tapLess() async => await driver.tap(_downButtonFinder);
  Future<String> getValueLabel() async => await driver.getText(_valueLabelFinder);
}
