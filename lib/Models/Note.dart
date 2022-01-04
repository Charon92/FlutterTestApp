import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'Note.g.dart';

@HiveType(typeId: 1)
class Tag extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String colour;

  Tag(this.name, this.colour);
}

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime date_created;

  @HiveField(4)
  DateTime date_last_edited;

  @HiveField(5)
  int is_archived = 0;

  @HiveField(6)
  HiveList<Tag> tags;

  Note(this.id, this.title, this.content, this.date_created, this.date_last_edited, this.tags);

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
//      'id': id,  since id is auto incremented in the database we don't need to send it to the insert query.
      'title': utf8.encode(title),
      'content': utf8.encode(content),
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'is_archived': is_archived
      //  for later use for integrating archiving
    };
    if (forUpdate) {
      data["id"] = this.id;
    }
    return data;
  }

// Converting the date time object into int representing seconds passed after midnight 1st Jan, 1970 UTC
  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  void archiveThisNote() {
    is_archived = 1;
  }

// overriding toString() of the note class to print a better debug description of this custom class
  @override
  toString() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'is_archived': is_archived
    }.toString();
  }
}
