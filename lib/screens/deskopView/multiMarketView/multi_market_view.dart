import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_mm_fancy_listener_bloc.dart';
import '../../../blocs/signalRBloc/signalr_mm_odds_bm_listener_bloc.dart';
import '../../../models/fav_stake_model.dart';
import '../../../models/favourite_model.dart';
import '../../../models/mm_fancy_model.dart';
import '../../../models/sport_category_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../homeView/one_click_bet_footer_card.dart';
import '../openBetsView/bets_tab_item.dart';
import 'mmOddsView/multi_market_tile.dart';
import '../newSportsView/new_sports_com_tile.dart';
import '../sportsReusables/sports_header.dart';
import '../sportsView/matchOddsView/match_odds_header.dart';
import 'mmBmView/mm_bookmaker_view.dart';
import 'mmFancyView/mm_fancy_bet_view.dart';
import 'mmOddsView/mm_match_odds_tile.dart';
import 'mmOddsView/fav_widgets.dart';
import 'mmOddsView/sports_bet_slip_order_card_for_mm_odds.dart';

class MultiMarketView extends StatefulWidget {
  const MultiMarketView({super.key, this.favStakeData, required this.favEvents, required this.fancyMarketData});
  final FavStakeData? favStakeData;
  final List<FavouriteEventData> favEvents;
  final List<List<MMFancyMarketData>> fancyMarketData;
  @override
  State<MultiMarketView> createState() => _MultiMarketViewState();
}

class _MultiMarketViewState extends State<MultiMarketView> {
  Map<String, Map<String, MMFancyMarketData>> fancyEventsById = {};
  List<FavouriteEventData> favEvents = [];
  List<FavouriteEventData> odds = [];
  List<FavouriteEventData> bmData = [];
  Set<String> _subscribedOddBMEventIds = {};
  Set<String> _subscribedFancyEventIds = {};

  ///
  final TextEditingController unit = TextEditingController();

  String selectedMarket = '';
  String? selectedSportId;
  List<FavRunner> moData = [];
  List<String> moDataEventIds = [];
  List<String> moDataMarketIds = [];
  int activeIndex = -1;
  FavRunner? selectedRunner;
  String? selectedPrice;
  double? selectedSize;
  bool isBackSelected = false;
  Map<int, double> runnerPLs = {};

  List<BetSlipItemForMmOdds> betSlipItems = [];

  String get _defaultStake => widget.favStakeData?.defaultStake.toString() ?? '';
  bool isSyncingUnit = false;

  void _setDefaultStake() {
    unit.text = _defaultStake;
  }

  /// Called when main stake input changes
  void _onMainStakeChanged() {
    if (isSyncingUnit) return;

    final newStake = unit.text;

    // Update all bet slip items' stake only when the main stake input changes directly
    for (var bet in betSlipItems) {
      if (bet.controller.text != newStake) {
        bet.controller.text = newStake;
      }
    }

    // Recalculate all P&L
    _updateAllRunnerPLsFromBetSlip();
  }

  /// Called when any bet slip item's stake or price changes
  void _onBetSlipStakeOrPriceChanged() {
    // Recalculate all P&L based on current bets
    _updateAllRunnerPLsFromBetSlip();
  }

  /// Core method to calculate P&L for all runners based on all active bets
  void _updateAllRunnerPLsFromBetSlip() {
    if (moData.isEmpty) return;

    final Map<int, double> updatedPLs = {};

    // Initialize all runners with 0
    for (int i = 0; i < moData.length; i++) {
      updatedPLs[i] = 0.0;
    }

    // Calculate P&L for each active bet only within its own event/market
    for (var bet in betSlipItems) {
      final stake = double.tryParse(bet.controller.text) ?? 0.0;
      if (stake <= 0) continue;

      final odds = double.tryParse(bet.price) ?? 0.0;
      if (odds <= 0) continue;

      final betEventId = bet.event.id;
      final betMarketId = bet.event.marketId;

      int runnerIndex = -1;
      for (int i = 0; i < moData.length; i++) {
        if (moData[i].id == bet.runner?.id && moDataEventIds[i] == betEventId && moDataMarketIds[i] == betMarketId) {
          runnerIndex = i;
          break;
        }
      }
      if (runnerIndex == -1) continue;

      // Calculate P&L only for runners in the same event/market
      for (int i = 0; i < moData.length; i++) {
        if (moDataEventIds[i] != betEventId || moDataMarketIds[i] != betMarketId) continue;

        if (i == runnerIndex) {
          // Selected runner (where bet is placed)
          if (bet.isBack) {
            // BACK bet: profit = (odds - 1) * stake
            updatedPLs[i] = updatedPLs[i]! + ((odds - 1) * stake);
          } else {
            // LAY bet: loss = (odds - 1) * stake
            updatedPLs[i] = updatedPLs[i]! - ((odds - 1) * stake);
          }
        } else {
          // Other runners in same market only
          if (bet.isBack) {
            // If BACK on selected, other runners winning means loss of stake
            updatedPLs[i] = updatedPLs[i]! - stake;
          } else {
            // If LAY on selected, other runners winning means profit of stake
            updatedPLs[i] = updatedPLs[i]! + stake;
          }
        }
      }
    }

    setState(() {
      runnerPLs = updatedPLs;
    });
  }

