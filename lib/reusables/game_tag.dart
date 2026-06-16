import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_asset_constants.dart';
import 'colors.dart';
import 'formatters.dart';

class EsportWithTitle extends StatelessWidget {
  final String gameTitle;
  const EsportWithTitle({super.key, required this.gameTitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 18,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Color(0xff1F5172)),
      ),
      child: Row(
        children: [
          ClipPath(
            clipper: SlantedTagClipper(),
            child: Container(
              height: 18,
              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 2),
              decoration: BoxDecoration(color: Color(0xff1F5172)),
              child: SvgPicture.asset(AppAssetConstants.e, height: 8, width: 8, colorFilter: ColorFilter.mode(white, BlendMode.srcIn)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Text(gameTitle, style: TextStyle(color: Color(0xff1F5172), fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class FBTag extends StatelessWidget {
  final bool isFTag;
  const FBTag({super.key, required this.isFTag});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
            color: green,
          ),
          child: Center(child: SvgPicture.asset(AppAssetConstants.clock, height: 13, width: 13, colorFilter: ColorFilter.mode(white, BlendMode.srcIn))),
        ),
        Container(
          width: 25,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
            color: isFTag ? cyan : Color(0xFF1876b2),
          ),
          child: isFTag
              ? SvgPicture.asset(AppAssetConstants.f, height: 13, width: 13, colorFilter: ColorFilter.mode(white, BlendMode.srcIn))
              : SvgPicture.asset(AppAssetConstants.b, height: 13, width: 13, colorFilter: ColorFilter.mode(white, BlendMode.srcIn)),
        ),
      ],
    );
  }
}

class PTag extends StatelessWidget {
  const PTag({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(color: Color(0xFFe4550f), borderRadius: BorderRadius.circular(4)),
      child: SvgPicture.asset(AppAssetConstants.p, height: 14, width: 14, colorFilter: ColorFilter.mode(white, BlendMode.srcIn)),
    );
  }
}

class PlayTag extends StatelessWidget {
  const PlayTag({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(color: Color(0xFF1876b2), borderRadius: BorderRadius.circular(4)),
      child: Padding(padding: const EdgeInsets.all(0.5), child: SvgPicture.asset(AppAssetConstants.inplay, height: 13, width: 13)),
    );
  }
}

class SessionTag extends StatelessWidget {
  final String value;
  final bool isLive;
  const SessionTag({super.key, required this.value, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Text(isLive ? "In-Play" : formatUtcToLocal(value),
        style: TextStyle(
          color: Color(0xFF787878),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ));
  }
}

class SlantedTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // top-left
    path.lineTo(size.width, 0); // top-right (slant start)
    path.lineTo(size.width - 8, size.height); // bottom-right slant
    path.lineTo(0, size.height); // bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
