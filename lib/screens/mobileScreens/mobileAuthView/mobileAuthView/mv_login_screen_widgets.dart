import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../reusables/colors.dart';
import '../../../../services/navigators.dart';

class MVLoginLogo extends StatelessWidget {
  const MVLoginLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ClipPath(
        clipper: HalfOvalClipper(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(image: AssetImage(AppAssetConstants.logincard), fit: BoxFit.cover),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(),
                child: Container(color: black.withValues(alpha: 0.1)),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Image(image: AssetImage(AppAssetConstants.gamingLogo), height: 180),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: InkWell(
                onTap: () {
                  removeScreen(context);
                },
                child: CircleAvatar(child: Icon(Icons.close)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HalfOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.5, size.height, 0, size.height * 0.75);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

BoxDecoration getGradientBoxDecoration() {
  return BoxDecoration(gradient: loginbg);
}
