import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

Widget generateSongList(
    OnAudioQuery _audioQuery, _addCallback, _addFirstCallback,
    {sortType: null, orderType: OrderType.ASC_OR_SMALLER, uriType: UriType.EXTERNAL}
    ) {

  return FutureBuilder<List<SongModel>>(
    // Default values:
    future: _audioQuery.querySongs(
      sortType: sortType,
      orderType: orderType,
      uriType: uriType,
      ignoreCase: true,
    ),
    builder: (context, item) {
      // Loading content
      if (item.data == null) return const CircularProgressIndicator();

      // When you try "query" without asking for [READ] or [Library] permission
      // the plugin will return a [Empty] list.
      if (item.data!.isEmpty) return const Text("Nothing found!");

      // You can use [item.data!] direct or you can create a:
      // List<SongModel> songs = item.data!;
      return ListView.builder(
        itemCount: item.data!.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 3.0, color: Colors.redAccent.shade700),
                ),
                color: Colors.black26,
              ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListTile(
                title: Text(
                  item.data![index].title,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  item.data![index].artist ?? "No Artist",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: GestureDetector(
                  onDoubleTap: () {
                    _addFirstCallback(item.data![index]);
                  },
                  child: Icon(Icons.play_arrow, color: Colors.redAccent.shade700,),
                ),
                // This Widget will query/load image. Just add the id and type.
                // You can use/create your own widget/method using [queryArtwork].
                leading: QueryArtworkWidget(
                  id: item.data![index].id,
                  type: ArtworkType.AUDIO,
                ),
              )
            ),
            margin: EdgeInsets.only(bottom: 15.0),
          );
        },
      );
    },
  );
}
