import 'package:flutter/material.dart';

import 'colors.dart';

class LiveIndicator extends StatelessWidget {
  final bool isLive;
  const LiveIndicator({super.key, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: grey),
        color: isLive ? Color(0xFF6BBD11) : grey,
      ),
    );
  }
}

class LiveIndicatorForDesktop extends StatelessWidget {
  final bool isLive;
  const LiveIndicatorForDesktop({super.key, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: grey),
        gradient: isLive ? LinearGradient(colors: [liveGreen, liveGreen]) : LinearGradient(colors: [greyShade, greyShade]),
      ),
    );
  }
}
