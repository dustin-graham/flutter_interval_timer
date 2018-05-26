import 'package:rxdart/rxdart.dart';

class Workout {
  final int sets;
  final int workDuration;
  final int restDuration;

  Workout(this.sets, this.workDuration, this.restDuration);

  Observable<WorkoutState> start() {
    final stateObservables = <Observable<WorkoutState>>[];
    stateObservables.add(preWorkoutObservable(sets, 5));
    for (int i = 0; i < sets; i++) {
      stateObservables.add(
          durationObservable(sets - i, workDuration, workoutPeriodDelegate));
      if (i < sets - 1) {
        stateObservables.add(durationObservable(
            sets - i, restDuration, workoutRestPeriodDelegate));
      }
    }
    stateObservables.add(new Observable.just(new WorkoutFinished()));
    return new Observable.concat(stateObservables);
  }

  WorkoutWorkPeriod workoutPeriodDelegate(
      int intervalsRemaining, int timeRemaining) {
    return new WorkoutWorkPeriod(intervalsRemaining, timeRemaining);
  }

  WorkoutRestPeriod workoutRestPeriodDelegate(
      int intervalsRemaining, int timeRemaining) {
    return new WorkoutRestPeriod(intervalsRemaining, timeRemaining);
  }

  Observable<PreWorkoutCountdown> preWorkoutObservable(
      int intervalsRemaining, int preWorkoutSeconds) {
    return new Observable.periodic(
            Duration(seconds: 1), (i) => preWorkoutSeconds - i)
        .take(preWorkoutSeconds+1)//we need to make the intervals inclusive of the last second
        .map((i) => new PreWorkoutCountdown(intervalsRemaining, i));
  }

  Observable<DurationWorkoutState> durationObservable(int intervalsRemaining,
      int duration, BuildDurationState createStateDelegate) {
    return new Observable.periodic(
            new Duration(seconds: 1), (i) => duration - i)
        .take(duration+1)//we need to make the intervals inclusive of the last second
        .map((i) => createStateDelegate(intervalsRemaining, i));
  }
}

typedef DurationWorkoutState BuildDurationState(
    int intervalsRemaining, int timeRemaining);

abstract class WorkoutState {}

abstract class DurationWorkoutState extends WorkoutState {
  final int intervalsRemaining;
  final int secondsRemaining;

  DurationWorkoutState(this.secondsRemaining, this.intervalsRemaining);
}

class WorkoutPaused extends WorkoutState {}

class PreWorkoutCountdown extends DurationWorkoutState {
  PreWorkoutCountdown(int intervalsRemaining, int secondsRemaining)
      : super(secondsRemaining, intervalsRemaining);
}

class WorkoutWorkPeriod extends DurationWorkoutState {
  WorkoutWorkPeriod(int intervalsRemaining, int secondsRemaining)
      : super(secondsRemaining, intervalsRemaining);
}

class WorkoutRestPeriod extends DurationWorkoutState {
  WorkoutRestPeriod(int intervalsRemaining, int secondsRemaining)
      : super(secondsRemaining, intervalsRemaining);
}

class WorkoutFinished extends WorkoutState {}
