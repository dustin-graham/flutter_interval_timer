import 'dart:async';

import 'package:interval_timer/pausable_concat.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class Workout {
  final int sets;
  final Duration countDownDuration;
  final Duration workDuration;
  final Duration restDuration;
  StreamController<WorkoutState> _streamController;
  Observable<WorkoutState> workoutObservable;
  StreamSubscription<WorkoutState> _subscription;

  Workout(
      {@required this.sets,
      @required this.workDuration,
      @required this.restDuration,
      @required this.countDownDuration}) {
//    final stateObservables = <Observable<WorkoutState>>[];
//    stateObservables.add(preWorkoutObservable(sets, 5));
//    for (int i = 0; i < sets; i++) {
//      stateObservables.add(
//          durationObservable(sets - i, workDuration, workoutPeriodDelegate));
//      if (i < sets - 1) {
//        stateObservables.add(durationObservable(
//            sets - i, restDuration, workoutRestPeriodDelegate));
//      }
//    }
//    stateObservables.add(new Observable.just(new WorkoutFinished()));
//    final _workoutObservable = new Observable<WorkoutState>(
//        new PausableConcatStream<WorkoutState>(stateObservables));
//
//    void startWorkout() {
//      print("starting workout");
//      _subscription = _workoutObservable.listen(
//        (workoutState) {
//          print("workout State: $workoutState");
//          _streamController.add(workoutState);
//        },
//        onDone: () => _streamController.close(),
//        onError: (error, stackTrace) =>
//            _streamController.addError(error, stackTrace),
//      );
//    }
//
//    _streamController = new StreamController<WorkoutState>(
//        onListen: startWorkout,
//        onPause: () => _subscription?.pause(),
//        onResume: () => _subscription?.resume(),
//        onCancel: () => _subscription?.cancel());
//
//    workoutObservable = Observable<WorkoutState>(_streamController.stream);
  }

  /// Returns the total duration of the workout program which is the sum of:
  ///
  /// -  Pre-workout countdown
  /// -  Each set which is the sum of
  ///     -  [workDuration]
  ///     -  [restDuration] (except the last set)
  ///
  /// For example, if we have a 5 second pre-workout countdown,
  /// and a 5 second work interval and a 5 second rest interval we will
  /// have a 20 second workout program. It's not 25 seconds because the final
  /// set leaves off the rest duration since the workout is over.
  Duration get totalWorkoutDuration {
    return countDownDuration +
        ((workDuration + restDuration) * sets) -
        restDuration;
  }

  WorkoutState workoutStateAtElapsedDuration(Duration elapsedDuration) {
    Duration actualWorkDuration = elapsedDuration - countDownDuration;
    Duration netWorkoutDuration = totalWorkoutDuration - countDownDuration;
    if (actualWorkDuration < Duration(seconds: 0)) {
      // still in countdown
      return PreWorkoutCountdown(sets, actualWorkDuration.abs().inSeconds);
    } else if (actualWorkDuration < netWorkoutDuration) {
      //find out which set we are in and how much longer we have to go
      Duration totalSetDuration = workDuration + restDuration;
      final currentSet =
          actualWorkDuration.inSeconds ~/ totalSetDuration.inSeconds;
      // the set is composed of both the work and the rest period, need to find out which part we are in
      final durationInSet =
          actualWorkDuration.inSeconds % totalSetDuration.inSeconds;
      final netDuration = durationInSet - workDuration.inSeconds;
      final setsRemaining = sets - currentSet;
      if (netDuration < 0) {
        // we're in rest period
        return WorkoutWorkPeriod(setsRemaining, netDuration.abs());
      } else {
        // we're in work period
        return WorkoutRestPeriod(
            setsRemaining, restDuration.inSeconds - netDuration.abs());
      }
    } else {
      return WorkoutFinished();
    }
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
    final startTime = DateTime.now();
    return new Observable.periodic(
            Duration(milliseconds: 500),
            (_) => new PreWorkoutCountdown(intervalsRemaining,
                DateTime.now().difference(startTime).inSeconds))
        .take(preWorkoutSeconds)
        .startWith(
            new PreWorkoutCountdown(intervalsRemaining, preWorkoutSeconds));
  }

  Observable<DurationWorkoutState> durationObservable(int intervalsRemaining,
      Duration duration, BuildDurationState createStateDelegate) {
    return new Observable.periodic(
            new Duration(seconds: 1), (i) => duration.inSeconds - i)
        .take(duration.inSeconds)
        .map((i) => createStateDelegate(intervalsRemaining, i))
        .startWith(createStateDelegate(intervalsRemaining, duration.inSeconds));
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
