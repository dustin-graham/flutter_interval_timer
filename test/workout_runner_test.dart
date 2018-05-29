import 'dart:async';

import 'package:async/async.dart';
import 'package:interval_timer/workout.dart';
import 'package:interval_timer/workout_runner.dart';
import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';

void main() {
  var initialTime = new DateTime(2000);

  test('WorkoutRunner can move through the workout', () {
    new FakeAsync().run((fake) {
      final workout = new Workout(
          sets: 2,
          countDownDuration: Duration(seconds: 5),
          restDuration: Duration(seconds: 5),
          workDuration: Duration(seconds: 5));
      final workoutRunner =
          new WorkoutRunner(workout, 1000, fake.getClock(initialTime));
      var workoutStates = <WorkoutState>[];
      workoutRunner.workoutStateObservable().listen((state) {
//        print("currentState: $state");
        workoutStates.add(state);
      });
      workoutRunner.start();
      // run through the whole workout
      fake.elapse(Duration(seconds: 20));

      // we should have produced 21 state updates, 5 for the countdown, 15 for the actual workout, 1 for the finish
      expect(workoutStates.length, 21);

      // the workout is now stopped, additional time should not produce more events
      fake.elapse(Duration(seconds: 10));
      expect(workoutStates.length, 21);

      // this first 4 should have been count downs
    });
  });

  test('WorkourRunner can pause and resume a workout', () {
    new FakeAsync().run((fake) {
      final workout = new Workout(
          sets: 2,
          countDownDuration: Duration(seconds: 5),
          restDuration: Duration(seconds: 5),
          workDuration: Duration(seconds: 5));
      final workoutRunner =
      new WorkoutRunner(workout, 1000, fake.getClock(initialTime));
      var workoutStates = <WorkoutState>[];
      workoutRunner.workoutStateObservable().listen((state) {
//        print("currentState: $state");
        workoutStates.add(state);
      });
      workoutRunner.start();

      fake.elapse(Duration(seconds: 3));// 5(initial), 4, 3, 2
      expect(workoutStates.length, 4);
      expect(workoutStates[3], isInstanceOf<PreWorkoutCountdown>());
      expect((workoutStates[3] as PreWorkoutCountdown).secondsRemaining, 2);

      // pause the runner
      workoutRunner.pause();
      fake.flushMicrotasks();// stream listeners are run on a microtask
      expect(workoutStates.length, 5);
      expect(workoutStates[4], isInstanceOf<WorkoutPaused>());
      // elapse some time
      fake.elapse(Duration(days: 1));

      // expect that there are no additional events
      expect(workoutStates.length, 5);
      expect(workoutStates[4], isInstanceOf<WorkoutPaused>());

      workoutRunner.resume();
      fake.flushMicrotasks();// runner emits current state immediately
      expect(workoutStates.length, 6);
      expect(workoutStates[5], isInstanceOf<PreWorkoutCountdown>());
      // still 2 because of some precision loss in moving time, need to investigate
      expect((workoutStates[5] as PreWorkoutCountdown).secondsRemaining, 2);

    });
  });
}
