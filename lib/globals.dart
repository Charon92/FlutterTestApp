library FlutterTest.globals;

import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

bool canVibrate = false;
List<CameraDescription>? cameras;
CameraDescription? camera;
String apiKey = dotenv.env['IMDB_MOVIE_API_KEY'] ?? 'a_b4r9k7bv';