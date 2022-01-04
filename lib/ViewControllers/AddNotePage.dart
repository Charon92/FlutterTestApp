import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../globals.dart' as globals;

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

import '../Models/Note.dart';
import 'AddTagPage.dart';

List<Widget> tagsWidgets(List<Tag> tags, List<Tag> selectedTags, callback) {
  if (tags.isNotEmpty) {
    return tags
        .map((item) => new GestureDetector(
              onTap: () {
                callback(item);
              },
              child: Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        width: 3.0,
                        color: selectedTags.contains(item)
                            ? Colors.grey
                            : Color(int.parse(item.colour, radix: 16))
                    ),
                  ),
                ),
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: selectedTags.contains(item)
                        ? Colors.grey
                        : Color(int.parse(item.colour, radix: 16)),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ))
        .toList();
  } else {
    return [
      Card(
        color: Colors.grey,
        child: Text('No tags!'),
      )
    ];
  }
}

class AddNote extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final format = DateFormat("yyyy-MM-dd");

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late Box<Note> notesBox;
  late Box<Tag> tagsBox;
  late List<Tag> allTags;

  Uuid uuid = Uuid();
  bool _canVibrate = false;

  late String id;
  late String title;
  late String content;
  late DateTime date_created;
  late DateTime date_last_edited;
  late int is_archived = 0;
  List<Tag> tags = [];

  getTags() async {
    tagsBox = Hive.box<Tag>('tags');
    setState(() {
      allTags = tagsBox.values.toList();
    });
    return allTags;
  }

  Future<void> _init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? debugPrint('This device can vibrate')
          : debugPrint('This device cannot vibrate');
    });
  }

  void _updateTitle() {
    title = _titleController.text;
  }

  void _updateContent() {
    content = _contentController.text;
  }

  void _addTagToList(Tag tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    } else {
      tags.remove(tag);
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    _titleController.addListener(_updateTitle);
    _contentController.addListener(_updateContent);
    notesBox = Hive.box<Note>('notes');
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void onFormSubmit() {
    if (widget.formKey.currentState!.validate()) {
      String id = uuid.v4();
      Note newNote = Note(id, title, content, date_created, date_last_edited,
          HiveList(tagsBox));
      notesBox.add(newNote);
      if (tags.isNotEmpty) {
        newNote.tags.addAll(tags);
      }
      newNote.save();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      builder: (ctx, snapshot) {
        // Checking if future is resolved or not
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Container(
                decoration: MainScaffoldDecoration(),
                child: Column(
                  children: [
                    MainBodyAppBar('Add Note', context, [
                      IconButton(
                          icon: Icon(Icons.add_circle),
                          tooltip: 'Create new Tag',
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddTag()));
                          })
                    ]),
                    Center(
                      child: Text(
                        '${snapshot.error} occured',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ));

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final allTags = snapshot.data as List<Tag>;
            return Container(
                height: double.maxFinite,
                decoration: MainScaffoldDecoration(),
                child: Column(children: [
                  MainBodyAppBar('Add Note', context, [
                    IconButton(
                        icon: Icon(Icons.add_circle),
                        tooltip: 'Create new Tag',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddTag()));
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
                                  controller: _titleController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                      labelText: "Title",
                                      labelStyle:
                                          TextStyle(color: Colors.white)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: TextFormField(
                                  controller: _contentController,
                                  style: TextStyle(color: Colors.white),
                                  minLines: null,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      labelText: "Content",
                                      labelStyle:
                                          TextStyle(color: Colors.white)),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.all(15),
                                  child: DateTimeField(
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
                                          initialDate:
                                              currentValue ?? DateTime.now(),
                                          lastDate: DateTime(2100));
                                    },
                                    onChanged: (date) {
                                      setState(() {
                                        date_created = date!;
                                      });
                                    },
                                  )),
                              Padding(
                                  padding: EdgeInsets.all(15),
                                  child: DateTimeField(
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
                                          initialDate:
                                              currentValue ?? DateTime.now(),
                                          lastDate: DateTime(2100));
                                    },
                                    onChanged: (date) {
                                      setState(() {
                                        date_last_edited = date!;
                                      });
                                    },
                                  )),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: tagsWidgets(
                                          allTags, tags, _addTagToList))),
                              SizedBox(height: 30),
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
                ]));
          }
        }

        return Container(
            height: double.maxFinite,
            decoration: MainScaffoldDecoration(),
            child: Column(children: [
              MainBodyAppBar('Add Note', context, [
                IconButton(
                    icon: Icon(Icons.add_circle),
                    tooltip: 'Create new Tag',
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => AddTag()));
                    })
              ]),
              Center(
                child: CircularProgressIndicator(),
              )
            ]));
      },
      // Future that needs to be resolved
      // inorder to display something on the Canvas
      future: getTags(),
    ));
  }
}
