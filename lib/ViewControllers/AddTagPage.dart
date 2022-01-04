import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:select_form_field/select_form_field.dart';

import '../globals.dart' as globals;

import '../Components/ScaffoldDecoration.dart';
import '../Components/MainBodyAppBar.dart';

import '../Models/Note.dart';

final List<Map<String, dynamic>> _colours = [
  {
    'value': Colors.tealAccent.toString(),
    'label': 'Teal',
    'icon': Icon(
      Icons.invert_colors_on_sharp,
      color: Colors.tealAccent,
    ),
  },
  {
    'value': Colors.purpleAccent.toString(),
    'label': 'Purple',
    'icon': Icon(
      Icons.invert_colors_on_sharp,
      color: Colors.purpleAccent,
    ),
  },
  {
    'value': Colors.deepOrangeAccent.toString(),
    'label': 'Orange',
    'icon': Icon(
      Icons.invert_colors_on_sharp,
      color: Colors.deepOrangeAccent,
    ),
  },
  {
    'value': Colors.redAccent.toString(),
    'label': 'Red',
    'icon': Icon(
      Icons.invert_colors_on_sharp,
      color: Colors.redAccent,
    ),
  },
];

class AddTag extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  @override
  _AddTagState createState() => _AddTagState();
}

class _AddTagState extends State<AddTag> {
  late String name;
  late String colour;
  late Box tagsBox;

  String selectedColourValue = Colors.deepOrangeAccent.toString();
  IconData selectedColourIcon = Icons.invert_colors_on_sharp;

  void onFormSubmit() {
    if (widget.formKey.currentState!.validate()) {
      Box<Tag> tagsBox = Hive.box<Tag>('tags');
      tagsBox.add(Tag(name, colour));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        height: double.maxFinite,
        decoration: MainScaffoldDecoration(),
        child: Column(
        children: [
          MainBodyAppBar('Add New Tag', context, []),
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
                          autofocus: true,
                          initialValue: "",
                          decoration: const InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(color: Colors.white)),
                          onChanged: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: SelectFormField(
                            type: SelectFormFieldType.dropdown,
                            style: TextStyle(color: Colors.white),
                            initialValue: selectedColourValue,
                            icon: Icon(
                              selectedColourIcon,
                              color: Color(int.parse(
                                  selectedColourValue
                                      .split('(0x')[1]
                                      .split(')')[0],
                                  radix: 16)),
                            ),
                            labelText: 'Colour',
                            items: _colours,
                            onChanged: (val) {
                              setState(() {
                                selectedColourValue = val;
                                String valString =
                                    val.split('(0x')[1].split(')')[0];
                                colour = valString;
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
          ]),
        ));
  }
}
