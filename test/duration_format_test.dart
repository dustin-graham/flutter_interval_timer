import 'package:interval_timer/duration_utility.dart';
import 'package:test/test.dart';

void main() {
  test('duration format works properly when time is under 1 minute', () {
    var secondsDuration = 5;
    var expectedOutput = '00:05';
    var actualOutput = DurationUtility.formattedDurationFromSeconds(secondsDuration);
    expect(actualOutput, expectedOutput);
  });

  test('duration format works properly when time is over 1 minute', () {
    var secondsDuration = 65;
    var expectedOutput = '01:05';
    var actualOutput = DurationUtility.formattedDurationFromSeconds(secondsDuration);
    expect(actualOutput, expectedOutput);
  });

  test('duration format works properly when time is over 1 hour', () {
    var secondsDuration = Duration(hours: 1, minutes: 5, seconds: 5).inSeconds;
    var expectedOutput = '01:05:05';
    var actualOutput = DurationUtility.formattedDurationFromSeconds(secondsDuration);
    expect(actualOutput, expectedOutput);
  });
}
