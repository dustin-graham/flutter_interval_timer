// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:interval_timer/main.dart';

void main() {
  testWidgets('Workout config initializes with defaults', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MyApp());

    // Verify that our counter starts at 0.
    var incrementorValueLabelFinder = find.byKey(new Key("incrementor-value-label"));
    var durationSetterFinder = find.byKey(new Key("work-duration-setter"));
    expect(durationSetterFinder, findsOneWidget);
    var workDurationValueLabelFinder = find.descendant(of: durationSetterFinder, matching: incrementorValueLabelFinder);
    expect(workDurationValueLabelFinder, findsOneWidget);
    var workDurationValueLabelText = tester.widget(workDurationValueLabelFinder) as Text;
    expect(workDurationValueLabelText.data, "00:05");

//    expect(find.text('1'), findsNothing);
//
//     Tap the '+' icon and trigger a frame.
//    await tester.tap(find.byIcon(Icons.add));
//    await tester.pump();
//
//     Verify that our counter has incremented.
//    expect(find.text('0'), findsNothing);
//    expect(find.text('1'), findsOneWidget);
  });
}
