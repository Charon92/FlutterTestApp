import 'package:flutter/material.dart';

import '../api.dart';

extension DefaultMap<K,V> on Map<K,V> {
  V? getOrElse(K key, V defaultValue) {
    if (this.containsKey(key)) {
      return this[key];
    } else {
      return defaultValue;
    }
  }
}

Map<String, Map<String, Color>> genreColours = {
  'Horror': {
    'card': Colors.black,
    'text': Colors.white70
  },
  'Adventure': {
    'card': Colors.lightGreen,
    'text': Colors.black
  },
  'Comedy': {
    'card': Colors.yellow,
    'text': Colors.black87
  },
  'Sci-Fi': {
    'card': Colors.pink,
    'text': Colors.white
  },
  'Action': {
    'card': Colors.blue,
    'text': Colors.white
  },
  'Adult': {
    'card': Colors.redAccent,
    'text': Colors.white
  },
  'Documentary': {
    'card': Colors.green,
    'text': Colors.white
  },
  'Thriller': {
    'card': Colors.purple,
    'text': Colors.white
  }
};

Widget actorListWidgets(List<dynamic> strings, int count)
{
  return new GridView.count(
      crossAxisCount: count,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: strings.map(
              (item) => new Card(
                shadowColor: Colors.orangeAccent,
                elevation: 8,
                color: Colors.black,
                shape: BeveledRectangleBorder(
                    borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(20.0)),
                    side: BorderSide(
                      color: Colors.orangeAccent,
                      width: 1,
                    )
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    item['image'],
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
      ).toList());
}

List<Widget> genreListWidgets(List<dynamic> genres)
{
  return genres.map(
          (item) => new Card(
        color: genreColours.getOrElse(item['value'], {'card': Colors.white})!['card'],
        child: Container(
          padding: EdgeInsets.all(10),
          child: Text(
            item['value'],
            style: TextStyle(
              color: genreColours.getOrElse(item['value'], {'text': Colors.black})!['text'],
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      )
  ).toList();
}

class MoviePage extends StatefulWidget {
  MoviePage({Key? key, required this.movieId}) : super(key: key);

  final String movieId;

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late TextEditingController _controller;
  int count = 2;

  @override
  initState() {
    super.initState();
    _controller = TextEditingController();
  }

  getData() async {
    var service = ApiService();
    var newData = await service.getFullMovie(widget.movieId, []);
    return newData;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Movie Film'),
      ),
      body: FutureBuilder(
        builder: (ctx, snapshot) {
          // Checking if future is resolved or not
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occured',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final _data = snapshot.data as Map<dynamic, dynamic>;
              return Container(
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
                  child: Center(
                child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        constraints: new BoxConstraints.expand(
                          height: 300.0,
                        ),
                        padding: new EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
                        decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: NetworkImage(
                              _data['image'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                width: 380,
                                child: Card(
                                  shadowColor: Colors.orangeAccent,
                                  elevation: 8,
                                  color: Colors.black,
                                  shape: BeveledRectangleBorder(
                                    borderRadius:
                                    BorderRadius.only(bottomRight: Radius.circular(20.0)),
                                    side: BorderSide(
                                      color: Colors.orangeAccent,
                                      width: 1,
                                    )
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Title',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        _data['title'],
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          'Release Year',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white
                                                          )
                                                      ),
                                                      Text(
                                                          _data['year'],
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          )
                                                      )
                                                    ],
                                                  )
                                              ),
                                              Expanded(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          'Runtime',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          )
                                                      ),
                                                      Text(
                                                          _data['runtimeStr'] ?? 'Unknown',
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          )
                                                      )
                                                    ],
                                                  )
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              )
                            ]
                        ),
                        height: 500.0,
                      ),
                      Column(
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Plot', style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20
                                          ),),
                                          Divider(
                                            color: Colors.white,
                                            height: 20,
                                            thickness: 1,
                                          ),
                                          Text(_data['plot'])
                                        ]
                                    )
                                )]
                            ),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: genreListWidgets(_data['genreList'])
                                )
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    'Full Cast',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                                children: [actorListWidgets(_data['actorList'], count)]
                            )
                          ]
                      )
                    ]),
              ));
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Container(
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
          child: Center(
            child: CircularProgressIndicator(),
          ));
        },

        // Future that needs to be resolved
        // inorder to display something on the Canvas
        future: getData(),
      ),
    );
  }
}