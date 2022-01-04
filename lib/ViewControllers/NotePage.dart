import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../globals.dart' as globals;


import '../Models/Note.dart';
import 'EditNotePage.dart';

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

List<Widget> buildActions(context, int noteId, Note note, Box notesBox) {
  return [
    IconButton(
        icon: Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  "Do you want to delete ${note.title}?",
                ),
                actions: <Widget>[
                  MaterialButton(
                    child: Text("No"),
                    onPressed: () =>
                        Navigator.of(context).pop(),
                  ),
                  MaterialButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      await notesBox.deleteAt(noteId);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }),
    IconButton(
        icon: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditNotePage(
                noteId: noteId,
              )));
        })
  ];
}

List<Widget> tagsWidgets(List<Tag> tags) {
  if (tags.isNotEmpty) {
    return tags
        .map((item) => new Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 3.0, color: Color(int.parse(item.colour, radix: 16))),
                  ),
                ),
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Color(int.parse(item.colour, radix: 16)),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            )
        .toList();
  } else {
    return [
      Card(
        color: Colors.purpleAccent,
        child: Text('No tags!'),
      )
    ];
  }
}

class NotePage extends StatefulWidget {
  NotePage({Key? key, required this.noteId}) : super(key: key);

  final int noteId;

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  Box<Note> notesBox = Hive.box('notes');
  Box<Tag> _tagsBox = Hive.box('tags');
  late ScrollController _scrollController;

  getNote() async {
    return await notesBox.getAt(widget.noteId);
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        // Checking if future is resolved or not
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Container(
                height: double.maxFinite,
                decoration: MainScaffoldDecoration(),
                child: Column(
                  children: [
                    MainBodyAppBar('Error occurred', context, null),
                    Expanded(
                        child: Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                    )
                  ],
                )
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final note = snapshot.data as Note;
            return Scaffold(
                body: Container(
                    height: double.maxFinite,
                    decoration: MainScaffoldDecoration(),
                    child: Column(
                      children: [
                        MainBodyAppBar(note.title, context, buildActions(context, widget.noteId, note, notesBox)),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(10.0),
                              controller: _scrollController,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        'Content',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Markdown(
                                      shrinkWrap: true,
                                      data: note.content,
                                      styleSheet: MarkdownStyleSheet(
                                        h1: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text('Date Created',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(note.date_created.toString()),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text('Date Last Edited',
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(note.date_last_edited.toString())
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: tagsWidgets(note.tags))),
                              ],
                          )
                        )
                      ]
                    )
                )
            );
          }
        }

        return Container(
            height: double.maxFinite,
            decoration: MainScaffoldDecoration(),
            child: Column(
              children: [
                MainBodyAppBar('Loading...', context, null),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            )
        );
      },
      // Future that needs to be resolved
      // inorder to display something on the Canvas
      future: getNote(),
    );
  }
}
