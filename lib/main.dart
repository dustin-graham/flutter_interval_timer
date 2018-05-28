import 'package:flutter/material.dart';
import 'package:interval_timer/duration_utility.dart';
import 'package:interval_timer/workout_screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        buttonColor: Colors.lightBlue,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new WorkoutConfigScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class WorkoutConfigScreen extends StatefulWidget {
  WorkoutConfigScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WorkoutConfigScreen createState() => new _WorkoutConfigScreen();
}

class _WorkoutConfigScreen extends State<WorkoutConfigScreen> {
  int _sets = 0;
  int _workInterval = 0;
  int _restInterval = 0;

  void _startWorkout(BuildContext contex) {
    Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) => new WorkoutScreen(
                  sets: _sets,
                  workDuration: _workInterval,
                  restDuration: _restInterval)),
        );
  }

  _changeSets(int sets) {
    print("got $sets sets");
    _sets = sets;
  }

  _changeWorkInterval(int workIntervalDuration) {
    print("got $workIntervalDuration work duration");
    _workInterval = workIntervalDuration;
  }

  _changeRestInterval(int restInterval) {
    print("got $restInterval rest duration");
    _restInterval = restInterval;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Incrementor(
              label: "Sets",
              incrementAmount: 1,
              onIncrementorChanged: _changeSets,
            ),
            new Incrementor(
              type: IncrementorType.duration,
              label: "Work Interval",
              incrementAmount: 5,
              onIncrementorChanged: _changeWorkInterval,
            ),
            new Incrementor(
              type: IncrementorType.duration,
              label: "Rest Interval",
              incrementAmount: 5,
              onIncrementorChanged: _changeRestInterval,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _startWorkout(context),
        tooltip: 'Start Workout',
        child: new Icon(
          Icons.play_arrow,
          size: 36.0,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

enum IncrementorType { integer, duration }

typedef void OnIncrementorChanged(int newValue);

class Incrementor extends StatefulWidget {
  final String label;
  final IncrementorType type;
  final int incrementAmount;
  final OnIncrementorChanged onIncrementorChanged;

  const Incrementor(
      {Key key,
      this.label,
      this.type,
      this.incrementAmount,
      this.onIncrementorChanged})
      : super(key: key);

  @override
  _IncrementorState createState() => new _IncrementorState();
}

class _IncrementorState extends State<Incrementor> {
  int count = 0;

  _increment() {
    setState(() {
      count = count + widget.incrementAmount;
      widget.onIncrementorChanged(count);
    });
  }

  _decrement() {
    setState(() {
      count = count - widget.incrementAmount;
      if (count < 0) {
        count = 0;
      }
      widget.onIncrementorChanged(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: new Text(
              widget.label,
              style: new TextStyle(fontSize: 20.0),
            ),
          ),
          new Container(
            width: 250.0,
            child: new Row(
              children: <Widget>[
                new IconButton(
                  iconData: Icons.indeterminate_check_box,
                  onTap: () {
                    _decrement();
                  },
                ),
                new Container(
                    alignment: Alignment.center,
                    width: 150.0,
                    child: new Text(
                      widget.type == IncrementorType.duration ? DurationUtility.formattedDurationFromSeconds(count) : "$count",
                      style: new TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w700),
                    )),
                new IconButton(
                  iconData: Icons.add_box,
                  onTap: () {
                    _increment();
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

typedef void IconButtonOnTapCallback();
typedef void IconButtonLongPressCallback();

class IconButton extends StatelessWidget {
  final IconButtonOnTapCallback onTap;
  final IconButtonLongPressCallback onLongPress;
  final IconData iconData;

  const IconButton({Key key, this.onTap, this.iconData, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new InkResponse(
      child: new Icon(iconData),
      onTap: onTap,
      onLongPress: onLongPress,
      onTapCancel: () {
        print("cancel");
      },
    );
  }
}

