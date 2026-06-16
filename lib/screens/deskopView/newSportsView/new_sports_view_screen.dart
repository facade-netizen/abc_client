import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/miscBlocs/bet_slip_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/miscBlocs/sports_left_panel_bloc.dart';
import '../../../blocs/miscBlocs/sports_session_connect_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/me_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/competation_with_events_model.dart';
import '../../../models/event_with_type_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/loader.dart';
import '../../../routing/app_router.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../homeView/custom_footer_card.dart';
import '../homeView/one_click_bet_footer_card.dart';
import '../mainTabView/main_tab_menu_card.dart';
import '../openBetsView/bets_tab_item.dart';
import '../sportsReusables/highlights_filter.dart';
import '../sportsReusables/sports_header.dart';
import '../sportsReusables/sports_highlights_header.dart';
import '../sportsReusables/sports_highlights_tile.dart';
import '../sportsView/betSlipOrder/sports_bet_slip_order_card.dart';
import 'new_sports_bet_screen.dart';
import 'new_sports_com_tile.dart';

String politicsSID = "2378961";
String winnerEventId = "31345701";
String winnerScreenType = "FIFA World Cup Winner";
String formattedWinnerScreenType = formatScreenType(winnerScreenType);
bool horseAndGreyRacingEnabledForSid(String sid) {
  return (sid == "7") || (sid == "4339");
}

class NewSportsStreamer extends StatefulWidget {
  const NewSportsStreamer({super.key, required this.screenType, this.sid, this.initialEventId});

  final String screenType;
  final String? sid;
  final String? initialEventId;

  @override
  State<NewSportsStreamer> createState() => _NewSportsStreamerState();
}

class _NewSportsStreamerState extends State<NewSportsStreamer> {
  // Key _currentKey = UniqueKey();

  @override
  void initState() {
    context.read<SportsLeftPanelBloc>().add(ResetSportsPanel());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      //   key: _currentKey,
      child: BlocBuilder<FetchCompetitionWithEventsBloc, FetchCompetitionWithEventsState>(
        builder: (context, fcs) {
          if (fcs is FetchCompetitionWithEventsProgress || fcs is FetchCompetitionWithEventsInitial) {
            return const LoaderContainerWithMessage();
          }

          if (fcs is FetchCompetitionWithEventsSuccess && fcs.competationData.isNotEmpty && fcs.eventId == widget.sid) {
            return NewSportsViewScreen(competition: fcs.competationData, sid: widget.sid, screenType: widget.screenType, initialEventId: widget.initialEventId);
          }

          return DataNotFound(message: "${widget.screenType} data not available");
        },
      ),
    );
  }
}

class NewSportsViewScreen extends StatefulWidget {
  const NewSportsViewScreen({super.key, required this.competition, required this.screenType, this.sid, this.initialEventId});

  final String screenType;
  final List<Competition> competition;
  final String? sid;
  final String? initialEventId;

  @override
  State<NewSportsViewScreen> createState() => _NewSportsViewScreenState();
}

class _NewSportsViewScreenState extends State<NewSportsViewScreen> {
  bool showOrderWindow = false;
  bool _pendingLoad = false;

  Event? orderEvent;
  bool isSuccess = false;
  String _lastOpenedEventId = '';

  List<Event> _allEvents = [];
  List<String> subscribedMultiNewSportsEventIds = [];

  final List<String> highlightsDropdownList = ["Time", "Event"];
  String selectedSortOption = "Time";

