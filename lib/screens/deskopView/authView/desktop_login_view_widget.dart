import 'package:flutter/material.dart';

import '../../../constants/app_asset_constants.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/loader.dart';
import '../../../services/navigators.dart';

class DesktopLoginViewWidget extends StatelessWidget {
  const DesktopLoginViewWidget({super.key, this.content, required this.height, required this.width, this.isProcessing = false});
  final Widget? content;
  final double height;
  final double width;
  final bool isProcessing;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      backgroundColor: none,
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: height,
        width: width,
        child: Row(
          children: [
            Container(
              width: width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                image: const DecorationImage(image: AssetImage(AppAssetConstants.logincard), fit: BoxFit.fill),
                gradient: gradientClr,
              ),
              child: Center(child: Image(image: AssetImage(AppAssetConstants.gamingLogo), height: 180)),
            ),
            Container(
              width: width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                color: appYellow,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    top: 10,
                    child: InkWell(
                      onTap: () {
                        removeScreen(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(color: black, borderRadius: BorderRadius.circular(4)),
                        child: Icon(Icons.close, color: appYellow),
                      ),
                    ),
                  ),
                  isProcessing ? LoaderContainerWithMessage(message: "Please wait") : Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
