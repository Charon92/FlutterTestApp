import '../globals.dart' as globals;

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Models/Note.dart';
import 'AddNotePage.dart';
import 'NotePage.dart';

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

class NotesPage extends StatefulWidget {
  NotesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late Box<Note> notesBox;

  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    notesBox = Hive.box('notes');
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ValueListenableBuilder(
          valueListenable: notesBox.listenable(),
          builder: (context, Box<Note> box, _) {
            if (box.values.isEmpty)
              return Container(
                  height: double.maxFinite,
                  decoration: MainScaffoldDecoration(),
                  child: Column(
                    children: [
                      MainBodyAppBar(widget.title, context, null),
                      Center(child: Text("No Notes"))
                    ],
                  ));
            return Container(
                height: double.maxFinite,
                decoration: MainScaffoldDecoration(),
                child: Column(
                  children: [
                    MainBodyAppBar(widget.title, context, null),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(25),
                        controller: _scrollController,
                        itemCount: box.values.length,
                        itemBuilder: (context, index) {
                          Note? currentNote = box.getAt(index);
                          return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(width: 3.0, color: Colors.white),
                                ),
                                color: Colors.black26,
                              ),
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: ListTile(
                                    onTap: () => {
                                      if (globals.canVibrate)
                                        {Vibrate.feedback(FeedbackType.selection)},
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>
                                              NotePage(noteId: index)))
                                    },
                                    title: Text(
                                      currentNote?.title ?? 'No Title',
                                      style: Theme.of(context).textTheme.headline1
                                    ),
                                    subtitle: Text(
                                      currentNote?.content.replaceRange(
                                          9, currentNote.content.length, '...') ??
                                          'No content',
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Text(
                                              "Do you want to delete ${currentNote?.title}?",
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
                                                  await box.deleteAt(index);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )
                              ),
                            margin: EdgeInsets.only(bottom: 15.0),
                          );
                        },
                      )
                    )
                  ],
                ));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: Builder(builder: (context) {
          return Stack(children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => AddNote()));
                },
              ),
            )
          ]);
        }));
  }
}
