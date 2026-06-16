import 'package:flutter/material.dart';

import '../../../../models/user_details_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../account_statement_screen.dart';
import '../activity_logs_screen_new.dart';
import '../balance_overrview_screen.dart';
import '../myBetsNew/my_bets_tab.dart';
import '../profile/profile_screen.dart';

class MyAccountMenuTile extends StatefulWidget {
  const MyAccountMenuTile({super.key, this.action, required this.menu, required this.selectedMenu});
  final String menu;
  final String selectedMenu;
  final void Function()? action;

  @override
  State<MyAccountMenuTile> createState() => _MyAccountMenuTileState();
}

class _MyAccountMenuTileState extends State<MyAccountMenuTile> {
  bool isHovered = false;

  bool get isMyBetsGroupSelected {
    return widget.selectedMenu == 'My Bets' || widget.selectedMenu == 'Bets History' || widget.selectedMenu == 'Profit & Loss';
  }

  bool get isTileSelected {
    if (widget.menu == 'My Bets') {
      return isMyBetsGroupSelected;
    }
    return widget.selectedMenu == widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.action,
        child: Container(
          height: 30,
          width: size.width,
          decoration: BoxDecoration(
            color: isTileSelected
                ? whiteOpac1
                : isHovered
                ? highlightHeader.withValues(alpha: 0.1)
                : white,
            border: Border(bottom: BorderSide(color: highlightHeader.withValues(alpha: 0.3))),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: HighlightText(
              widget.menu,
              style: TextStyle(color: black, fontWeight: FontWeight.normal, fontSize: 13, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}

List<String> accountMenu = ["My Profile", "Balance Overview", "Account Statement", "My Bets", "Activity Log"];

///Map each menu with its screen
Map<String, Widget?> accountMenuScreens(UserAccountDetails? currentUser) {
  return {
    'My Profile': ProfileScreen(),
    'Balance Overview': BalanceOverviewScreen(),
    'Account Statement': AccountStatementScreen(),
    'My Bets': MyBetsTab(key: const ValueKey('my-bets-current'), currentUser: currentUser, initialTab: 'Current Bets'),
    'Bets History': MyBetsTab(key: const ValueKey('my-bets-history'), currentUser: currentUser, initialTab: 'Betting History'),
    'Profit & Loss': MyBetsTab(key: const ValueKey('my-bets-profit-loss'), currentUser: currentUser, initialTab: 'Profit & Loss'),
    'Activity Log': ActivityLogsScreenNew(),
  };
}
