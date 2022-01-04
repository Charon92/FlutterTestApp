import '../globals.dart' as globals;

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'MoviePage.dart';
import '../api.dart';

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

List<Widget> checkResults(List<dynamic> results, context, bool canVibrate) {
  if (results.isEmpty) {
    return [
      Center(
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left:
                      BorderSide(width: 3.0, color: Colors.white),
                ),
                color: Colors.black26,
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'No values, have you made a query yet?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )))
    ];
  } else {
    return results.map((result) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 3.0, color: Colors.white),
          ),
          color: Colors.black26,
        ),
        child: GestureDetector(
          onTap: () => {
            if (canVibrate) {Vibrate.feedback(FeedbackType.selection)},
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    MoviePage(movieId: result['id'].toString())))
          },
          child: Row(
            children: [
              Image.network(result['image'],
                  height: 100, fit: BoxFit.fitHeight),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  result['title'],
                  style: Theme.of(context).textTheme.headline2,
                ),
              )
            ],
          ),
        ),
        margin: EdgeInsets.only(bottom: 15.0),
      );
    }).toList();
  }
}

class MovieSearchPage extends StatefulWidget {
  MovieSearchPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  List<dynamic> results = [];

  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getMovies(String value) async {
    var service = ApiService();
    var new_results = await service.getMovie(value);
    setState(() {
      results = new_results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: double.maxFinite,
      decoration: MainScaffoldDecoration(),
      child: Column(
        children: [
          MainBodyAppBar(widget.title, context, null),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(15.0),
                    children:
                        checkResults(results, context, globals.canVibrate)),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        border: Border(
                            top: BorderSide(
                                width: 2, color: Colors.white)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        autofocus: true,
                        controller: _controller,
                        onSubmitted: (String value) async {
                          getMovies(value);
                        },
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: new InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            prefixIconColor: Colors.white,
                            border: InputBorder.none,
                            hintText: 'Jurassic Park',
                            hintStyle: TextStyle(
                                color: Colors.redAccent.shade700,
                                fontStyle: FontStyle.italic),
                            contentPadding: EdgeInsets.all(10.0)),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    ));
  }
}