  void clearAllPLs() {
    if (runnerPLs.isEmpty) return;
    setState(() {
      runnerPLs.clear();
    });
  }

  void cancelAction() {
    setState(() {
      unit.clear();
      selectedRunner = null;
      activeIndex = -1;
      clearAllPLs();
    });
  }

  void toggleBet({
    required FavouriteEventData event,
    required FavRunner runner,
    required String price,
    required bool isBack,
    double? size,
    String? defaultStake,
    int? runnerIndex,
  }) {
    final index = betSlipItems.indexWhere(
      (b) => b.runner?.id == runner.id && b.event.id == event.id && b.event.marketId == event.marketId && b.price == price && b.isBack == isBack,
    );

    setState(() {
      if (index >= 0) {
        // Dispose the bet item before removing
        betSlipItems[index].dispose();
        betSlipItems.removeAt(index);

        // If removing the active bet, clear active selection
        if (activeIndex == runnerIndex && selectedPrice == price && isBackSelected == isBack) {
          activeIndex = -1;
          selectedRunner = null;
          selectedPrice = null;
          isBackSelected = false;
        }
      } else {
        // Use default stake from favStakeData or current unit text or '100'
        final stakeToUse = defaultStake ?? _defaultStake;
        final newBet = BetSlipItemForMmOdds(
          minBet: 1,
          event: event,
          price: price,
          isBack: isBack,
          runner: runner,
          defaultStake: stakeToUse,
          onStakeOrPriceChanged: _onBetSlipStakeOrPriceChanged,
        );
        betSlipItems.add(newBet);
        selectedRunner = runner;
        selectedPrice = price;
        isBackSelected = isBack;
        if (runnerIndex != null) {
          activeIndex = runnerIndex;
        }
      }

      // Recalculate all P&L after adding/removing bet
      _updateAllRunnerPLsFromBetSlip();
    });
  }

  void removeFromBetSlip(int index) {
    final removedBet = betSlipItems[index];
    setState(() {
      // Dispose the bet item before removing
      removedBet.dispose();
      betSlipItems.removeAt(index);

      // If removing the active bet, clear active selection
      if (activeIndex != -1 && removedBet.runner?.id == moData[activeIndex].id && removedBet.price == selectedPrice && removedBet.isBack == isBackSelected) {
        activeIndex = -1;
        selectedRunner = null;
        selectedPrice = null;
        isBackSelected = false;
      }

      // Recalculate all P&L after removal
      _updateAllRunnerPLsFromBetSlip();
    });
  }

  void onClearAll() {
    setState(() {
      // Dispose all bet items
      for (var bet in betSlipItems) {
        bet.dispose();
      }
      betSlipItems.clear();
      clearAllPLs();
      activeIndex = -1;
      selectedRunner = null;
      selectedPrice = null;
      isBackSelected = false;
      // Reset to default stake instead of clearing
      _setDefaultStake();
    });
  }

