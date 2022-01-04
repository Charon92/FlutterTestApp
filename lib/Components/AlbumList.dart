import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

Widget generateAlbumList(OnAudioQuery _audioQuery) {
  return FutureBuilder<List<AlbumModel>>(
    // Default values:
    future: _audioQuery.queryAlbums(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
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
          return Card(
              shadowColor: Colors.blueAccent,
              elevation: 5,
              color: Colors.black,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20.0)),
                  side: BorderSide(
                    color: Colors.blueAccent,
                    width: 1,
                  )),
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: ListTile(
                    title: Text(
                      item.data![index].album,
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    subtitle:
                    Text(
                      item.data![index].artist ?? 'Unknown Artist',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    // This Widget will query/load image. Just add the id and type.
                    // You can use/create your own widget/method using [queryArtwork].
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                    ),
                  )
              )
          );
        },
      );
    },
  );
}