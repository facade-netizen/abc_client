import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

class TopFilterWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TopFilterWidget({super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      width: size.width * 0.8,
      height: 36,
      decoration: BoxDecoration(
        color: topFltrbgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD4D4D4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // By Time
          GestureDetector(
            onTap: () => onTabSelected(0),
            child: Container(
              width: size.width * 0.4,
              height: 36,
              decoration: BoxDecoration(color: selectedIndex == 0 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'by Time',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: selectedIndex == 0 ? blueColor : black, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
          ),

          // By Competition
          GestureDetector(
            onTap: () => onTabSelected(1),
            child: Container(
              width: size.width * 0.382,
              height: 36,
              decoration: BoxDecoration(color: selectedIndex == 1 ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  'by Competition',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: selectedIndex == 1 ? blueColor : black, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
