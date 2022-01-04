import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../globals.dart' as globals;

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

import '../Models/Note.dart';
import 'NotePage.dart';

class EditNotePage extends StatefulWidget {
  EditNotePage({Key? key, required this.noteId}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final int noteId;

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _controller;
  late Box<Note> notesBox;
  bool _canVibrate = globals.canVibrate;

  final format = DateFormat("yyyy-MM-dd");
  Uuid uuid = Uuid();

  late String id;
  late String title;
  late String content;
  late DateTime date_created;
  late DateTime date_last_edited;
  late int is_archived = 0;
  late HiveList<Tag> tags;

  void onFormSubmit() {
    if (widget.formKey.currentState!.validate()) {
      String id = uuid.v4();
      Box<Note> notesBox = Hive.box<Note>('notes');
      notesBox.putAt(widget.noteId,
          Note(id, title, content, date_created, date_last_edited, tags));
      Navigator.of(context).pop();
    }
  }

  getNote() async {
    return await notesBox.getAt(widget.noteId);
  }

  @override
  void initState() {
    _controller = TextEditingController();
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
    return FutureBuilder(
      builder: (ctx, snapshot) {
        // Checking if future is resolved or not
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Container(
                height: double.maxFinite,
                decoration: MainScaffoldDecoration(),
                child: Column(children: [
                  MainBodyAppBar('Edit Note', context, []),
                  Center(
                    child: Text(
                      '${snapshot.error} occured',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ]));

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final note = snapshot.data as Note;
            return Scaffold(
                body: Container(
                    height: double.maxFinite,
                    decoration: MainScaffoldDecoration(),
                    child: Column(children: [
                      MainBodyAppBar('Editing ${note.title}', context, [
                        IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text(
                                      "Do you want to cancel editing ${note.title}?",
                                    ),
                                    actions: <Widget>[
                                      MaterialButton(
                                        child: Text("Yes"),
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => NotePage(
                                                      noteId: widget.noteId,
                                                    ))),
                                      ),
                                      MaterialButton(
                                        child: Text("No"),
                                        onPressed: () => Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(),
                                      ),
                                    ],
                                  );
                                },
                              );
                            })
                      ]),
                      SafeArea(
                        child: SingleChildScrollView(
                          child: Form(
                            key: widget.formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(15),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      initialValue: note.title,
                                      decoration: const InputDecoration(
                                          labelText: "Title",
                                          labelStyle:
                                              TextStyle(color: Colors.white)),
                                      onChanged: (value) {
                                        setState(() {
                                          title = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(15),
                                    child: TextFormField(
                                      style: TextStyle(color: Colors.white),
                                      initialValue: note.content,
                                      minLines: null,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                          labelText: "Content",
                                          labelStyle:
                                              TextStyle(color: Colors.white)),
                                      onChanged: (value) {
                                        setState(() {
                                          content = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(15),
                                      child: DateTimeField(
                                        enabled: false,
                                        initialValue: note.date_created,
                                        style: TextStyle(color: Colors.white),
                                        format: format,
                                        decoration: const InputDecoration(
                                            labelText: "Date Created",
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                              color: Colors.tealAccent,
                                            )),
                                        onShowPicker: (context, currentValue) {
                                          return showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2100));
                                        },
                                        onChanged: (date) {
                                          setState(() {
                                            date_created = note.date_created;
                                          });
                                        },
                                      )),
                                  Padding(
                                      padding: EdgeInsets.all(15),
                                      child: DateTimeField(
                                        initialValue: note.date_last_edited,
                                        style: TextStyle(color: Colors.white),
                                        format: format,
                                        decoration: const InputDecoration(
                                            labelText: "Last Edited",
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                              color: Colors.tealAccent,
                                            )),
                                        onShowPicker: (context, currentValue) {
                                          return showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2100));
                                        },
                                        onChanged: (date) {
                                          setState(() {
                                            date_last_edited = date!;
                                          });
                                        },
                                      )),
                                  MaterialButton(
                                    color: Colors.tealAccent,
                                    child: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    onPressed: onFormSubmit,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ])));
          }
        }

        return Container(
            height: double.maxFinite,
            decoration: MainScaffoldDecoration(),
            child: Column(children: [
              MainBodyAppBar('Edit Note', context, []),
              Center(
                child: CircularProgressIndicator(),
              )
            ]));
      },
      // Future that needs to be resolved
      // inorder to display something on the Canvas
      future: getNote(),
    );
  }
}
