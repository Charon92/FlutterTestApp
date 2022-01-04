import 'package:flutter/material.dart';

/// Used to build the main AppBar instance that sits INSIDE the main body
/// Container so that it floats above the background. Actions can be null.
Widget MainBodyAppBar(String title, context, List<Widget>? actions) {
  return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.headline1
        ),
        shape: Border(
            bottom: BorderSide(
                color: Colors.redAccent.shade700,
                width: 2.0
            )
        ),
        actions: actions,
      )
  );
}