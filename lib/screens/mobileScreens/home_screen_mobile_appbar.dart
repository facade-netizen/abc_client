import 'package:flutter/material.dart';

import '../../../reusables/buttons.dart';
import '../../../reusables/colors.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../constants/strings/home_screen_strings.dart';
import '../../constants/app_string_constants.dart';
import '../../demo/bootstrap/demo_bootstrap.dart';
import '../../reusables/open_url.dart';
import '../../reusables/sized_box_hw.dart';
import '../../services/navigators.dart';
import 'mobileAuthView/mobileAuthView/mv_login_screen.dart';

class MobileLogInMobileAppBar extends StatelessWidget {
  const MobileLogInMobileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(gradient: bottomBarGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(AppAssetConstants.gamingLogo, height: 65, width: 72),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: [
                    ColouredElevatedButton(
                      height: 38,
                      width: 90,
                      onCLick: () async {
                        await openUrl(AppStringConstants.whatsappLink1);
                      },
                      gradientColor: mvSignupButton,
                      child: Text(
                        HomeScreenStrings.signup,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: white),
                      ),
                    ),
                    wb5,
                    ColouredElevatedButton(
                      height: 38,
                      width: 90,
                      onCLick: () => DemoBootstrap.start(context),
                      gradientColor: mvSignupButton,
                      child: const Text(
                        'Try Demo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: white),
                      ),
                    ),
                    wb5,
                    ColouredElevatedButton(
                      height: 38,
                      width: 90,
                      onCLick: () {
                        pushSimple(context, MVLogin());
                      },
                      gradientColor: redGrdntButton,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 20, color: white),
                          Text(
                            HomeScreenStrings.login,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
