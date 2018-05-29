import 'dart:async';

import 'package:interval_timer/workout.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutRunner {
  final Workout workout;
  BehaviorSubject<WorkoutState> _stateSubject = new BehaviorSubject();
  StreamSubscription<dynamic> _ticker;
  Duration _currentWorkoutPlayhead = new Duration(milliseconds: 0);
  Duration _pauseAdjustment = new Duration(seconds: 0);
  DateTime _startTime;
  DateTime _pausedTime;

  WorkoutRunner(this.workout);

  Observable<WorkoutState> workoutStateObservable() {
    return new Observable(_stateSubject);
  }

  void runnerShouldBeStarted() {
    if (_ticker == null || _startTime == null) {
      throw "Runner should be started before doing this operation";
    }
  }

  start() {
    _startTime = DateTime.now();
    _pausedTime = null;
    _ticker?.cancel();
    _ticker = new Observable.periodic(Duration(milliseconds: 250)).listen((_) {
      _currentWorkoutPlayhead = DateTime.now().difference(_startTime) - _pauseAdjustment;
      print(_currentWorkoutPlayhead);
      final currentState = workout.workoutStateAtElapsedDuration(_currentWorkoutPlayhead);
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
      _pausedTime = new DateTime.now();
      _stateSubject.add(WorkoutPaused());
      _ticker.pause();
    }
  }

  resume() {
    runnerShouldBeStarted();
    if (isPaused()) {
      _pauseAdjustment += new DateTime.now().difference(_pausedTime);
      _pausedTime = null;
      final currentState = workout.workoutStateAtElapsedDuration(
          _currentWorkoutPlayhead);
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