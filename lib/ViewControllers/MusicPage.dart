import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../globals.dart' as globals;

import '../Components/SongList.dart';
import '../Components/ArtistList.dart';
import '../Components/AlbumList.dart';
import '../Components/MusicPlayer.dart';
import '../Components/Queue.dart';
import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

import 'MusicSearchPage.dart';

List<Widget> buildActions(context, OnAudioQuery audioQuery, Function callback,
    bool canVibrate, Function sortCallback, Function orderCallback) {
  return [
    IconButton(
        onPressed: () =>
        {
          if (canVibrate) {Vibrate.feedback(FeedbackType.selection)},
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  MusicSearchPage(
                      callback: callback,
                      audioQuery: audioQuery
                  )
          ))
        },
        icon: Icon(Icons.search),
        color: Colors.redAccent
    ),
    IconButton(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20.0)),
                  side: BorderSide(
                    color: Colors.redAccent,
                    width: 1,
                  )),
              scrollable: true,
              title: Text(
                'Select filters and ordering',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0
                ),
              ),
              titleTextStyle: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JetBrains'
              ),
              contentTextStyle: TextStyle(
                  color: Colors.redAccent
              ),
              content: new SingleChildScrollView(
                child: new MyDialogContent(sortCallback: sortCallback, orderCallback: orderCallback,),
              ),
              actions: <Widget>[
                MaterialButton(
                    color: Colors.redAccent,
                    child: Text("Filter"),
                    onPressed: () => print('PRESSED YES')
                ),
              ],
            );
          },
        );
      },
      icon: Icon(
        Icons.filter_alt,
        color: Colors.redAccent,
      ),
    )
  ];
}


class MusicPage extends StatefulWidget {
  MusicPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final PageController controller = PageController();
  int _selectedIndex = 0;
  List<SongModel> queue = [];
  bool _canVibrate = globals.canVibrate;
  SongSortType songSortType = SongSortType.TITLE;
  OrderType songOrderType = OrderType.ASC_OR_SMALLER;
  UriType songUriType = UriType.EXTERNAL;

  void addSongToTopOfQueue(SongModel song) {
    print('Added ${song.title} to top of queue');
    AudioManager.instance.audioList.insert(
        0, AudioInfo(song.uri ?? song.data,
        title: song.title, desc: song.title,
        coverUrl: '')
    );
  }

  void addSongToQueue(SongModel song) {
    print('Added ${song.title} to queue');
    AudioManager.instance.audioList.add(
        AudioInfo(song.data,
        title: song.title, desc: song.title,
        coverUrl: '')
    );
    queue.add(song);
  }

  void addMultipleSongsToQueue(List<SongModel> songs) {
    songs.forEach((item) =>
        AudioManager.instance.audioList.add(AudioInfo(item.uri ?? item.data,
            title: item.title, desc: item.title,
            coverUrl: '')));
  }

  void clearQueue() {
    print('Clearing queue');
    queue.clear();
  }

  void sortCallback(SongSortType sortType) {
    setState(() {
      songSortType = sortType;
    });
  }

  void orderCallback(OrderType orderType) {
    setState(() {
      songOrderType = orderType;
    });
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      controller.animateToPage(_selectedIndex,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    });
  }

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: MainScaffoldDecoration(),
        child: Column(
          children: [
            MainBodyAppBar(
                widget.title,
                context,
                buildActions(context, _audioQuery, addSongToTopOfQueue,
                    _canVibrate, sortCallback, orderCallback)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView(
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      controller: controller,
                      children: [
                        generateSongList(_audioQuery, addSongToQueue, addSongToTopOfQueue),
                        generateArtistList(_audioQuery),
                        // generateAlbumList(_audioQuery),
                        generateQueueList(queue),
                      ],
                      physics: PageScrollPhysics(),
                    ),
                  ],
                )
            )),
            MusicPlayer(songs: queue, audioQuery: _audioQuery,)
          ]
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
              label: 'Songs',
              icon: Icon(Icons.music_note, color: Colors.redAccent),
              activeIcon: Icon(
                Icons.music_note,
                color: Colors.red,
              )),
          BottomNavigationBarItem(
            label: 'Artists',
            icon: Icon(Icons.person, color: Colors.redAccent),
            activeIcon: Icon(
              Icons.person,
              color: Colors.red,
            ),
          ),
          // BottomNavigationBarItem(
          //   label: 'Albums',
          //   icon: Icon(Icons.library_music, color: Colors.redAccent),
          //   activeIcon: Icon(
          //     Icons.library_music,
          //     color: Colors.red,
          //   ),
          // ),
          BottomNavigationBarItem(
            label: 'Queue',
            icon: Icon(Icons.queue_music, color: Colors.redAccent),
            activeIcon: Icon(
              Icons.library_music,
              color: Colors.red,
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        iconSize: 25,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyDialogContent extends StatefulWidget {
  MyDialogContent({
    Key? key,
    required this.sortCallback,
    required this.orderCallback
  }): super(key: key);

  final Function sortCallback;
  final Function orderCallback;

  @override
  _MyDialogContentState createState() => new _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  List<SongSortType> _allSongSortTypes = [
    SongSortType.ARTIST,
    SongSortType.ALBUM,
    SongSortType.DATE_ADDED,
    SongSortType.DISPLAY_NAME,
    SongSortType.DURATION,
    SongSortType.SIZE,
    SongSortType.TITLE
  ];
  SongSortType _selectedSortType = SongSortType.ARTIST;
  OrderType _selectedOrderType = OrderType.ASC_OR_SMALLER;

  @override
  void initState(){
    super.initState();
  }

  _getContent(){
    if (_allSongSortTypes.length == 0){
      return new Container();
    }

    return new Column(
        children: new List<RadioListTile<SongSortType>>.generate(
            _allSongSortTypes.length,
                (int index){
              return new RadioListTile<SongSortType>(
                activeColor: Colors.redAccent,
                selectedTileColor: Colors.redAccent,
                value: _allSongSortTypes[index],
                groupValue: _selectedSortType,
                title: new Text(
                  _allSongSortTypes[index].toString(),
                  style: TextStyle(
                      color: Colors.redAccent
                  ),
                ),
                onChanged: (value) {
                  setState((){
                    _selectedSortType = value!;
                  });
                },
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}