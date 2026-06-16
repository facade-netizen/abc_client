import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_only_inplay_events_bloc.dart';
import '../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/me_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../../../models/event_with_type_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/loader.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../routing/app_router.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../openBetsView/bets_tab_item.dart';
import '../sportsReusables/sports_header.dart';
import '../sportsReusables/sports_highlights_header.dart';
import '../sportsReusables/sports_highlights_tile.dart';
import '../sportsView/betSlipOrder/sports_bet_slip_order_card.dart';

String capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String? subscribedSingleInplayEventId;
List<String> subscribedMultiInplayEventIds = [];

class NewInplayScreen extends StatefulWidget {
  const NewInplayScreen({super.key});

  @override
  State<NewInplayScreen> createState() => _NewInplayScreenState();
}

class _NewInplayScreenState extends State<NewInplayScreen> {
  List<Sport> eventData = [];
  List<String> sportsFilter = [];
  List<BetSlipItem> betSlipItems = [];
  Set<String> removedEventIds = {};

  @override
  void initState() {
    context.read<FetchOnlyInplayEventsBloc>().add(FetchOnlyInplayEvents());
    super.initState();
  }

  void _connectMultiEvents(List<String> eventIds) {
    if (eventIds.isEmpty || !mounted) return;
    subscribedMultiInplayEventIds = eventIds;
    context.read<MultiEventsSignalRDataBloc>().add(MultiEventsSignalRDataListener());
    context.read<SubscribeMultiEventsSignalRBloc>().add(SubscribeMultiEventsSignalR(eventIds: eventIds));
  }

  void _removeEventFromList(List<String> eventIds) {
    final validIds = eventIds.where((eventId) => eventId.isNotEmpty && !removedEventIds.contains(eventId)).toList();
    if (validIds.isEmpty) return;

    setState(() {
      removedEventIds.addAll(validIds);
      for (final sport in eventData) {
        sport.event.removeWhere((e) => validIds.contains(e.id));
      }
      eventData.removeWhere((sport) => sport.event.isEmpty);
    });
  }

  void toggleBet({required Event event, required String price, required bool isBack, required AbcRunner? runner}) {
    final index = betSlipItems.indexWhere((b) => b.event.id == event.id && b.price == price && b.isBack == isBack);
    setState(() {
      if (index >= 0) {
        betSlipItems.removeAt(index);
      } else {
        activeTab = RightPanelTab.betSlip;
        betSlipItems.add(BetSlipItem(event: event, price: price, isBack: isBack, runner: runner));
      }
    });
  }

  void removeFromBetSlip(int index) {
    setState(() => betSlipItems.removeAt(index));
  }

  void _openSportTabForEvent({required Sport sport, required Event event}) {
    subscribedSingleInplayEventId = event.id;
    isRefreshed = false;
    context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sport.id));
    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: event.id));
    context.go(GoToRoute.sportEvent(sportId: sport.id, name: sport.name, eventId: event.id, inPlay: event.inPlay, premium: event.premiumMatch));
  }

  bool isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscribeMultiEventsSignalRBloc, SubscribeMultiEventsSignalRState>(
      listener: (context, state) {
        if (state is SubscribeMultiEventsSignalRSuccess || state is SubscribeMultiEventsSignalRFailure) {
          setState(() {
            isSuccess = true;
          });
        }
      },
      child: BlocListener<RemoveEventSignalRStreamerBloc, RemoveEventSignalRStreamerState>(
        listener: (context, state) {
          if (state is RemoveEventSignalRStreamerSuccess && state.forInplayIds.isNotEmpty) {
            _removeEventFromList(state.forInplayIds);
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final middleWidth = screenWidth * 0.70 - 20;
            final rightWidth = screenWidth * 0.30;
            return BlocConsumer<FetchOnlyInplayEventsBloc, FetchOnlyInplayEventsState>(
              listener: (context, state) {
                if (state is FetchOnlyInplayEventsSuccess) {
                  eventData = state.eventResponse.data
                      .map((sport) => Sport(
                            id: sport.id,
                            name: sport.name,
                            event: sport.event.where((e) => e.id != '28127348' && !removedEventIds.contains(e.id)).toList(),
                          ))
                      .where((sport) => sport.event.any((e) => e.inPlay == true))
                      .toList();
                  eventData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  final allEventIds = eventData.map((sport) => sport.event.map((e) => e.id).toList()).expand((ids) => ids).toList();
                  _connectMultiEvents(allEventIds);
                }
              },
              builder: (context, state) {
                if (state is FetchOnlyInplayEventsProgress) return const LoaderContainerWithMessage();
                if (state is FetchOnlyInplayEventsSuccess && eventData.isNotEmpty) {
                  return isSuccess == false
                      ? LoaderContainerWithMessage()
                      : SizedBox(
                          width: screenWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: middleWidth,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: eventData.map((sport) {
                                      final filteredEvents =
                                          sportsFilter.isEmpty || sportsFilter.contains('All') ? sport.event : sport.event.where((e) => sportsFilter.contains(e.name)).toList();
                                      return Column(
                                        children: [
                                          SportsHeader(title: capitalize(sport.name), color: darkGreen),
                                          SportsHighlightsHeader(type: 1, sid: sport.id),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: filteredEvents.map((event) {
                                              return RightClickWrapper(
                                                route: GoToRoute.sportEvent(
                                                  sportId: sport.id,
                                                  name: sport.name,
                                                  eventId: event.id,
                                                  inPlay: event.inPlay,
                                                  premium: event.premiumMatch,
                                                  fancyMarket: event.fancyMarket,
                                                ),
                                                child: SportsHighlightsTile(
                                                  sid: sport.id,
                                                  event: event,
                                                  action: () {
                                                    _openSportTabForEvent(sport: sport, event: event);
                                                  },
                                                  selectedBets: betSlipItems,
                                                  onLayBackTap: ({required event, required price, required isBack, required runner}) {
                                                    toggleBet(event: event, price: price, isBack: isBack, runner: runner);
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          hb20,
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: rightWidth,
                                child: BetsSlipTab(
                                  child: SportsBetSlipOrderCard(
                                    width: rightWidth,
                                    bets: betSlipItems,
                                    onClearAll: () => setState(() => betSlipItems.clear()),
                                    onRemove: removeFromBetSlip,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                }
                return const DataNotFound(message: 'No events available');
              },
            );
          },
        ),
      ),
    );
  }
}
