import 'package:flutter/material.dart';

MaterialButton blackMaterialButtons(VoidCallback fxn, Widget child,
    {double rad = 5.0, double width = double.infinity}) {
  return MaterialButton(
    onPressed: () {
      fxn.call();
    },
    child: child,
    minWidth: width,
    elevation: 0.0,
    focusElevation: 0.0,
    highlightElevation: 0.0,
    color: Colors.black,
    textColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rad)),
  );
}
