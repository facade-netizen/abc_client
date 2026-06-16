import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_font_size.dart';

FontWeight normal = FontWeight.w500;
FontWeight font7 = FontWeight.w700;
FontWeight bold = FontWeight.bold;

TextStyle tStyleFont13 = const TextStyle(fontSize: fontSize13);
TextStyle tStyleFont10 = const TextStyle(fontSize: fontSize10);
TextStyle tStyleFont16 = const TextStyle(fontSize: fontSize16);

TextStyle tStyle36 = TextStyle(fontSize: fontSize36, fontWeight: font7);

TextStyle tStyle10 = TextStyle(fontSize: fontSize10, fontWeight: normal, color: black);
TextStyle tStyle12 = TextStyle(fontSize: fontSize12, fontWeight: normal);
TextStyle tStyle13 = TextStyle(fontSize: fontSize13, fontWeight: normal);
TextStyle tStyle14 = TextStyle(fontSize: fontSize14, fontWeight: normal);
TextStyle tStyle16 = TextStyle(fontSize: fontSize16, fontWeight: normal);
TextStyle tStyle18 = TextStyle(fontSize: fontSize18, fontWeight: normal);
TextStyle tStyle20 = TextStyle(fontSize: fontSize20, fontWeight: normal);

TextStyle tStyleBold10 = TextStyle(fontSize: fontSize10, fontWeight: bold);
TextStyle tStyleBold12 = TextStyle(fontSize: fontSize12, fontWeight: bold);
TextStyle tStyleBold13 = TextStyle(fontSize: fontSize13, fontWeight: bold);
TextStyle tStyleBold14 = TextStyle(fontSize: fontSize14, fontWeight: bold);
TextStyle tStyleBold15 = TextStyle(fontSize: fontSize15, fontWeight: bold, color: white);
TextStyle tStyleBold16 = TextStyle(fontSize: fontSize16, fontWeight: bold);
TextStyle tStyleBold18 = TextStyle(fontSize: fontSize18, fontWeight: bold);
TextStyle tStyleBold24 = TextStyle(fontSize: fontSize24, fontWeight: bold);
TextStyle tStyleBold25 = TextStyle(fontSize: fontSize25, fontWeight: bold);

TextStyle tStyle14W6 = const TextStyle(fontSize: fontSize14, fontWeight: FontWeight.w600);

TextStyle tStyleBold24Black = TextStyle(fontSize: fontSize24, fontWeight: bold, color: black);
TextStyle tStyleBold13Black = TextStyle(fontSize: fontSize13, fontWeight: bold, color: black);

const tfInputDecoration = InputDecoration(
  filled: true,
  fillColor: white,
  errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: bgCktbet),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: bgCktbet),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);

TextStyle n12ts = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: black);
TextStyle n15ts = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: black);
TextStyle b14ts = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: black);
TextStyle b22ts = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: black);
TextStyle b12ts = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: black);
TextStyle b16ts = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black);
TextStyle b13ts({Color? color}) {
  return TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? black);
}
