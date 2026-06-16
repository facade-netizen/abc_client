import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';

class SportTypeCustomTabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String icon;

  const SportTypeCustomTabBtn(this.label, {super.key, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isActive ? blackGrdntButton : appYellowGrdnt,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.network(icon, colorFilter: ColorFilter.mode(isActive ? appBarText : black, BlendMode.srcIn), height: 22, width: 22),
            wb5,
            SizedBox(
              width: 50,
              child: Text(
                label,
                style: TextStyle(fontSize: 14, letterSpacing: 0.2, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600, color: isActive ? appBarText : black, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
