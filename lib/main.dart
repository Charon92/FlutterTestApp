import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertest/ViewControllers/GalleryPage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ViewControllers/MovieSearchPage.dart';
import 'ViewControllers/NotesPage.dart';
import 'ViewControllers/MusicPage.dart';
import 'ViewControllers/GalleryPage.dart';
import 'ViewControllers/AlarmPage.dart';
import 'ViewControllers/CameraPage.dart';

import 'Components/ScaffoldDecoration.dart';
import 'Components/MainBodyAppBar.dart';

import 'Models/Note.dart';

import 'globals.dart' as globals;

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences? prefs;

const double cardBorderWidth = 1;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Obtain a list of the available cameras on the device.
  globals.cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  globals.camera = globals.cameras!.first;

  HttpOverrides.global = new MyHttpOverrides();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TagAdapter());

  await Hive.openBox<Note>('notes');
  await Hive.openBox<Tag>('tags');

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs!.containsKey(countKey)) {
    await prefs?.setInt(countKey, 0);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generic Functions',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'JetBrains',
        textTheme: TextTheme(
                bodyText1: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
                bodyText2: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w100),
                headline1: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                headline2: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                headline4: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold))
            .apply(
          bodyColor: Colors.white,
        ),
      ),
      home: const Homepage(title: 'My Utilities'),
      routes: {
        '/movie_search': (context) =>
            MovieSearchPage(title: 'Search for a movie'),
        '/notes': (context) => NotesPage(title: 'Notes'),
        '/music_player': (context) => MusicPage(title: 'Music Player'),
        '/gallery': (context) => GalleryPage(title: 'Gallery'),
        '/alarms': (context) => AlarmPage(
            title: 'Alarms',
            countKey: countKey,
            prefs: prefs,
            port: port,
            isolateName: isolateName),
        '/camera': (context) => CameraPage(title: 'Camera')
      },
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _init();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  // Future<void> _checkBiometrics() async {
  //   late bool canCheckBiometrics;
  //   try {
  //     canCheckBiometrics = await auth.canCheckBiometrics;
  //   } on PlatformException catch (e) {
  //     canCheckBiometrics = false;
  //     print(e);
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _canCheckBiometrics = canCheckBiometrics;
  //   });
  // }
  //
  // Future<void> _getAvailableBiometrics() async {
  //   late List<BiometricType> availableBiometrics;
  //   try {
  //     availableBiometrics = await auth.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     availableBiometrics = <BiometricType>[];
  //     print(e);
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _availableBiometrics = availableBiometrics;
  //   });
  // }
  //
  // Future<void> _authenticate() async {
  //   bool authenticated = false;
  //   try {
  //     setState(() {
  //       _isAuthenticating = true;
  //       _authorized = 'Authenticating';
  //     });
  //     authenticated = await auth.authenticate(
  //         localizedReason: 'Let OS determine authentication method',
  //         useErrorDialogs: true,
  //         stickyAuth: true);
  //     setState(() {
  //       _isAuthenticating = false;
  //     });
  //   } on PlatformException catch (e) {
  //     print(e);
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Error - ${e.message}';
  //     });
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   setState(
  //           () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  // }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  Future<void> _init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      globals.canVibrate = canVibrate;
      globals.canVibrate
          ? debugPrint('This device can vibrate')
          : debugPrint('This device cannot vibrate');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized == 'Authorized') {
      return Scaffold(
          body: Container(
        height: double.maxFinite,
        decoration: MainScaffoldDecoration(),
        child: Column(
          children: [
            MainBodyAppBar(widget.title, context, []),
            Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0),
              child: ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: () => {
                      if (globals.canVibrate)
                        {Vibrate.feedback(FeedbackType.selection)},
                      Navigator.pushNamed(context, '/notes')
                    },
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 3.0, color: Colors.white),
                            ),
                            color: Colors.black26,
                          ),
                          child: Padding(
                            child: ListTile(
                              title: Text('Notes',
                                  style: TextStyle(color: Colors.white)),
                              leading: Icon(
                                Icons.note,
                                color: Colors.white,
                                size: 30.0,
                                semanticLabel: 'All Notes',
                              ),
                            ),
                            padding: EdgeInsets.all(5),
                          ),
                        )),
                  ),
                  GestureDetector(
                      onTap: () => {
                            if (globals.canVibrate)
                              {Vibrate.feedback(FeedbackType.selection)},
                            Navigator.pushNamed(context, '/music_player')
                          },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 3.0, color: Colors.white),
                            ),
                            color: Colors.black26,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: ListTile(
                                leading: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30.0,
                                  semanticLabel: 'Music Player',
                                ),
                                title: Text('Music',
                                    style: TextStyle(color: Colors.white)),
                              )),
                        ),
                      )),
                  GestureDetector(
                      onTap: () => {
                            if (globals.canVibrate)
                              {Vibrate.feedback(FeedbackType.selection)},
                            Navigator.pushNamed(context, '/gallery')
                          },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 3.0, color: Colors.white),
                            ),
                            color: Colors.black26,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: ListTile(
                                title: Text('Gallery',
                                    style: TextStyle(color: Colors.white)),
                                leading: Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 30.0,
                                  semanticLabel: 'Gallery',
                                ),
                              )),
                        ),
                      )),
                  GestureDetector(
                      onTap: () => {
                            if (globals.canVibrate)
                              {Vibrate.feedback(FeedbackType.selection)},
                            Navigator.pushNamed(context, '/alarms')
                          },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 3.0, color: Colors.white),
                            ),
                            color: Colors.black26,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: ListTile(
                              title: Text('Alarms',
                                  style: TextStyle(color: Colors.white)),
                              leading: Icon(
                                Icons.alarm,
                                color: Colors.white,
                                size: 30.0,
                                semanticLabel: 'Alarms',
                              ),
                            ),
                          ),
                        ),
                      )),
                  GestureDetector(
                      onTap: () => {
                            if (globals.canVibrate)
                              {Vibrate.feedback(FeedbackType.selection)},
                            Navigator.pushNamed(context, '/camera')
                          },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left:
                                    BorderSide(width: 3.0, color: Colors.white),
                              ),
                              color: Colors.black26,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: ListTile(
                                  title: Text('Camera',
                                      style: TextStyle(color: Colors.white)),
                                  leading: Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                    size: 30.0,
                                    semanticLabel: 'camera',
                                  ),
                                ))),
                      )),
                  GestureDetector(
                      onTap: () => {
                            if (globals.canVibrate)
                              {Vibrate.feedback(FeedbackType.selection)},
                            Navigator.pushNamed(context, '/movie_search')
                          },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left:
                                    BorderSide(width: 3.0, color: Colors.white),
                              ),
                              color: Colors.black26,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: ListTile(
                                  title: Text('Search Movies API',
                                      style: TextStyle(color: Colors.white)),
                                  leading: Icon(
                                    Icons.movie,
                                    color: Colors.white,
                                    size: 30.0,
                                    semanticLabel: 'Search movies',
                                  ),
                                ))),
                      )),
                ],
              ),
            )
          ],
        ),
      ));
    } else if (_authorized == 'Not Authorized') {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Authenticate'),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 30),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_supportState == _SupportState.unknown)
                    const CircularProgressIndicator()
                  else if (_supportState == _SupportState.supported)
                    const Text('This device is supported')
                  else
                    const Text('This device is not supported'),
                  const Divider(height: 100),
                  if (_isAuthenticating)
                    ElevatedButton(
                      onPressed: _cancelAuthentication,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          Text('Cancel Authentication'),
                          Icon(Icons.cancel),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: <Widget>[
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(20)),
                              shape: MaterialStateProperty.all<
                                      BeveledRectangleBorder>(
                                  BeveledRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20.0)),
                                      side: BorderSide(
                                        color: Colors.redAccent,
                                        width: 1,
                                      )))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                _isAuthenticating ? 'Cancel' : 'Authenticate',
                                style: TextStyle(fontSize: 14),
                              ),
                              const Icon(Icons.fingerprint),
                            ],
                          ),
                          onPressed: _authenticateWithBiometrics,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Utilities'),
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: Text(
              'You are not authorised and there seems to have been an error: ${_authorized}',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ));
    }
  }
}
