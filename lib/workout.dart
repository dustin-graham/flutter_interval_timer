import 'dart:async';

import 'package:interval_timer/pausable_concat.dart';
import 'package:rxdart/rxdart.dart';

class Workout {
  final int sets;
  final int workDuration;
  final int restDuration;
  StreamController<WorkoutState> _streamController;
  Observable<WorkoutState> workoutObservable;
  StreamSubscription<WorkoutState> _subscription;

  Workout(this.sets, this.workDuration, this.restDuration) {
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
    final _workoutObservable = new Observable<WorkoutState>(new PausableConcatStream<WorkoutState>(stateObservables));

    void startWorkout() {
      _subscription = _workoutObservable.listen(
        (workoutState) {
          _streamController.add(workoutState);
        },
        onDone: () => _streamController.close(),
        onError: (error, stackTrace) =>
            _streamController.addError(error, stackTrace),
      );
    }

    _streamController = new StreamController<WorkoutState>(
        onListen: startWorkout,
        onPause: () => _subscription?.pause(),
        onResume: () => _subscription?.resume(),
        onCancel: () => _subscription?.cancel());

    workoutObservable = Observable<WorkoutState>(_streamController.stream);
  }

  bool get isPaused {
    return _subscription?.isPaused ?? false;
  }

  void pause() {
    _streamController.add(new WorkoutPaused());
    _subscription?.pause();
  }

  void resume() {
    _subscription?.resume();
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
        .take(preWorkoutSeconds +
            1) //we need to make the intervals inclusive of the last second
        .map((i) => new PreWorkoutCountdown(intervalsRemaining, i));
  }

  Observable<DurationWorkoutState> durationObservable(int intervalsRemaining,
      int duration, BuildDurationState createStateDelegate) {
    return new Observable.periodic(
            new Duration(seconds: 1), (i) => duration - i)
        .take(duration +
            1) //we need to make the intervals inclusive of the last second
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
