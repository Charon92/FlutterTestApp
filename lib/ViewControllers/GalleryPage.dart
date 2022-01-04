import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../globals.dart' as globals;

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

const double cardBorderWidth = 2;

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  final Future<String?> videoFile;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool initialized = false;

  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  void initVideo() async {
    var video = await widget.videoFile;
    if ( video != null ) {
      setState(() {
        initialized = true;
        print(video);
        player.setDataSource(
            video, autoPlay: false, showCover: true);
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialized
      // If the video is initialized, display it
          ? Scaffold(
        body: Center(
          child: FijkView(
            player: player,
            color: Colors.black,
          ),
        ),
      )
      // If the video is not yet initialized, display a spinner
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class ImageScreen extends StatelessWidget {
  const ImageScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  final Future<File?> imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: FutureBuilder<File?>(
        future: imageFile,
        builder: (_, snapshot) {
          final file = snapshot.data;
          if (file == null) return Container();
          return Image.file(file);
        },
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
    required this.canVibrate
  }) : super(key: key);

  final AssetEntity asset;
  final bool canVibrate;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: asset.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            if (canVibrate) {Vibrate.feedback(FeedbackType.selection);}
            if (asset.type == AssetType.image) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageScreen(imageFile: asset.file),
                ),
              );
            } else {
              // if it's not, navigate to VideoScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoScreen(videoFile: asset.getMediaUrl()),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 3.0, color: Colors.redAccent.shade700),
              ),
              color: Colors.black26,
            ),
            child: Stack(
              children: [
                // Wrap the image in a Positioned.fill to fill the space
                Positioned.fill(
                  child: Image.memory(bytes, fit: BoxFit.cover),
                ),
                // Display a Play icon if the asset is a video
                if (asset.type == AssetType.video)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.redAccent.shade700,
                      ),
                    )
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget generateGalleryGrid(List<AssetEntity> assets, bool canVibrate) {
    return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 25, right: 25),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20
            ),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              return AssetThumbnail(asset: assets[index], canVibrate: canVibrate,);
            },
          ),
        )
    );
}

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late List<AssetPathEntity> albums;
  List<AssetEntity> assets = [];
  late File? imageUri;
  late var albumAssets;
  bool _canVibrate = globals.canVibrate;

  void _init() async {

    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      await _fetchAssets();
    } else {
      PhotoManager.openSetting();
    }
  }

  _fetchAssets() async {
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: MainScaffoldDecoration(),
        child: Column(
          children: [
            MainBodyAppBar('Image Gallery', context, null),
            generateGalleryGrid(assets, _canVibrate)
          ]
        )
      )
    );
  }

}