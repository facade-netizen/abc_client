import 'package:flutter/material.dart';

import 'colors.dart';

TextStyle customButtonStyle() {
  return const TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w900,
    color: black,
  );
}

TextStyle customAppBarTitleStyle() => const TextStyle(fontWeight: FontWeight.bold, color: secondaryClr,fontSize: 18);

TextStyle headerStyle(Color color) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: color,
  );
}

