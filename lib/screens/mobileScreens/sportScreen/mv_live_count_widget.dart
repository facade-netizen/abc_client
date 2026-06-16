import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/app_asset_constants.dart';
import '../../../reusables/colors.dart';

class MVLiveBadge extends StatefulWidget {
  final int count;
  const MVLiveBadge({super.key, required this.count});
  @override
  State<MVLiveBadge> createState() => _MVLiveBadgeState();
}

class _MVLiveBadgeState extends State<MVLiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2),
            color: white,
            child: FadeTransition(
              opacity: controller,
              child: SvgPicture.asset(AppAssetConstants.live, height: 9, width: 15, colorFilter: ColorFilter.mode(red, BlendMode.srcIn)),
            ),
          ),
          // Count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
            ),
            child: Text(widget.count.toString(), style: const TextStyle(color: white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
