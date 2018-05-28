import 'package:interval_timer/workout.dart';
import 'package:test/test.dart';

void main() {
  group('Workout', () {

    test('Total length is correct', () {
      // 5 seconds countdown
      // 5 seconds work
      // 5 seconds rest
      // 5 seconds work
      // done (don't need to do the last rest period 'cause we're done)
      // total 20 seconds
      final workout = new Workout(sets: 2, workDuration: Duration(seconds: 5), restDuration: Duration(seconds: 5), countDownDuration: Duration(seconds: 5));
      expect(workout.totalWorkoutDuration, Duration(seconds: 20));
    });


    void expectInterval<T extends DurationWorkoutState>(WorkoutState state, int intervalsRemaining, int secondsRemaining) {
      expect(state, isInstanceOf<T>());
      var workPeriod17 = state as T;
      expect(workPeriod17.intervalsRemaining, intervalsRemaining);
      expect(workPeriod17.secondsRemaining, secondsRemaining);
    }

    test('Is Seekable', () {
      final workout = new Workout(sets: 2, workDuration: Duration(seconds: 5), restDuration: Duration(seconds: 5), countDownDuration: Duration(seconds: 5));

      // starting out we should be in countdown mode
      final stateAtTime0 = workout.workoutStateAtElapsedDuration(Duration(seconds: 0));
      expectInterval<PreWorkoutCountdown>(stateAtTime0, 2, 5);

      // sub-second durations get truncated
      final stateAtTime0250 = workout.workoutStateAtElapsedDuration(Duration(milliseconds: 250));
      expectInterval<PreWorkoutCountdown>(stateAtTime0250, 2, 5);

      // 3 seconds into it we should still be in countdown
      final stateAtTime3 = workout.workoutStateAtElapsedDuration(Duration(seconds: 3));
      expectInterval<PreWorkoutCountdown>(stateAtTime3, 2, 2);

      // 5 seconds into it we should be now in our main workout
      final stateAtTime5 = workout.workoutStateAtElapsedDuration(Duration(seconds: 5));
      expectInterval<WorkoutWorkPeriod>(stateAtTime5, 2, 5);

      // 7 seconds into it we should still be in the first work period with 3 seconds to go
      final stateAtTime7 = workout.workoutStateAtElapsedDuration(Duration(seconds: 7));
      expectInterval<WorkoutWorkPeriod>(stateAtTime7, 2, 3);

      // 10 seconds into it, we've finished the countdown and first work period, time to rest
      final stateAtTime10 = workout.workoutStateAtElapsedDuration(Duration(seconds: 10));
      expectInterval<WorkoutRestPeriod>(stateAtTime10, 2, 5);

      // 17 seconds into it, we're working out again on our last set
      final stateAtTime17 = workout.workoutStateAtElapsedDuration(Duration(seconds: 17));
      expectInterval<WorkoutWorkPeriod>(stateAtTime17, 1, 3);

      // 23 seconds into it we're finished because there's no need to rest before we finish
      final stateAtTime23 = workout.workoutStateAtElapsedDuration(Duration(seconds: 23));
      expect(stateAtTime23, isInstanceOf<WorkoutFinished>());

    });
  });
}