  @override
  void didUpdateWidget(covariant NewSportsViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.sid != widget.sid || oldWidget.screenType != widget.screenType)) {
      setState(() {
        showOrderWindow = false;
        orderEvent = null;
        _pendingLoad = false;
        _lastOpenedEventId = "0";
        _allEvents.clear();
        subscribedMultiNewSportsEventIds.clear();
      });

      context.read<SportsLeftPanelBloc>().add(ResetSportsPanel());
    }
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;
  }

  void _handleInitialLogic() {
    context.read<SubscribeMultiEventsSignalRBloc>().add(DisconnectMultiEventsSignalR());
    final location = GoRouter.of(context).state.matchedLocation;
    if (widget.initialEventId != null && location.contains('event')) {
      final event = _allEvents.firstWhereOrNull((e) => e.id == widget.initialEventId);

      if (event != null) {
        _selectEvent(event, fromDeepLink: true);
      }
      return;
    }
    if (widget.screenType.toLowerCase() == formattedWinnerScreenType.toLowerCase()) {
      final winnerEvent = _allEvents.firstWhereOrNull((e) => e.id == winnerEventId);
      if (winnerEvent != null) {
        _selectEvent(winnerEvent);
      }
    }
  }

  void _removeEventFromList(List<String> eventIds) {
    final validIds = eventIds.where((eventId) => eventId.isNotEmpty).toList();
    if (validIds.isEmpty) return;
    final eventExists = _allEvents.any((e) => validIds.contains(e.id));
    log("Attempting to remove event with ids: $validIds, exists in list: $eventExists");
    if (!eventExists) return;
    setState(() {
      _allEvents.removeWhere((e) => validIds.contains(e.id));
      if (_allEvents.every((event) => !validIds.contains(event.id))) {
        if (orderEvent != null && validIds.contains(orderEvent!.id)) {
          orderEvent = null;
          showOrderWindow = false;
        }
      }
      if (validIds.contains(_lastOpenedEventId)) {
        _lastOpenedEventId = '0';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isRefreshed = false;

    _allEvents = widget.screenType.toLowerCase() == formattedWinnerScreenType.toLowerCase()
        ? widget.competition.expand((c) => c.events).toList().where((test) => test.id == winnerEventId).toList()
        : widget.competition.expand((c) => c.events).toList();

    context.read<SportsLeftPanelBloc>().add(InitSportsPanel(screenType: widget.screenType, competitions: widget.competition));
    if (widget.initialEventId == null) {
      context.read<SignalREventListenerBloc>().add(SignalREventDisconnect());
      _connectMultiEvents(_allEvents.map((e) => e.id).toList());
    }
    if (widget.initialEventId != null) {
      _handleInitialLogic();
    }
  }

  void _connectMultiEvents(List<String> eventIds) {
    if (eventIds.isEmpty) return;
    subscribedMultiNewSportsEventIds = eventIds;
    context.read<MultiEventsSignalRDataBloc>().add(MultiEventsSignalRDataListener());
    context.read<SubscribeMultiEventsSignalRBloc>().add(SubscribeMultiEventsSignalR(eventIds: eventIds));
  }

  List<Event> getSortedEvents() {
    final events = List<Event>.from(_allEvents).where((e) => e.id != winnerEventId).toList();
    if (selectedSortOption == 'Time') {
      events.sort((a, b) => a.openDate.compareTo(b.openDate));
    } else {
      events.sort((a, b) => a.name.compareTo(b.name));
    }
    return events;
  }

  void _selectEvent(Event event, {bool fromDeepLink = false}) {
    isSuccess = true;
    context.read<OddsProfitLossBloc>().add(SetToInitialOddsProfitLoss());
    context.read<SportsLeftPanelBloc>().add(SelectEvent(event));
    context.read<SportsLeftPanelBloc>().add(SelectMatchOdds(event: event));
    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: event.id));
    if (_lastOpenedEventId != "0" && _lastOpenedEventId != event.id) {
      sportsSessionConnect(ctxt: context, type: SessionType.disconnect, eventId: _lastOpenedEventId);
    }
    sportsSessionConnect(ctxt: context, type: SessionType.connect, eventId: event.id);
    if (fromDeepLink) {
      if (mounted) {
        setState(() {
          orderEvent = event;
          showOrderWindow = false;
          _pendingLoad = false;
        });
      }
    }
  }

  bool isSportSessionConnected = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SportsLeftPanelBloc, SportsLeftPanelState>(
      listener: (context, lps) {
        if (lps is SportsLeftPanelSuccess) {
          final sel = lps.selectedEvent;
          if (lps.viewMode == SportsViewMode.orderWindow && sel != null && isSportSessionConnected == false) {
            final selId = sel.id;
            _lastOpenedEventId = selId;
            setState(() {
              isSportSessionConnected = true;
              orderEvent = sel;
              showOrderWindow = true;
              _pendingLoad = false;
            });
          }
        }
      },
      child: BlocListener<RemoveEventSignalRStreamerBloc, RemoveEventSignalRStreamerState>(
        listener: (context, state) {
          if (state is RemoveEventSignalRStreamerSuccess && state.ids.isNotEmpty) {
            _removeEventFromList(state.ids);
          }
        },
        child: BlocListener<SubscribeMultiEventsSignalRBloc, SubscribeMultiEventsSignalRState>(
          listener: (context, state) {
            if (state is SubscribeMultiEventsSignalRSuccess || state is SubscribeMultiEventsSignalRFailure) {
              setState(() {
                isSuccess = true;
              });
            }
          },
          child: isSuccess == false && widget.initialEventId == null
              ? LoaderContainerWithMessage()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final leftWidth = screenWidth * 0.2;
                    final middleWidth = screenWidth * 0.55 - 10;
                    final rightWidth = screenWidth * 0.25;

                    final allEvents = getSortedEvents();

                    return BlocBuilder<BetSlipBloc, BetSlipState>(
                      builder: (context, betSlipState) {
                        final betSlipItems = betSlipState is BetSlipUpdated ? betSlipState.betSlipItems.cast<BetSlipItem>() : <BetSlipItem>[];
                        return Row(
                          children: [
                            /// LEFT PANEL
                            Container(
                              width: leftWidth,
                              color: white,
                              child: SportsLeftPanel(screenType: widget.screenType, competitions: widget.competition),
                            ),

                            /// MIDDLE
                            showOrderWindow && orderEvent != null
                                ? SizedBox(
                                    width: middleWidth + rightWidth + 10,
                                    child: NewSportsBetScreenStreamer(event: orderEvent!),
                                  )
                                : _pendingLoad
                                    ? SizedBox(width: middleWidth + rightWidth + 10, child: const LoaderContainerWithMessage())
                                    : Row(
                                        children: [
                                          SizedBox(
                                            width: middleWidth,
                                            child: Stack(
                                              children: [
                                                /// MAIN SCROLLABLE CONTENT
                                                Positioned.fill(
                                                  child: CustomScrollable(
                                                    children: [
                                                      /// BANNER
                                                      SportsBannerCard(
                                                        image: widget.sid == "4"
                                                            ? AppAssetConstants.cricketNew
                                                            : widget.sid == "1"
                                                                ? AppAssetConstants.sccoer
                                                                : widget.sid == "2"
                                                                    ? AppAssetConstants.tennisNew
                                                                    : widget.sid == "7"
                                                                        ? AppAssetConstants.horseRacingNew
                                                                        : widget.sid == "4339"
                                                                            ? AppAssetConstants.greyhoundRacingNew
                                                                            : widget.sid == "2378961"
                                                                                ? AppAssetConstants.politicsNew
                                                                                : '',
                                                      ),

                                                      /// FILTER
                                                      HighlightsFilter(
                                                        selectedItem: selectedSortOption,
                                                        dropdownItems: highlightsDropdownList,
                                                        onChanged: (p0) {
                                                          if (p0 != null) {
                                                            setState(() {
                                                              selectedSortOption = p0;
                                                            });
                                                          }
                                                        },
                                                      ),

                                                      /// HEADER
                                                      SportsHighlightsHeader(
                                                        sid: widget.sid,
                                                      ),

                                                      /// EVENTS
                                                      BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
                                                        builder: (context, fss) {
                                                          final defaultStake = fss is FetchFavStakeSuccess ? fss.favStakeData.defaultStake.toString() : '';

                                                          return Column(
                                                            children: [
                                                              ...allEvents.map(
                                                                (e) => RightClickWrapper(
                                                                  route: GoToRoute.sportEvent(
                                                                    sportId: widget.sid!,
                                                                    name: widget.screenType.toLowerCase().contains('fifa') ? 'Soccer' : widget.screenType,
                                                                    eventId: e.id,
                                                                    inPlay: e.inPlay,
                                                                    premium: e.premiumMatch,
                                                                  ),
                                                                  child: SportsHighlightsTile(
                                                                    sid: widget.sid,
                                                                    event: e,
                                                                    action: () {
                                                                      //isEntered = true;
                                                                      final current = GoRouter.of(context).state.matchedLocation;
                                                                      final next = GoToRoute.sportEvent(
                                                                        sportId: widget.sid!,
                                                                        name: widget.screenType,
                                                                        eventId: e.id,
                                                                        inPlay: e.inPlay,
                                                                        premium: e.premiumMatch,
                                                                        fancyMarket: e.fancyMarket,
                                                                      );
                                                                      if (current != next) {
                                                                        context.go(next);
                                                                      }
                                                                    },
                                                                    selectedBets: betSlipItems,
                                                                    onLayBackTap: ({
                                                                      required event,
                                                                      required price,
                                                                      required isBack,
                                                                      required runner,
                                                                    }) {
                                                                      context.read<BetSlipBloc>().add(
                                                                            AddBetSlipItem(
                                                                              event: event,
                                                                              price: price,
                                                                              isBack: isBack,
                                                                              runner: runner,
                                                                              defaultStake: defaultStake,
                                                                            ),
                                                                          );

                                                                      activeTab = RightPanelTab.betSlip;
                                                                    },
                                                                  ),
                                                                ),
                                                              ),

                                                              /// EXTRA SPACE FOR FOOTER
                                                              const SizedBox(height: 120),

                                                              /// FOOTER
                                                              const CustomFooterCard(),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                /// FLOATING FOOTER
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child: SizedBox(
                                                      width: screenWidth < 900 ? screenWidth * 0.8 : 820,
                                                      child: const OneClickBetFooterCard(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (!showOrderWindow || orderEvent == null)
                                            SizedBox(
                                              width: rightWidth,
                                              child: BetsSlipTab(
                                                child: SportsBetSlipOrderCard(
                                                  key: Key(DateTime.now().toIso8601String()),
                                                  width: rightWidth,
                                                  bets: betSlipItems,
                                                  onClearAll: () => context.read<BetSlipBloc>().add(ClearBetSlipItems()),
                                                  onRemove: (index) => context.read<BetSlipBloc>().add(RemoveBetSlipItem(index)),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// ============ SPORTS LEFT PANEL ============
class SportsLeftPanel extends StatelessWidget {
  final List<Competition> competitions;
  final String screenType;

  const SportsLeftPanel({super.key, required this.competitions, required this.screenType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SportsLeftPanelBloc, SportsLeftPanelState>(
      builder: (context, lps) {
        if (lps is! SportsLeftPanelSuccess) {
          return const SizedBox();
        }

        return Column(
          children: [
            // BREADCRUMBS
            Column(
              children: List.generate(lps.breadcrumbs.length, (i) {
                final isLast = i == lps.breadcrumbs.length - 1;
                return NewSportsComTile(
                  menu: lps.breadcrumbs[i],
                  selectedMenu: isLast ? lps.breadcrumbs[i] : '',
                  action: () {
                    context.read<SportsLeftPanelBloc>().add(NavigateBreadcrumb(i));
                  },
                );
              }),
            ),
            Expanded(child: _content(context, lps)),
          ],
        );
      },
    );
  }

  Widget _content(BuildContext context, SportsLeftPanelSuccess lps) {
    final selectedEve = lps.pendingEvent ?? lps.selectedEvent;
    switch (lps.viewMode) {
      case SportsViewMode.matchOdds:
      case SportsViewMode.orderWindow:
        return ListView(
          children: [
            RightClickWrapper(
              route:
                  '/sport/${lps.selectedEvent?.sid}/${lps.screenType.toLowerCase().contains('fifa') ? 'Soccer' : lps.screenType}/event/${lps.selectedEvent?.id}/${lps.selectedEvent?.inPlay}',
              child: NewSportsMatchOddsCTA(
                title: selectedEve?.id == winnerEventId ? "Winner" : 'Match Odds',
                inPlay: selectedEve?.inPlay ?? false,
                // mark selected when in orderWindow mode (order is open)
                isSelected: lps.viewMode == SportsViewMode.orderWindow && (lps.pendingEvent ?? lps.selectedEvent) != null,
                action: () {
                  // This will trigger orderWindow mode and open the order window
                  context.read<SportsLeftPanelBloc>().add(SelectMatchOdds(event: lps.pendingEvent ?? lps.selectedEvent));
                  context.read<SubscribeMultiEventsSignalRBloc>().add(DisconnectMultiEventsSignalR());
                  context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: (lps.pendingEvent ?? lps.selectedEvent)?.id ?? "0"));
                  final sportId = lps.selectedEvent?.sid;
                  final sportName = lps.screenType;
                  if (sportId != null) {
                    context.go(
                      GoToRoute.sportEvent(
                        sportId: sportId,
                        name: sportName.toLowerCase().contains('fifa') ? 'Soccer' : sportName,
                        eventId: lps.selectedEvent!.id,
                        inPlay: lps.selectedEvent!.inPlay,
                        premium: lps.selectedEvent!.premiumMatch,
                        fancyMarket: lps.selectedEvent!.fancyMarket,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );

      case SportsViewMode.events:
        return _events(context, lps);

      case SportsViewMode.competitions:
        return _competitions(context);
    }
  }

  // COMPETITIONS

  Widget _competitions(BuildContext context) {
    return ListView.builder(
      itemCount: competitions.length,
      itemBuilder: (context, i) {
        final c = competitions[i];
        return NewSportsComTile(
          menu: c.name,
          selectedMenu: '',
          action: () {
            context.read<SportsLeftPanelBloc>().add(SelectCompetition(competition: c, screenType: screenType, competitions: competitions));
          },
        );
      },
    );
  }

  Widget _events(BuildContext context, SportsLeftPanelSuccess lps) {
    if (lps.groupedEvents.isEmpty) {
      return const Center(child: Text("No events available"));
    }

    final keys = lps.groupedEvents.keys.toList()..sort();

    final allEvents = lps.groupedEvents.values.expand((e) => e).toList();
    final winnerEvent = allEvents.where((e) => e.id == winnerEventId).toList();

    return ListView.builder(
      itemCount: keys.length + 1,
      itemBuilder: (context, i) {
        if (i == keys.length) {
          if (winnerEvent.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              NewSportsMoreTileDate(),
              ...winnerEvent.map(
                (e) => NewSportsComTile(
                  menu: "Winner",
                  selectedMenu: (lps.pendingEvent ?? lps.selectedEvent)?.id == e.id ? "Winner" : '',
                  action: () {
                    context.go(GoToRoute.sport(sportId: "1", name: winnerScreenType));
                    context.read<OddsProfitLossBloc>().add(SetToInitialOddsProfitLoss());
                    context.read<SubscribeMultiEventsSignalRBloc>().add(DisconnectMultiEventsSignalR());
                    context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: "1"));
                    context.read<SportsLeftPanelBloc>().add(SelectEvent(e));
                    context.read<SportsLeftPanelBloc>().add(SelectMatchOdds(event: e));
                    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: e.id));
                  },
                ),
              ),
            ],
          );
        }

        /// ✅ SAFE ZONE
        final date = keys[i];
        final events = lps.groupedEvents[date]!;
        final filteredEvents = events.where((e) => e.id != winnerEventId).toList();

        final hasWinnerInThisGroup = events.any((e) => e.id == winnerEventId);

        if (hasWinnerInThisGroup) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewSportsComTileDate(date: date),
            ...filteredEvents.map(
              (e) => NewSportsComTile(
                menu: e.name,
                selectedMenu: (lps.pendingEvent ?? lps.selectedEvent)?.name ?? '',
                action: () {
                  context.read<SportsLeftPanelBloc>().add(SelectEvent(e));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
