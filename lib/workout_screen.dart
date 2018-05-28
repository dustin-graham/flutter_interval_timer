import 'package:flutter/material.dart';
import 'package:interval_timer/duration_utility.dart';
import 'package:interval_timer/workout.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audioplayer/audioplayer.dart';

class WorkoutScreen extends StatefulWidget {
  final int sets;
  final Duration countdownDuration;
  final Duration workDuration;
  final Duration restDuration;

  const WorkoutScreen(
      {Key key,
      this.sets,
      this.workDuration,
      this.restDuration,
      this.countdownDuration = const Duration(seconds: 5)})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutScreen();
}

enum WorkoutAudio { getReady, go, rest, done }

class _WorkoutScreen extends State<WorkoutScreen> {
  Workout workout;
  Observable<WorkoutState> workoutStream;
  AudioPlayer audioPlayer = new AudioPlayer();
  WorkoutAudio lastPlayedAudio;

  _initializeWorkout() {
    workout = new Workout(
        sets: widget.sets,
        workDuration: widget.workDuration,
        restDuration: widget.restDuration,
        countDownDuration: widget.countdownDuration);
    final now = DateTime.now();
    workoutStream = new Observable.periodic(Duration(milliseconds: 250), (_) {
      return workout
          .workoutStateAtElapsedDuration(DateTime.now().difference(now));
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeWorkout();
  }

  _maybePlayAudio(WorkoutAudio audio) {
    if (lastPlayedAudio == null || lastPlayedAudio != audio) {
      lastPlayedAudio = audio;
      audioPlayer.playAsset(_audioPathForType(audio));
    }
  }

  String _audioPathForType(WorkoutAudio audio) {
    switch (audio) {
      case WorkoutAudio.getReady:
        return "audio/get_ready.m4a";
      case WorkoutAudio.go:
        return "audio/go.m4a";
      case WorkoutAudio.rest:
        return "audio/rest.m4a";
      case WorkoutAudio.done:
        return "audio/done.m4a";
      default:
        return null;
    }
  }

  _restart() {
    setState(() {
      _initializeWorkout();
    });
  }

  _finish(BuildContext context) {
    Navigator.pop(context);
  }

  _bodyWidget(BuildContext context, bool paused, int intervalsRemaining,
      int secondsRemaining, String helperText) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final stack = <Widget>[];
    if (paused) {
      stack.add(
        new Align(
            alignment: Alignment.topCenter + new Alignment(0.0, 0.1),
            child: new RaisedButton(
              onPressed: () {},
              child: new Text("Hold to Reset"),
            )),
      );
    }
    stack.add(
      new Container(
        width: double.infinity,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: new Text(
                intervalsRemaining.toString(),
                style: textTheme.display2,
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: new Text(
                DurationUtility.formattedDurationFromSeconds(secondsRemaining),
                style: textTheme.display3,
              ),
            ),
            new Text(
              helperText,
              style: textTheme.headline.copyWith(fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
    );
    return new Stack(
      children: stack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<WorkoutState>(
        stream: workoutStream,
        builder: (context, snapshot) {
          var workoutState = snapshot.data;
          print("workout state type: $workoutState");
          Widget bodyWidget;
          bool isPaused = false;
          bool isFinished = false;
          if (workoutState is WorkoutPaused) {
            isPaused = true;
            bodyWidget = new Center(child: new Text("Paused"));
          } else if (workoutState is PreWorkoutCountdown) {
            _maybePlayAudio(WorkoutAudio.getReady);
            bodyWidget = _bodyWidget(
                context,
                false,
                workoutState.intervalsRemaining,
                workoutState.secondsRemaining,
                "GET READY");
          } else if (workoutState is WorkoutWorkPeriod) {
            _maybePlayAudio(WorkoutAudio.go);
            bodyWidget = _bodyWidget(
                context,
                false,
                workoutState.intervalsRemaining,
                workoutState.secondsRemaining,
                "WORK IT!");
          } else if (workoutState is WorkoutRestPeriod) {
            _maybePlayAudio(WorkoutAudio.rest);
            bodyWidget = _bodyWidget(
                context,
                false,
                workoutState.intervalsRemaining,
                workoutState.secondsRemaining,
                "REST NOW");
          } else if (workoutState is WorkoutFinished) {
            _maybePlayAudio(WorkoutAudio.done);
            isFinished = true;
            bodyWidget = new Center(
                child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Finished"),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                    onPressed: () {
                      _restart();
                    },
                    child: new Text("RESTART"),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new RaisedButton(
                    onPressed: () {
                      _finish(context);
                    },
                    child: new Text("FINISH"),
                  ),
                ),
              ],
            ));
          }

          return new Scaffold(
              floatingActionButton: isFinished
                  ? null
                  : new FloatingActionButton(
                      onPressed: isPaused
                          ? () => workout.resume()
                          : () => workout.pause(),
                      child: isPaused
                          ? new Icon(Icons.play_arrow)
                          : new Icon(Icons.pause),
                    ),
              body: bodyWidget);
        });
  }
}
