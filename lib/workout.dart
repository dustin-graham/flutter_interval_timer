import 'dart:async';

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
      @required this.countDownDuration});

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
      return PreWorkoutCountdown(sets, actualWorkDuration.abs());
    } else if (actualWorkDuration < netWorkoutDuration) {
      //find out which set we are in and how much longer we have to go
      Duration totalSetDuration = workDuration + restDuration;
      final currentSet =
          actualWorkDuration.inSeconds ~/ totalSetDuration.inSeconds;
      final setsRemaining = sets - currentSet;
      // the set is composed of both the work and the rest period, need to find out which part we are in
      final durationInSet =
          actualWorkDuration.inMilliseconds % totalSetDuration.inMilliseconds;
      final netDuration = durationInSet - workDuration.inMilliseconds;
      if (netDuration < 0) {
        // we're in rest period
        return WorkoutWorkPeriod(setsRemaining, new Duration(milliseconds: netDuration.abs()));
      } else {
        // we're in work period
        final remainingRestMillis = restDuration.inMilliseconds - netDuration.abs();
        return WorkoutRestPeriod(
            setsRemaining, new Duration(milliseconds: remainingRestMillis));
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

}

typedef DurationWorkoutState BuildDurationState(
    int intervalsRemaining, int timeRemaining);

abstract class WorkoutState {}

abstract class DurationWorkoutState extends WorkoutState {
  final int intervalsRemaining;
  final Duration durationRemaining;
  int get secondsRemaining {
    final millisRemainder = durationRemaining.inMilliseconds % 1000;
    if (millisRemainder > 0) {
    // need to round up to upper whole second
      return durationRemaining.inSeconds + 1;
    }
    return durationRemaining.inSeconds;
  }

  DurationWorkoutState(this.durationRemaining, this.intervalsRemaining);
}

class WorkoutPaused extends WorkoutState {}

class PreWorkoutCountdown extends DurationWorkoutState {
  PreWorkoutCountdown(int intervalsRemaining, Duration durationRemaining)
      : super(durationRemaining, intervalsRemaining);

  @override
  String toString() {
    return 'PreWorkoutCountdown{$secondsRemaining}';
  }


}

class WorkoutWorkPeriod extends DurationWorkoutState {
  WorkoutWorkPeriod(int intervalsRemaining, Duration durationRemaining)
      : super(durationRemaining, intervalsRemaining);

  @override
  String toString() {
    return 'WorkoutWorkPeriod{$secondsRemaining}';
  }


}

class WorkoutRestPeriod extends DurationWorkoutState {
  WorkoutRestPeriod(int intervalsRemaining, Duration durationRemaining)
      : super(durationRemaining, intervalsRemaining);

  @override
  String toString() {
    return 'WorkoutRestPeriod{$secondsRemaining}';
  }


}

class WorkoutFinished extends WorkoutState {}
