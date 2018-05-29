import 'dart:async';

import 'package:interval_timer/workout.dart';
import 'package:quiver/time.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutRunner {
  final Workout workout;
  final int refreshRateMillis;
  final Clock clock; // passing in the clock makes this unit testable
  BehaviorSubject<WorkoutState> _stateSubject = new BehaviorSubject();
  StreamSubscription<dynamic> _ticker;
  Duration _currentWorkoutPlayhead = new Duration(milliseconds: 0);
  Duration _pauseAdjustment = new Duration(seconds: 0);
  DateTime _startTime;
  DateTime _pausedTime;

  WorkoutRunner(this.workout,
      [this.refreshRateMillis = 250, this.clock = const Clock()]);

  Observable<WorkoutState> workoutStateObservable() {
    return new Observable(_stateSubject);
  }

  void runnerShouldBeStarted() {
    if (_ticker == null || _startTime == null) {
      throw "Runner should be started before doing this operation";
    }
  }

  start() {
    _startTime = clock.now();
    _pausedTime = null;
    _ticker?.cancel();
    _ticker = new Observable.periodic(Duration(milliseconds: refreshRateMillis))
        .startWith(PreWorkoutCountdown(workout.sets, workout.countDownDuration))
        .listen((_) {
      var now = clock.now();
      _currentWorkoutPlayhead = now.difference(_startTime) - _pauseAdjustment;
      final currentState =
          workout.workoutStateAtElapsedDuration(_currentWorkoutPlayhead);
      _stateSubject.add(currentState);
      if (currentState is WorkoutFinished) {
        stop();
      }
    });
  }

  stop() {
    _startTime = null;
    _pausedTime = null;
    _ticker?.cancel();
  }

  pause() {
    runnerShouldBeStarted();
    if (!isPaused()) {
      _pausedTime = clock.now();
      _stateSubject.add(WorkoutPaused());
      _ticker.pause();
    }
  }

  resume() {
    runnerShouldBeStarted();
    if (isPaused()) {
      _pauseAdjustment += clock.now().difference(_pausedTime);
      _pausedTime = null;
      final currentState =
          workout.workoutStateAtElapsedDuration(_currentWorkoutPlayhead);
      _stateSubject.add(currentState);
      _ticker.resume();
    }
  }

  isPaused() {
    return _ticker?.isPaused ?? false;
  }

  close() {
    _stateSubject.close();
    _ticker?.cancel();
  }
}
