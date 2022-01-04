import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

Widget generateQueueList(
  List<SongModel> queue
) {
  return ListView.builder(
    itemCount: queue.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 3.0, color: Colors.orangeAccent.shade700),
              ),
              color: Colors.black26,
            ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: ListTile(
              title: Text(
                queue[index].title,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                queue[index].artist ?? "No Artist",
                style: TextStyle(color: Colors.white),
              ),
              // This Widget will query/load image. Just add the id and type.
              // You can use/create your own widget/method using [queryArtwork].
              leading: QueryArtworkWidget(
                id: queue[index].id,
                type: ArtworkType.AUDIO,
              ),
            )
          ),
          margin: EdgeInsets.only(bottom: 15.0),
        );
      }
  );
}