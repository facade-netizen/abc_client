import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/miscBlocs/sports_session_connect_bloc.dart';
import '../../../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../homeView/one_click_bet_footer_card.dart';
import '../inplayView/inplay_event_tile.dart';
import 'new_inplay_screen.dart';
import 'new_inplay_today_screen.dart';
import 'new_inplay_tomorrow_screen.dart';

class NewInplayTabView extends StatefulWidget {
  const NewInplayTabView({super.key, required this.child});
  final Widget child;

  @override
  State<NewInplayTabView> createState() => _NewInplayTabViewState();
}

class _NewInplayTabViewState extends State<NewInplayTabView> {
  void _disconnectAllSignalR() {
    final multiBloc = context.read<SubscribeMultiEventsSignalRBloc>();

    final singleEventIds = [subscribedSingleInplayEventId, subscribedSingleTodayEventId, subscribedSingleTomorrowEventId];

    for (final id in singleEventIds) {
      if (id != null) {
        sportsSessionConnect(ctxt: context, type: SessionType.disconnect, eventId: id);
      }
    }

    final multiEventLists = [subscribedMultiInplayEventIds];

    for (final ids in multiEventLists) {
      if (ids.isNotEmpty) {
        multiBloc.add(DisconnectMultiEventsSignalR(eventIds: ids));
      }
    }
  }

  String _getCurrentTab() {
    final location = GoRouterState.of(context).uri.path;

    if (location.contains('/today')) return 'Today';
    if (location.contains('/tomorrow')) return 'Tomorrow';
    return 'In-Play';
  }

  void _onTabSelected(String menu) {
    _disconnectAllSignalR();

    switch (menu) {
      case 'Today':
        context.go(GoToRoute.inplay(type: 'today'));
        break;
      case 'Tomorrow':
        context.go(GoToRoute.inplay(type: 'tomorrow'));
        break;
      default:
        context.go(GoToRoute.inplay());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _getCurrentTab();
    Size size = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: inplayTab.map((menu) {
                    return RightClickWrapper(
                      route: menu == 'Tomorrow'
                          ? GoToRoute.inplay(type: 'tomorrow')
                          : menu == 'Today'
                              ? GoToRoute.inplay(type: 'today')
                              : GoToRoute.inplay(),
                      child: InplayTabCard(title: menu, selectedTab: selectedTab, action: () => _onTabSelected(menu)),
                    );
                  }).toList(),
                ),
                hb20,
                Expanded(child: widget.child),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: size.width * 0.66,
              child: const OneClickBetFooterCard(),
            ),
          ),
        ],
      ),
    );
  }
}
