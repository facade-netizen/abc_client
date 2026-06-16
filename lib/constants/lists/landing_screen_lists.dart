import 'package:flutter_svg/svg.dart';

import '../../screens/mobileScreens/mvAccounts/mv_mobile_account_menu.dart';
import '../../screens/mobileScreens/inPlayScreen/mv_in_play_screen.dart';
import '../../screens/mobileScreens/mvMultiMarket/mv_multi_market_screen.dart';
import '../../screens/mobileScreens/sportScreen/mv_sport_screen.dart';
import '../app_asset_constants.dart';

List<String> commodityList = [
  AppAssetConstants.homeWhite,
  AppAssetConstants.energyWhite,
  AppAssetConstants.bullionWhite,
  AppAssetConstants.forexWhite,
  AppAssetConstants.accountWhite,
];
List<String> iconPathList = [AppAssetConstants.homeWhite, AppAssetConstants.sportsWhite, AppAssetConstants.inPlayWhite, AppAssetConstants.accountWhite];

List<String> selectedIcons = [AppAssetConstants.homeYellow, AppAssetConstants.sportsYellow, AppAssetConstants.inPlayYellow, AppAssetConstants.accountYellow];
List<String> selectedCommodityIcons = [
  AppAssetConstants.homeYellow,
  AppAssetConstants.energyYellow,
  AppAssetConstants.bullionYellow,
  AppAssetConstants.forexYellow,
  AppAssetConstants.accountYellow,
];

List<Map<dynamic, dynamic>> sportsBottomNavBarItems = [
  {'icon': AppAssetConstants.trophy, 'text': 'Sports', "screen": const MVSportScreen()},
  {'icon': AppAssetConstants.clockWhite, 'text': 'In-play', "screen": const MVInPlayScreenPage()},
  {'icon': AppAssetConstants.homeWhite, 'text': 'Home', "screen": null},
  {'icon': AppAssetConstants.pinWhite, 'text': 'Multi Market', "screen": const MVMultiMarketsCard()},
  {'icon': AppAssetConstants.personTabbar, 'text': 'Account', "screen": const MobileAccountMenu()},
];
List<Map<dynamic, dynamic>> sportsTypeTabs = [
  {'icon': AppAssetConstants.ball, 'name': 'Cricket'},
  {'icon': AppAssetConstants.soccer1, 'name': 'Soccer'},
  {'icon': AppAssetConstants.tennis, 'name': 'Tennis'},
  {'icon': AppAssetConstants.eSoccer, 'name': 'E Soccer'},
  {'icon': AppAssetConstants.kabbadi, 'name': 'Kabaddi'},
];

class SectionData {
  final String label;
  final SvgPicture icon;

  SectionData({required this.label, required this.icon});
}

List appList = ['Home', 'In-Play', 'Cricket', 'Football', 'Tennis', 'Bets Results', 'Commodity'];

List myAccountItems = ['Username5462', 'My Profile', 'Balance Overview', 'My Beats', 'Activity Log', 'Settings', 'Logout'];
