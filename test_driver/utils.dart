// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.
//
// see: https://raw.githubusercontent.com/brianegan/flutter_architecture_samples/master/example/integration_tests/lib/page_objects/utils.dart

import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

Future<bool> widgetExists(
    FlutterDriver driver,
    SerializableFinder finder, {
      Duration timeout,
    }) async {
  try {
    await driver.waitFor(finder, timeout: timeout);

    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> widgetAbsent(
    FlutterDriver driver,
    SerializableFinder finder, {
      Duration timeout,
    }) async {
  try {
    await driver.waitForAbsent(finder, timeout: timeout);

    return true;
  } catch (_) {
    return false;
  }
}