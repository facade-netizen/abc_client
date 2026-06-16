import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../reusables/colors.dart';
import '../../../../routing/route_navigation_helper.dart';
import '../../../deskopView/resultsView/result_sport_dropdown.dart';
import '../../mvReusables/mobile_string_list.dart';
import '../inplay_custom_tabs.dart';
import 'mv_line_result_tile.dart';
import 'mv_result_view_tile.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final List<String> _sports = ['CRICKET', 'SOCCER', 'E-SOCCER', 'FANCYBET'];
  String _selectedSport = 'CRICKET';

  int _getTabIndex(String? tab) {
    if (tab == null) return 0;
    switch (tab.toLowerCase()) {
      case 'today':
        return 0;
      case 'yesterday':
        return 1;
      default:
        return 0;
    }
  }

  String _getTabName(int index) => index == 1 ? 'Yesterday' : 'Today';

  @override
  Widget build(BuildContext context) {
    final tabParam = GoRouter.of(context).state.pathParameters['tab'];
    final activeTabIndex = _getTabIndex(tabParam);
    final currentTab = _getTabName(activeTabIndex);
    Size size = MediaQuery.sizeOf(context);

    return Column(
      children: [
        // Today / Yesterday tab switcher
        Container(
          height: 55,
          decoration: BoxDecoration(color: btmBarBottomColor),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: white),
                borderRadius: BorderRadius.circular(5),
                color: btmBarBottomColor,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabs = resultsTabs;
                  final tabWidth = constraints.maxWidth / tabs.length;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final item = tabs[index];
                      return SizedBox(
                        width: tabWidth,
                        child: InplayCustomTabBtn(
                          isActive: activeTabIndex == index,
                          label: item,
                          onTap: () {
                            context.go(GoToRoute.result(item.toLowerCase()));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),

        // Sport category dropdown
        Container(
          height: 50,
          decoration: BoxDecoration(color: btmBarBottomColor),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: ResultSportDropdown(
              height: 40,
              width: size.width,
              selectedSport: _selectedSport,
              sports: _sports,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSport = value;
                  });
                }
              },
            ),
          ),
        ),

        // Content area
        Expanded(
          child: _selectedSport == 'FANCYBET'
              ? MobileLineResultView(tab: currentTab, key: ValueKey(currentTab))
              : MobileSportsResultView(
                  key: ValueKey(currentTab),
                  resultTab: currentTab,
                  selectedSport: _selectedSport,
                ),
        ),
      ],
    );
  }
}
