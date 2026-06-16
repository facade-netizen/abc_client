import 'package:flutter/material.dart';
import '../../../../reusables/colors.dart';

class InplayCustomTabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const InplayCustomTabBtn({super.key, required this.isActive, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? white : btmBarBottomColor,
          border: Border(
            left: BorderSide(color: white, width: 0.5),
            right: BorderSide(color: white, width: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isActive ? black : white,
              height: 1,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