  @override
  void dispose() {
    unit.removeListener(_onMainStakeChanged);
    unit.dispose();
    // Dispose all bet items
    for (var bet in betSlipItems) {
      bet.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setDefaultStake();
    unit.addListener(_onMainStakeChanged);
    favEvents = widget.favEvents;
    odds = favEvents.where((event) => event.favType == FavType.odds).toList();
    bmData = favEvents.where((event) => event.favType == FavType.bookmaker).toList();
    final combinedOddBMEventIds = {...bmData.map((e) => e.id), ...odds.map((e) => e.id)};
    if (combinedOddBMEventIds.isNotEmpty && combinedOddBMEventIds != _subscribedOddBMEventIds) {
      _subscribedOddBMEventIds = combinedOddBMEventIds;
      context.read<SignalRMMOddBMListenerBloc>().add(SignalRMMOddBMListener(eventId: combinedOddBMEventIds.toList()));
    }

    final fancyEventIds = widget.fancyMarketData.expand((entry) => entry).map((e) => e.eventId).toSet();
    if (fancyEventIds.isNotEmpty && fancyEventIds != _subscribedFancyEventIds) {
      _subscribedFancyEventIds = fancyEventIds;
      context.read<SignalRMMFancyListenerBloc>().add(SignalRMMFancyListener(eventId: fancyEventIds.toList()));
    }

    for (final eventMeta in widget.fancyMarketData.expand((entry) => entry)) {
      fancyEventsById.putIfAbsent(eventMeta.eventId, () => {})[eventMeta.marketId] = eventMeta;
    }

    // Keep a flattened list of odds runners so multi-market bet slip indexing works correctly.
    moData = [];
    moDataEventIds = [];
    moDataMarketIds = [];
    for (final event in odds) {
      for (final runner in event.runners) {
        moData.add(runner);
        moDataEventIds.add(event.id);
        moDataMarketIds.add(event.marketId);
      }
    }

    /// Match odds runner order map
    final Map<String, int> oddsRunnerOrder = {};
    for (int i = 0; i < odds.length; i++) {
      for (int j = 0; j < odds[i].runners.length; j++) {
        oddsRunnerOrder[odds[i].runners[j].name.toLowerCase()] = j;
      }
    }

    /// Sort bookmaker runners according to match odds
    for (final event in bmData) {
      event.runners.sort((a, b) {
        final aIndex = oddsRunnerOrder[a.name.toLowerCase()] ?? 999;
        final bIndex = oddsRunnerOrder[b.name.toLowerCase()] ?? 999;
        return aIndex.compareTo(bIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double leftWidth = screenWidth * 0.2;
        double middleWidth = screenWidth * 0.55 - 10;
        double rightWidth = screenWidth * 0.25;
        return Row(
          children: [
            /// LEFT MENU
            Container(
              width: leftWidth,
              color: white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SportsHeader(),
                  BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
                    builder: (context, scs) {
                      List<EventType> eventType = [];
                      if (scs is FetchSportsCategorySuccess) {
                        eventType = scs.categoryResponse.data;
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: eventType.length,
                          itemBuilder: (context, index) {
                            final eve = eventType[index];
                            return RightClickWrapper(
                              route: GoToRoute.sport(sportId: eve.id, name: eve.name),
                              child: MultiMarketTile(
                                market: eve.name,
                                selectedMarket: selectedMarket,
                                action: () {
                                  if (selectedMarket != eve.name) {
                                    setState(() {
                                      selectedMarket = eve.name;
                                      selectedSportId = eve.id;
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      context.go(GoToRoute.sport(sportId: eve.id, name: eve.name));
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// CENTER & RIGHT
            Row(
              children: [
                SizedBox(
                  width: middleWidth,
                  child: Stack(
                    children: [
                      fancyEventsById.isNotEmpty || odds.isNotEmpty || bmData.isNotEmpty
                          ? Positioned.fill(
                              child: CustomScrollable(
                                children: [
                                  hb10,
                                  HighlightText(
                                    "Multi Markets",
                                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),

                                  /// MATCH ODDS
                                  if (odds.isNotEmpty)
                                    Column(
                                      children: () {
                                        int globalIndex = 0;
                                        return odds.map((odd) {
                                          final eventStartIndex = globalIndex;
                                          final runnerTiles = List.generate(odd.runners.length, (index) {
                                            final runner = odd.runners[index];
                                            final currentIndex = eventStartIndex + index;
                                            globalIndex++;

                                            return MmMatchOddsTileNew(
                                              unit: unit,
                                              runner: runner,
                                              idx: currentIndex,
                                              activeIndex: activeIndex,
                                              favStakeData: widget.favStakeData,
                                              marketType: odd.marketType,
                                              marketName: odd.marketName,
                                              
                                              currentPL: runnerPLs[currentIndex] ?? 0.0,
                                              eventId: odd.id.toString(),
                                              marketId: odd.marketId,
                                              updateAllPLs: (selectedIndex, stake, odds, isBack) {
                                                // This is kept for compatibility but not used directly
                                              },
                                              clearAllPLs: clearAllPLs,
                                              action: (i) => setState(() => activeIndex = i),
                                              selectedBets: betSlipItems,
                                              onBetSlipSelected: (runner, price, size, isBack) {
                                                setState(() {
                                                  activeTab = RightPanelTab.betSlip;
                                                });
                                                toggleBet(event: odd, runner: runner, price: price, size: size, isBack: isBack, defaultStake: unit.text, runnerIndex: currentIndex);
                                              },
                                            );
                                          });

                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FavBetHeader(
                                                eventData: odd,
                                                removeMarket: () {
                                                  context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: odd.id, favType: FavType.odds));
                                                },
                                                refreshMarket: () {
                                                  context.read<FetchFavouriteBloc>().add(FetchFavourite());
                                                  context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
                                                },
                                                gotoMarket: () {
                                                  context.go(
                                                    GoToRoute.sportEvent(
                                                      sportId: odd.sid,
                                                      name: odd.sid == "4"
                                                          ? 'Cricket'
                                                          : odd.sid == "1"
                                                              ? 'Soccer'
                                                              : odd.sid == "0"
                                                                  ? 'Tennis'
                                                                  : "",
                                                      eventId: odd.id,
                                                      inPlay: odd.inPlay,
                                                      premium: odd.premiumMatch,
                                                      fancyMarket: odd.fancyMarket,
                                                    ),
                                                  );
                                                },
                                              ),
                                              MatchOddsBLHeader(selections: odd.runners.length.toString(), top: 5),
                                              Column(children: runnerTiles),
                                              hb15,
                                            ],
                                          );
                                        }).toList();
                                      }(),
                                    ),

                                  /// BOOKMAKER
                                  if (bmData.isNotEmpty)
                                    Column(
                                      children: bmData.map((bm) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FavBetHeader(
                                              eventData: bm,
                                              removeMarket: () {
                                                context
                                                    .read<RemoveFavouriteEventsBloc>()
                                                    .add(RemoveFavouriteEvents(eventId: bm.id, marketId: bm.marketId, favType: FavType.bookmaker));
                                              },
                                              refreshMarket: () {
                                                context.read<FetchFavouriteBloc>().add(FetchFavourite());
                                                context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
                                              },
                                              gotoMarket: () {
                                                context.go(
                                                  GoToRoute.sportEvent(
                                                    sportId: bm.sid,
                                                    name: bm.sid == "4"
                                                        ? 'Cricket'
                                                        : bm.sid == "1"
                                                            ? 'Soccer'
                                                            : bm.sid == "0"
                                                                ? 'Tennis'
                                                                : "",
                                                    eventId: bm.id,
                                                    inPlay: bm.inPlay,
                                                    premium: bm.premiumMatch,
                                                  ),
                                                );
                                              },
                                            ),
                                            MmBookmakerView(
                                              bmData: bm,
                                              favStakeData: widget.favStakeData,
                                            ),
                                            hb15,
                                          ],
                                        );
                                      }).toList(),
                                    ),

                                  ///fancy
                                  if (fancyEventsById.isNotEmpty)
                                    ...fancyEventsById.entries.map((entry) {
                                      final eventId = entry.key;
                                      final eventMarkets = entry.value;
                                      final eventMeta = eventMarkets.values.first;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FancyFavBetHeader(
                                            eventData: eventMeta,
                                            gotoMarket: () {
                                              context.go(
                                                GoToRoute.sportEvent(
                                                    sportId: eventMeta.sid ?? "",
                                                    name: eventMeta.sid == "4"
                                                        ? 'Cricket'
                                                        : eventMeta.sid == "1"
                                                            ? 'Soccer'
                                                            : eventMeta.sid == "0"
                                                                ? 'Tennis'
                                                                : "",
                                                    eventId: eventId,
                                                    inPlay: eventMeta.inPlay,
                                                    premium: eventMeta.premium ?? false,
                                                    fancyMarket: eventMeta.fancyMarket ?? false),
                                              );
                                            },
                                          ),
                                          MmFancyBetView(fancyMarkets: eventMarkets, favStakeData: widget.favStakeData),
                                        ],
                                      );
                                    }),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  hb10,
                                  HighlightText(
                                    "Multi Markets",
                                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  HighlightText(
                                    "There are currently no followed multi markets.",
                                    style: TextStyle(color: black, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        child: SizedBox(
                          width: middleWidth,
                          child: const OneClickBetFooterCard(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),

            /// RIGHT SIDE
            SizedBox(
              width: rightWidth,
              child: BetsSlipTab(
                child: SportsBetSlipOrderCardForMmOdds(
                  width: rightWidth,
                  bets: betSlipItems,
                  onClearAll: onClearAll,
                  onRemove: removeFromBetSlip,
                  onStakeOrPriceChanged: _updateAllRunnerPLsFromBetSlip,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
