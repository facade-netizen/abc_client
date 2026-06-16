import 'package:flutter/material.dart';

import '../../../reusables/colors.dart';

List<IconData> sportsIcons = [
  Icons.sports,
  Icons.sports_soccer_outlined,
  Icons.sports_tennis_outlined,
  Icons.policy_outlined,
  Icons.sports_cricket_outlined,
  Icons.sports_football_outlined,
];

class SeacrhButton extends StatelessWidget {
  final VoidCallback onTap;
  const SeacrhButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, black], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            width: 56,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [btnBgTopColor, btnBgBtmColor], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.search_rounded, color: Colors.white, size: 30)],
            ),
          ),
        ),
      ],
    );
  }
}
