import 'package:flutter/material.dart';

Widget errorWidget(IconData? icon, String? reason) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        icon == null
            ? const Icon(Icons.error, color: Colors.red)
            : Icon(icon, color: Colors.red),
        const SizedBox(width: 10.0),
        reason == null
            ? const Text("\tSomething went wrong, please retry.")
            : Text(reason),
      ],
    ),
  );
}
