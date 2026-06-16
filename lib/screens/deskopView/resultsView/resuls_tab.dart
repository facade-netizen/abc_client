import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../reusables/sized_box_hw.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../inplayView/inplay_event_tile.dart';
import '../sportsReusables/sports_header.dart';
import 'resuls_view_tile.dart';
import 'result_line_tile.dart';
import 'result_sport_dropdown.dart';

class ResultsTabView extends StatefulWidget {
  const ResultsTabView({super.key, this.initialTab = 'today'});

  final String initialTab;

  @override
  State<ResultsTabView> createState() => _ResultsTabViewState();
}

class _ResultsTabViewState extends State<ResultsTabView> {
  String selectedTab = 'Today';

  final List<String> tabs = ['Today', 'Yesterday'];
  final List<String> sports = ['CRICKET', 'SOCCER', 'E-SOCCER', 'FANCYBET'];
  String selectedSport = 'CRICKET';

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    String routeTab = 'today';
    if (location.startsWith('/result/')) {
      routeTab = location.split('/').last;
    }

    final newTab = routeToTab(routeTab);

    if (newTab != selectedTab) {
      selectedTab = newTab;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final middleWidth = screenWidth * 0.70 - 20;
          final rightWidth = screenWidth * 0.30;
          return SizedBox(
            width: screenWidth,
            child: Row(
              children: [
                SizedBox(
                  width: middleWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: tabs.map((menu) {
                              return RightClickWrapper(
                                route: GoToRoute.result(tabToRoute(menu)),
                                child: InplayTabCard(
                                  title: menu,
                                  selectedTab: selectedTab,
                                  action: () {
                                    final route = tabToRoute(menu);
                                    context.go(GoToRoute.result(route));
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                          ////
                          ResultSportDropdown(
                            selectedSport: selectedSport,
                            sports: sports,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedSport = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      hb10,
                      Expanded(
                        child: resultScreens(selectedTab, selectedSport),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(width: rightWidth, child: const SportsBetSlip()),
              ],
            ),
          );
        },
      ),
    );
  }

  String tabToRoute(String tab) {
    return tab.toLowerCase();
  }

  String routeToTab(String route) {
    switch (route) {
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'Yesterday';
      default:
        return 'Today';
    }
  }
}

Widget resultScreens(String tab, String selectedSport) {
  switch (tab) {
    case 'Today':
      return selectedSport == 'FANCYBET'
          ? ResultLineTile(
              tab: tab,
              key: ValueKey(tab),
            )
          : ResultViewTile(
              resultTab: tab,
              selectedSport: selectedSport,
              key: ValueKey(tab),
            );
    case 'Yesterday':
      return selectedSport == 'FANCYBET'
          ? ResultLineTile(
              tab: tab,
              key: ValueKey(tab),
            )
          : ResultViewTile(
              resultTab: tab,
              selectedSport: selectedSport,
              key: ValueKey(tab),
            );
    default:
      return const SizedBox();
  }
}
