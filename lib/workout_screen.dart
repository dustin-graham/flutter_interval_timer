import 'package:flutter/material.dart';
import 'package:interval_timer/workout.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutScreen extends StatefulWidget {
  final int sets;
  final int workDuration;
  final int restDuration;

  const WorkoutScreen(
      {Key key, this.sets, this.workDuration, this.restDuration})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _WorkoutScreen(new Workout(sets, workDuration, restDuration));
}

class _WorkoutScreen extends State<WorkoutScreen> {
  final Workout workout;
  Observable<WorkoutState> workoutStream;

  _WorkoutScreen(this.workout);

  @override
  void initState() {
    super.initState();
    workoutStream = workout.start();
  }

  _togglePlayPause() {
//    setState(() {
//      isPaused = !isPaused;
//    });
  }

  _bodyWidget(BuildContext context, bool paused, int intervalsRemaining, int secondsRemaining, String helperText) {
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
                secondsRemaining.toString(),
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
          if (workoutState is WorkoutPaused) {
            isPaused = true;
            bodyWidget = new Text("Paused");
          } else if (workoutState is PreWorkoutCountdown) {
            bodyWidget = _bodyWidget(context, false, workoutState.intervalsRemaining, workoutState.secondsRemaining, "GET READY");
          } else if (workoutState is WorkoutWorkPeriod) {
            bodyWidget = _bodyWidget(context, false, workoutState.intervalsRemaining, workoutState.secondsRemaining, "WORK IT!");
          } else if (workoutState is WorkoutRestPeriod) {
            bodyWidget = _bodyWidget(context, false, workoutState.intervalsRemaining, workoutState.secondsRemaining, "REST NOW");
          } else if (workoutState is WorkoutFinished) {
            bodyWidget = new Text("Finished");
          }

          return new Scaffold(
              floatingActionButton: new FloatingActionButton(
                onPressed: _togglePlayPause,
                child: isPaused
                    ? new Icon(Icons.play_arrow)
                    : new Icon(Icons.pause),
              ),
              body: bodyWidget);
        });
  }
}
