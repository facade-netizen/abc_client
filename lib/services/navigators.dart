import 'package:flutter/material.dart';

Future<dynamic> pushByRemovingAll(BuildContext context, Widget newScreen) {
  return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => newScreen), (Route<dynamic> route) => false);
}

Future<dynamic> pushByReplacing(BuildContext context, Widget newScreen) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => newScreen),
  );
}

Future<dynamic> pushSimple(BuildContext context, Widget newScreen) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => newScreen),
  );
}

void removeScreen(BuildContext context) {
  return Navigator.of(context).pop();
}



