import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants/app_asset_constants.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/custom_login_container.dart';
import '../../../../reusables/open_url.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/style.dart';
import '../../../constants/app_string_constants.dart';
import '../../../reusables/buttons.dart';
import '../mobileAuthView/mobileAuthView/mv_login_screen.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, this.cardColor, required this.child, this.borderRadius});
  final Widget? child;
  final Color? cardColor;
  final BorderRadiusGeometry? borderRadius;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor ?? metallicBlue,
          border: Border.all(color: outlineColor, width: 3),
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        ),
        child: child,
      ),
    );
  }
}

class HomeHeading extends StatelessWidget {
  const HomeHeading({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(child: Text(title, style: tStyleBold15)),
    );
  }
}

class DesktopViewCustomCard extends StatelessWidget {
  const DesktopViewCustomCard({super.key, required this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: cardGradient),
      child: child,
    );
  }
}

class CustomContactCard extends StatelessWidget {
  const CustomContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomLoginContainer(
                  width: 361,
                  height: 50,
                  borderRadius: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssetConstants.whatsapp, height: 25, width: 25, colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, .7), BlendMode.srcIn)),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.whatsappLink1);
                        },
                        child: Text(
                          "WhatsApp 3",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      wb5,
                      Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7))),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.whatsappLink1);
                        },
                        child: Text(
                          "WhatsApp 4",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                hb10,
                CustomLoginContainer(
                  width: 361,
                  height: 50,
                  borderRadius: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssetConstants.support, height: 25, width: 25, colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, .7), BlendMode.srcIn)),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.whatsappLink);
                        },
                        child: Text(
                          "Customer support1",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(0, 0, 0, .7)),
                        ),
                      ),
                      wb5,
                      Text("|", style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7))),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.whatsappLink);
                        },
                        child: Text(
                          "supports",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color.fromRGBO(0, 0, 0, .7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          hb20,
          SizedBox(
            width: 361,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomLoginContainer(
                  width: 115,
                  height: 44,
                  borderRadius: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssetConstants.telegram, height: 25, width: 25, colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, .7), BlendMode.srcIn)),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.telegram);
                        },
                        child: Text(
                          "Telegram",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomLoginContainer(
                  width: 115,
                  height: 44,
                  borderRadius: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssetConstants.email, height: 26, width: 26, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.email);
                        },
                        child: Text(
                          "Email",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomLoginContainer(
                  width: 115,
                  height: 44,
                  borderRadius: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssetConstants.insta, height: 26, width: 26, colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, .7), BlendMode.srcIn)),
                      wb5,
                      InkWell(
                        onTap: () async {
                          await openUrl(AppStringConstants.insta);
                        },
                        child: Text(
                          "6Ball",
                          style: TextStyle(color: Color.fromRGBO(0, 0, 0, .7), fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          hb10,
          FooterLinks(),
          hb10,
          AppQRAndDownloadButton(
            image: AppAssetConstants.mvApkButton,
            onTap: () {
            openUrl(AppStringConstants.apkDownloadLink);
            },
          ),
        ],
      ),
    );
  }
}
