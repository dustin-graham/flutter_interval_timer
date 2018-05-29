import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() {
    driver?.close();
  });

  test('Configure Workout', () async {
    // setup finders
    // value labels
    var intervalValueLabelFinder =
        find.byValueKey("interval-count-setter-value-label");
    var workDurationValueLabelFinder =
        find.byValueKey("work-duration-setter-value-label");
    var restDurationValueLabelFinder =
        find.byValueKey("rest-duration-setter-value-label");

    // interval buttons
    var intervalUpButton = find.byValueKey("interval-count-setter-more-button");
    var intervalDownButton = find.byValueKey("interval-count-setter-less-button");

    // work duration buttons
    var workDurationUpButton = find.byValueKey("work-duration-setter-more-button");
    var workDurationDownButton = find.byValueKey("work-duration-setter-less-button");

    // rest duration buttons
    var restDurationUpButton = find.byValueKey("rest-duration-setter-more-button");
    var restDurationDownButton = find.byValueKey("rest-duration-setter-less-button");

    // verify the initial values
    expect(await driver.getText(intervalValueLabelFinder), "2");
    expect(await driver.getText(workDurationValueLabelFinder), "00:20");
    expect(await driver.getText(restDurationValueLabelFinder), "00:20");

    // tap the buttons and make sure the UI shows correctly
    // increase the interval count by 1
    await driver.tap(intervalUpButton);
    expect(await driver.getText(intervalValueLabelFinder), "3");

    // tap interval down button 5 times
    for(int i = 0; i < 5; i++) {
      await driver.tap(intervalDownButton);
    }
    // UI should not let the interval count go below 1
    expect(await driver.getText(intervalValueLabelFinder), "1");

    // tap the work duration up once
    await driver.tap(workDurationUpButton);
    // should count by 5
    expect(await driver.getText(workDurationValueLabelFinder), "00:25");

    // tap the work duration down 10 times
    for (int i = 0; i < 10; i++) {
      await driver.tap(workDurationDownButton);
    }
    // min value for this field is 5
    expect(await driver.getText(workDurationValueLabelFinder), "00:05");

    // tap the rest duration up once
    await driver.tap(restDurationUpButton);
    expect(await driver.getText(restDurationValueLabelFinder), "00:25");

    // tap the rest duration down 10 times
    for (int i = 0; i < 10; i++) {
      await driver.tap(restDurationDownButton);
    }
    // min value for this field is 5
    expect(await driver.getText(restDurationValueLabelFinder), "00:05");
  });
}
