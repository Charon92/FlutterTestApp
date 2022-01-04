import 'package:flutter/material.dart';

import 'package:audio_manager/audio_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicPlayer extends StatefulWidget {
  MusicPlayer({Key? key, required this.songs, required this.audioQuery}) : super(key: key);

  final List<SongModel> songs;
  final OnAudioQuery audioQuery;

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  double _slider = 0;
  bool isPlaying = false;
  double _sliderVolume = AudioManager.instance.volume;
  Duration _position = AudioManager.instance.position;
  Duration _duration = AudioManager.instance.duration;
  String _error = 'null';
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;

  @override
  void initState() {
    setupAudio();
    super.initState();
  }

  @override
  void dispose() {
    AudioManager.instance.release();
    super.dispose();
  }

  void setupAudio() {
    List<AudioInfo> _list = [];
    if ( widget.songs.isEmpty ) {
      _list.add(
        AudioInfo(
          'assets/music/CP Violation.mp3',
          title: 'CP Violation',
          desc: 'The song CP Violation from the Half-Life 2 Soundtrack',
          coverUrl: 'assets/images/700x700.png'
        )
      );
    } else {
      widget.songs.forEach((item) =>
          _list.add(AudioInfo(item.uri ?? item.data,
              title: item.title, desc: item.title,
              coverUrl: '')));
    }

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print(
              "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          AudioManager.instance.updateLrc("audio resource loading....");
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = 'null';
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          print('AudioManager received an error: ${args}');
          _error = args;
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: songProgress(context),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  icon: getPlayModeIcon(playMode),
                  onPressed: () {
                    playMode = AudioManager.instance.nextMode();
                    setState(() {});
                  }),
              IconButton(
                  iconSize: 36,
                  icon: Icon(
                    Icons.skip_previous,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => AudioManager.instance.previous()),
              IconButton(
                onPressed: () async {
                  print('Pressed play: ${AudioManager.instance.audioList[0]}');
                  bool playing = await AudioManager.instance.playOrPause();
                  print("await -- $playing");
                },
                padding: const EdgeInsets.all(0.0),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 48.0,
                  color: Colors.redAccent,
                ),
              ),
              IconButton(
                  iconSize: 36,
                  icon: Icon(
                    Icons.skip_next,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => AudioManager.instance.next()),
              IconButton(
                  icon: Icon(
                    Icons.stop,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => AudioManager.instance.stop()),
            ],
          ),
        ),
      ]),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.redAccent,
            width: 1.0
          )
        )
      ),
    );
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.redAccent,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.redAccent,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.redAccent,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.redAccent);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.redAccent,
                  overlayColor: Colors.red,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.redAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    Duration msec = Duration(
                        milliseconds:
                        (_duration.inMilliseconds * value).round());
                    AudioManager.instance.seekTo(msec);
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.redAccent,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}