import 'package:http/io_client.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

import 'globals.dart' as globals;


class ApiService {
  Future<List<dynamic>> getMovie(String movie) async {
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);

    Uri uri = Uri.https('imdb-api.com', '/en/API/SearchTitle/' + globals.apiKey + '/' + movie);

    print('URI: ' + uri.path);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var results = data['results'];
      List<Map> posts = List<Map>.from(results.map( (model) => model) );
      return posts;
    } else {
      return [{"Request failed with status code: " + response.statusCode.toString()}];
    }
  }

  Future<List<dynamic>> getActor(String actor) async {
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);

    Uri uri = Uri.https('imdb-api.com', '/en/API/SearchName/' + globals.apiKey + '/' + actor);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var results = data['results'];
      List<Map> posts = List<Map>.from(results.map( (model) => model) );
      return posts;
    } else {
      return [{"Request failed with status code: " + response.statusCode.toString()}];
    }
  }

  Future<Map<String, dynamic>> getFullMovie(String movieId, List<String>? options) async {
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = new IOClient(ioc);

    Uri uri = Uri.https(
        'imdb-api.com',
        '/en/API/Title/' + globals.apiKey + '/' + movieId + '/FullActor,FullCast,Ratings'
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      return {'response': "Request failed with status code: " + response.statusCode.toString()};
    }
  }
}