import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'configure_workout_screen.dart';

void main() {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() {
    driver?.close();
  });
  
  test('Configure Workout', () async {
    final screen = new ConfigureWorkoutScreen(driver);

    // verify initial values
    expect(await screen.intervalCountElement.getValueLabel(), "2");
    expect(await screen.workDurationElement.getValueLabel(), "00:20");
    expect(await screen.restDurationElement.getValueLabel(), "00:20");

    // tab the buttons and make sure the UI shows correctly
    // increase the interval count by 1
    await screen.intervalCountElement.tapMore();
    expect(await screen.intervalCountElement.getValueLabel(), "3");

    // tap interval down button 5 times
    for(int i = 0; i < 5; i++) {
      await screen.intervalCountElement.tapLess();
    }
    // UI should not let the interval count go below 1
    expect(await screen.intervalCountElement.getValueLabel(), "1");

    // tap the work duration up once
    await screen.workDurationElement.tapMore();
    // should count by 5
    expect(await screen.workDurationElement.getValueLabel(), "00:25");

    // tap the work duration down 10 times
    for (int i = 0; i < 10; i++) {
      await screen.workDurationElement.tapLess();
    }
    // min value for this field is 5
    expect(await screen.workDurationElement.getValueLabel(), "00:05");

    // tap the rest duration up once
    await screen.restDurationElement.tapMore();
    expect(await screen.restDurationElement.getValueLabel(), "00:25");

    // tap the rest duration down 10 times
    for (int i = 0; i < 10; i++) {
      await screen.restDurationElement.tapLess();
    }
    // min value for this field is 5
    expect(await screen.restDurationElement.getValueLabel(), "00:05");
  });
}
