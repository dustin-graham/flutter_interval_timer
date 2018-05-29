// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/defaults.dart';

import 'package:interval_timer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var methodChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  Map<String, dynamic> preferenceOverrides = {};

  configureSharedPrefs() {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        // for some reason shared_prefs needs a prefix
        return new Future.value(
            preferenceOverrides.map((k, v) => MapEntry("flutter.$k", v)));
      }
      return null;
    });
  }

  setUp(() {
    configureSharedPrefs();
  });


  verifyIncrementorValueLabel(
      WidgetTester tester, String keyName, String expectedValue) {
    var incrementorValueLabelFinder =
        find.byKey(new Key("incrementor-value-label"));

    var intervalCountSetterFinder = find.byKey(new Key(keyName));
    expect(intervalCountSetterFinder, findsOneWidget);
    var intervalCountValueLabelFinder = find.descendant(
        of: intervalCountSetterFinder, matching: incrementorValueLabelFinder);
    Text intervalCountValueLabelWidget =
        tester.widget(intervalCountValueLabelFinder);
    expect(intervalCountValueLabelWidget.data, expectedValue);
  }

  // TODO: find out how to configure shared prefs differently for different tests
//  testWidgets('Workout config initializes with defaults',
//      (WidgetTester tester) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    Defaults defaults = new Defaults(prefs);
//    // Build our app and trigger a frame.
//    await tester.pumpWidget(new MyApp(
//      defaults: defaults,
//    ));
//
//    // verify initial sets count setter
//    verifyIncrementorValueLabel(tester, "interval-count-setter", "2");
//
//    // verify initial work duration setter
//    verifyIncrementorValueLabel(tester, "work-duration-setter", "00:20");
//
//    // verify initial rest duration setter
//    verifyIncrementorValueLabel(tester, "rest-duration-setter", "00:20");
//  });

  testWidgets('workout config defaults respect user settings',
      (WidgetTester tester) async {
    preferenceOverrides = {
      Defaults.lastUsedSets: 50,
      Defaults.lastUsedWorkDurationSeconds: 300, // 05:00
      Defaults.lastUsedRestDurationSeconds: 120 // 02:00
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Defaults defaults = new Defaults(prefs);
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MyApp(
      defaults: defaults,
    ));

    // verify initial sets count setter
    verifyIncrementorValueLabel(tester, "interval-count-setter", "50");

    // verify initial work duration setter
    verifyIncrementorValueLabel(tester, "work-duration-setter", "05:00");

    // verify initial rest duration setter
    verifyIncrementorValueLabel(tester, "rest-duration-setter", "02:00");
  });
}
