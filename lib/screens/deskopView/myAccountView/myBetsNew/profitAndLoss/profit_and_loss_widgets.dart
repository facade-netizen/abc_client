import 'package:flutter/material.dart';

import '../../../../../reusables/colors.dart';
import '../../../../../reusables/highlighted_text_widget.dart';

class Heading extends StatelessWidget {
  final String text;
  const Heading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: HighlightText(text, style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.normal)),
          ),
        ],
      ),
    );
  }
}

class CustomTabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CustomTabBtn(
    this.label, {
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? tileOrFontColor : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          border: Border(
            left: BorderSide(color: tileOrFontColor),
            right: BorderSide(color: tileOrFontColor),
            top: BorderSide(color: tileOrFontColor),
            bottom: isActive ? BorderSide(color: tileOrFontColor) : BorderSide.none,
          ),
        ),
        child: HighlightText(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? Colors.white : tileOrFontColor, height: 1),
        ),
      ),
    );
  }
}
