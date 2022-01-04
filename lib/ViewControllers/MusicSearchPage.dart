import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

List<Widget> checkResults(List<dynamic> results, context, Function callback) {
  if (results.isEmpty) {
    return [
      Center(
          child: Card(
              shadowColor: Colors.redAccent,
              elevation: 8,
              color: Colors.black,
              shape: BeveledRectangleBorder(
                  borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(20.0)),
                  side: BorderSide(
                    color: Colors.redAccent,
                    width: 1,
                  )),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'No values, have you made a query yet?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
          )
      )
    ];
  } else {
    return results.map((item) {
      return Card(
          shadowColor: Colors.redAccent,
          elevation: 5,
          color: Colors.black,
          shape: BeveledRectangleBorder(
              borderRadius:
              BorderRadius.only(bottomRight: Radius.circular(20.0)),
              side: BorderSide(
                color: Colors.redAccent,
                width: 1,
              )),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: ListTile(
                title: Text(
                  item.title,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  item.artist ?? "No Artist",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: GestureDetector(
                  onDoubleTap: () {
                    callback(item);
                  },
                  child: Icon(Icons.play_arrow, color: Colors.redAccent,),
                ),
                // This Widget will query/load image. Just add the id and type.
                // You can use/create your own widget/method using [queryArtwork].
                leading: QueryArtworkWidget(
                  id: item.id,
                  type: ArtworkType.AUDIO,
                ),
              )
          )
      );
    }).toList();
  }
}

class MusicSearchPage extends StatefulWidget {
  MusicSearchPage({Key? key, required this.callback, required this.audioQuery}) : super(key: key);

  final Function callback;
  final OnAudioQuery audioQuery;

  @override
  _MusicSearchPageState createState() => _MusicSearchPageState();
}

class _MusicSearchPageState extends State<MusicSearchPage> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  List<dynamic> results = [];
  bool _canVibrate = true;

  Future<void> _init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? debugPrint('This device can vibrate')
          : debugPrint('This device cannot vibrate');
    });
  }

  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void filterSongs(String value) async {
    List<dynamic> new_results = await widget.audioQuery.queryWithFilters(
      value,
      WithFiltersType.AUDIOS,
      args: AudiosArgs.ARTIST,
    );
    setState(() {
      results = new_results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Search Page',
          style: TextStyle(
            color: Colors.redAccent
          ),
        ),
      ),
      body: Container(
          height: double.maxFinite,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  const Color(0xFF2D2D2D),
                  const Color(0xFF1D1D1D),
                  const Color(0xFF000000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(15.0),
                  children: checkResults(results, context, widget.callback)),
              Positioned(
                  bottom: 0,
                  left: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border(
                          top: BorderSide(width: 1, color: Colors.redAccent)),
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
                        filterSongs(value);
                      },
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          prefixIconColor: Colors.redAccent,
                          border: InputBorder.none,
                          hintText: 'Jurassic Park',
                          hintStyle: TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic),
                          contentPadding: EdgeInsets.all(10.0)),
                    ),
                  )
              )
            ],
          )),
    );
  }

}