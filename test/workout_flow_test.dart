import 'package:interval_timer/workout.dart';
import 'package:test/test.dart';

void main() {
  group('Workout', () {
//    test('Flows from start to finish', () async {
//      final workout = new Workout(sets: 2, workDuration: Duration(seconds: 5), restDuration: Duration(seconds: 5), countDownDuration: Duration(seconds: 5));
//      StreamQueue<WorkoutState> queue = new StreamQueue(workout.workoutObservable);
//      while (await queue.hasNext) {
//        var event = await queue.next;
//      }
//      expect(true, false);
//    });

    test('Total length is correct', () {
      final workout = new Workout(sets: 2, workDuration: Duration(seconds: 5), restDuration: Duration(seconds: 5), countDownDuration: Duration(seconds: 5));
      expect(workout.totalWorkoutDuration, Duration(seconds: 25));
    });


    void expectInterval<T extends DurationWorkoutState>(WorkoutState state, int intervalsRemaining, int secondsRemaining) {
      expect(state, isInstanceOf<WorkoutWorkPeriod>());
      var workPeriod17 = state as T;
      expect(workPeriod17.intervalsRemaining, intervalsRemaining);
      expect(workPeriod17.secondsRemaining, secondsRemaining);
    }

    test('Is Seekable', () {
      final workout = new Workout(sets: 2, workDuration: Duration(seconds: 5), restDuration: Duration(seconds: 5), countDownDuration: Duration(seconds: 5));
      final stateAtTime0 = workout.workoutStateAtElapsedDuration(Duration(seconds: 0));

      // starting out we should be in countdown mode
      expect(stateAtTime0, isInstanceOf<PreWorkoutCountdown>());
      var countdown0 = stateAtTime0 as PreWorkoutCountdown;
      expect(countdown0.intervalsRemaining, 2);
      expect(countdown0.secondsRemaining, 5);

      // 3 seconds into it we should still be in countdown
      final stateAtTime3 = workout.workoutStateAtElapsedDuration(Duration(seconds: 3));
      expect(stateAtTime3, isInstanceOf<PreWorkoutCountdown>());
      var countdown3 = stateAtTime3 as PreWorkoutCountdown;
      expect(countdown3.intervalsRemaining, 2);
      expect(countdown3.secondsRemaining, 2);

      // 5 seconds into it we should be now in our main workout
      final stateAtTime5 = workout.workoutStateAtElapsedDuration(Duration(seconds: 5));
      expect(stateAtTime5, isInstanceOf<WorkoutWorkPeriod>());
      var workPeriod5 = stateAtTime5 as WorkoutWorkPeriod;
      expect(workPeriod5.intervalsRemaining, 2);
      expect(workPeriod5.secondsRemaining, 5);

      // 7 seconds into it we should still be in the first work period with 3 seconds to go
      final stateAtTime7 = workout.workoutStateAtElapsedDuration(Duration(seconds: 7));
      expect(stateAtTime7, isInstanceOf<WorkoutWorkPeriod>());
      var workPeriod7 = stateAtTime7 as WorkoutWorkPeriod;
      expect(workPeriod7.intervalsRemaining, 2);
      expect(workPeriod7.secondsRemaining, 3);

      // 10 seconds into it, we've finished the countdown and first work period, time to rest
      final stateAtTime10 = workout.workoutStateAtElapsedDuration(Duration(seconds: 10));
      expect(stateAtTime10, isInstanceOf<WorkoutRestPeriod>());
      var restPeriod10 = stateAtTime10 as WorkoutRestPeriod;
      expect(restPeriod10.intervalsRemaining, 2);
      expect(restPeriod10.secondsRemaining, 5);

      // 17 seconds into it, we're working out again on our last set
      final stateAtTime17 = workout.workoutStateAtElapsedDuration(Duration(seconds: 17));
      expectInterval(stateAtTime17, 1, 3);

    });


  });
}
