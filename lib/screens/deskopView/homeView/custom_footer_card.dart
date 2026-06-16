import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/app_asset_constants.dart';
import '../../../constants/app_string_constants.dart';
import '../../../reusables/buttons.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/open_url.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../mobileScreens/mobileAuthView/mobileAuthView/mv_login_screen.dart';
import 'app_download_popup.dart';
import 'one_click_bet_footer_card.dart';

class CustomFooterCard extends StatelessWidget {
  const CustomFooterCard({super.key, this.type = 1, this.isshowOneClickBetFooterCard = false});
  final int type;
  final bool isshowOneClickBetFooterCard;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: whiteOpac,
      width: size.width,
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: type == 0 ? size.width * 0.5 : size.width * 0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hb40,

                  /// Top two footer cards row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: FooterTileCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OpenLinkedButton(title: "Customer support1", image: AppAssetConstants.support),
                              const VerticalDivider(color: grey, endIndent: 15, indent: 15),
                              OpenLinkedButton(title: "support2"),
                            ],
                          ),
                        ),
                      ),
                      wb10,
                      Flexible(
                        flex: 1,
                        child: FooterTileCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OpenLinkedButton(title: "WhatsApp 3", image: AppAssetConstants.whatsapp),
                              const VerticalDivider(color: grey, endIndent: 15, indent: 15),
                              OpenLinkedButton(title: "WhatsApp 4"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: FooterTileCard(height: 15, width: size.width),
                  ),

                  /// Bottom 3 social/contact buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: FooterTileCard(
                          child: OpenLinkedButton(title: "Telegram", image: AppAssetConstants.telegram),
                        ),
                      ),
                      wb10,
                      Flexible(
                        child: FooterTileCard(
                          child: OpenLinkedButton(title: "Email", image: AppAssetConstants.email),
                        ),
                      ),
                      wb10,
                      Flexible(
                        child: FooterTileCard(
                          child: OpenLinkedButton(title: "6Ball", image: AppAssetConstants.insta),
                        ),
                      ),
                    ],
                  ),
                  hb30,
                ],
              ),
            ),
          ),
          const Divider(color: grey),
          hb30,
          FooterLinks(),
          hb30,
          AppQRAndDownloadButton(
            image: AppAssetConstants.btnAppdl,
            onTap: () {
              AppDownloadPopup.open(context);
            },
          ),
          hb50,
          if (isshowOneClickBetFooterCard) OneClickBetFooterCard(),
          hb50,
        ],
      ),
    );
  }
}

class FooterTileCard extends StatelessWidget {
  const FooterTileCard({super.key, this.child, this.height, this.width});
  final Widget? child;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      width: width,
      constraints: BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: child),
      ),
    );
  }
}

class OpenLinkedButton extends StatelessWidget {
  const OpenLinkedButton({super.key, required this.title, this.buttonLink, this.image = '', this.height});

  final String title;
  final String? buttonLink;
  final double? height;
  final String image;

  @override
  Widget build(BuildContext context) {
    // Map title to default URL
    String getLinkByTitle() {
      switch (title.toLowerCase()) {
        case 'customer support1':
          return AppStringConstants.whatsappLink;
        case 'support2':
          return AppStringConstants.whatsappLink;
        case 'whatsapp 3':
          return AppStringConstants.whatsappLink1;
        case 'whatsapp 4':
          return AppStringConstants.whatsappLink1;
        case 'email':
          return AppStringConstants.email;
        case 'telegram':
          return AppStringConstants.telegram;
        case '6ball':
          return AppStringConstants.insta;
        default:
          return AppStringConstants.whatsappLink;
      }
    }

    final linkToOpen = buttonLink ?? getLinkByTitle();

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () async {
            await openUrl(linkToOpen);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image.isNotEmpty) SvgPicture.asset(image, height: height ?? 20, width: 20, colorFilter: ColorFilter.mode(grey, BlendMode.srcIn)),
              if (image.isNotEmpty) wb5,
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: grey, overflow: TextOverflow.ellipsis),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
