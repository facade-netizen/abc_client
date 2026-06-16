import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../blocs/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../../../../models/user_details_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../routing/route_navigation_helper.dart';
import '../../sportsReusables/table_cell_card.dart';
import 'bettingHistory/betting_history_screen.dart';
import 'currentBets/current_bets_tab.dart';
import 'profitAndLoss/profit_and_loss_screen.dart';

class MyBetsTab extends StatefulWidget {
  const MyBetsTab({
    super.key,
    this.currentUser,
    this.initialTab = 'Current Bets',
  });
  final UserAccountDetails? currentUser;
  final String initialTab;

  @override
  State<MyBetsTab> createState() => _MyBetsTabState();
}

class _MyBetsTabState extends State<MyBetsTab> {
  late String selectedTab;

  Map<String, Widget> get myBetsTabs => {
        'Current Bets': CurrentBetsTab(currentUser: widget.currentUser),
        'Betting History': BettingHistoryScreen(currentUser: widget.currentUser),
        'Profit & Loss': ProfitAndLossScreen(currentUser: widget.currentUser),
      };

  @override
  void initState() {
    super.initState();

    selectedTab = widget.initialTab;
    _dispatchTabFetch(selectedTab);
  }

  @override
  void didUpdateWidget(covariant MyBetsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab != widget.initialTab) {
      selectedTab = widget.initialTab;
      _dispatchTabFetch(selectedTab);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget selectedScreen = myBetsTabs[selectedTab] ?? const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TableHeader(title: "My Bets"),
        Wrap(
          children: myBetsTabs.keys.map((title) {
            return MyBetsTabMenu(
              title: title,
              selectedTab: selectedTab,
              action: () {
                final route = tabToRoute(title);
                context.go(GoToRoute.accountMyBets(route));
              },
            );
          }).toList(),
        ),
        hb10,
        Expanded(child: selectedScreen),
      ],
    );
  }

  void _dispatchTabFetch(String tabTitle) {
    if (tabTitle == 'Profit & Loss') {
      context.read<FetchPlayerProfitAndLossBloc>().add(FetchPlayerProfitAndLossInt());
      context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistoryInt());
    } else if (tabTitle == 'Betting History') {
      context.read<FetchPlayerBetHistoryBloc>().add(FetchPlayerBetInt());
      context.read<FetchSportsBookHistoryBloc>().add(FetchSportsBookHistoryInt());
    }
  }

  String tabToRoute(String tab) {
    return tab.toLowerCase().replaceAll(' & ', '-').replaceAll(' ', '-');
  }
}

String routeToTab(String route) {
  switch (route) {
    case 'current-bets':
      return 'Current Bets';
    case 'betting-history':
      return 'Betting History';
    case 'profit-loss':
      return 'Profit & Loss';
    default:
      return 'Current Bets';
  }
}

class MyBetsTabMenu extends StatelessWidget {
  const MyBetsTabMenu({
    super.key,
    this.action,
    required this.title,
    required this.selectedTab,
  });
  final String title;
  final String selectedTab;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        width: 230,
        height: 35,
        decoration: BoxDecoration(
          color: selectedTab == title ? tileOrFontColor : white,
          border: Border.all(color: black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HighlightText(
              textAlign: TextAlign.center,
              title,
              style: TextStyle(color: selectedTab == title ? white : black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
