import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/sized_box_hw.dart';
import 'live_badge.dart';

class MainMenuTabCard extends StatefulWidget {
  const MainMenuTabCard({super.key, this.action, required this.title, required this.selectedTab, this.liveCount, this.eventTypeId});
  final String title;
  final String selectedTab;
  final void Function()? action;
  final int? liveCount;
  final String? eventTypeId;

  @override
  State<MainMenuTabCard> createState() => _MainMenuTabCardState();
}

class _MainMenuTabCardState extends State<MainMenuTabCard> {
  int cricket = 0, soccer = 0, tennis = 0, gHond = 0, hourse = 0, ele = 0;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.action,
      child: widget.title.toLowerCase() == 'casino'
          ? Container(
              height: 35,
              decoration: BoxDecoration(
                gradient: bottomBarGradient,
                border: Border.symmetric(vertical: BorderSide(color: black.withValues(alpha: 0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(AppAssetConstants.menuTagnew),
                  Center(
                    child: HighlightText(
                      widget.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  wb5,
                  Image.asset(AppAssetConstants.menuCasino),
                  wb5,
                ],
              ),
            )
          : Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: widget.selectedTab.toLowerCase() == widget.title.toLowerCase() ? selectedTabClr : loginbg,
                border: Border.symmetric(vertical: BorderSide(color: Colors.black.withValues(alpha: 0.2))),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: HighlightText(
                      widget.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  if (widget.liveCount != null)
                    BlocBuilder<FetchOnlyInplayCountsBloc, FetchOnlyInplayCountsState>(
                      builder: (context, state) {
                        if (state is FetchOnlyInplayCountsSuccess) {
                          cricket = state.cricketCount;
                          soccer = state.soccerCount;
                          tennis = state.tennisCount;
                          gHond = state.gHondCount;
                          hourse = state.hourseCount;
                          ele = state.eleCount;
                        }
                        return Positioned(
                          top: -8,
                          right: -10,
                          child: LiveBadge(
                            count: widget.eventTypeId == "4"
                                ? cricket
                                : widget.eventTypeId == "1"
                                ? soccer
                                : widget.eventTypeId == "2"
                                ? tennis
                                : widget.eventTypeId == "4339"
                                ? gHond
                                : widget.eventTypeId == "7"
                                ? hourse
                                : widget.eventTypeId == "5"
                                ? ele
                                : 0,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

// Map each tab with its screen

String formatScreenType(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

List<TabItem> staticTabs = [
  TabItem(title: 'Home'),
  TabItem(title: 'In-Play'),
  TabItem(title: 'Multi Markets'),
  //TabItem(title: 'Virtual Cricket'),
];

class TabItem {
  final String title;
  final int? count;
  final String? eventTypeId;
  const TabItem({this.count, this.eventTypeId, required this.title});
}
