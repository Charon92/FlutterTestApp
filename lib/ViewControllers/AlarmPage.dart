import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../globals.dart' as globals;

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage(
      {Key? key,
      required this.title,
      required this.port,
      required this.prefs,
      required this.countKey,
      required this.isolateName})
      : super(key: key);

  final String title;
  final ReceivePort port;
  final SharedPreferences? prefs;
  final String countKey;
  final String isolateName;

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmPage> {
  int _counter = 0;
  bool _canVibrate = globals.canVibrate;

  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    widget.port.listen((_) async => await _incrementCounter());
  }

  Future<void> _incrementCounter() async {
    developer.log('Increment counter!');
    // Ensure we've loaded the updated count from the background isolate.
    await widget.prefs?.reload();

    setState(() {
      _counter++;
    });
  }

  // The background
  static SendPort? uiSendPort;

  // The callback for our alarm
  Future<void> callback() async {
    developer.log('Alarm fired!');
    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(widget.countKey);
    await prefs.setInt(widget.countKey, currentCount! + 1);

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(widget.isolateName)!;
    uiSendPort?.send(null);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: MainScaffoldDecoration(),
        child: Column(
          children: <Widget>[
            MainBodyAppBar(widget.title, context, null),
            Center(
              child: Column(children: [
                Text(
                  'Alarm fired $_counter times',
                  style: textStyle,
                ),
                SizedBox(
                  height: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total alarms fired: ',
                      style: textStyle,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.prefs?.getInt(widget.countKey).toString() ??
                          'Unknown Count',
                      key: const ValueKey('BackgroundCountText'),
                      style: textStyle,
                    ),
                  ],
                )
              ]),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black87),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(20)),
                  shape: MaterialStateProperty.all<BeveledRectangleBorder>(
                      BeveledRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0)),
                          side: BorderSide(
                            color: Colors.pinkAccent,
                            width: 1,
                          )))),
              key: const ValueKey('RegisterOneShotAlarm'),
              onPressed: () async {
                if (_canVibrate) {
                  Vibrate.feedback(FeedbackType.medium);
                }
                await AndroidAlarmManager.oneShot(
                  const Duration(seconds: 5),
                  // Ensure we have a unique alarm ID.
                  Random().nextInt(pow(2, 31).toInt()),
                  callback,
                  exact: true,
                  wakeup: true,
                );
              },
              child: const Text(
                'Schedule OneShot Alarm',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
