import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../apis/apiHandlers/api_constants.dart';
import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_runners_pl_bloc.dart';
import '../../../blocs/miscBlocs/get_market_id_in_app_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../models/event_with_type_model.dart';
import '../../../models/fav_stake_model.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../models/odd_data_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/video_stream.dart';
import '../authView/desktop_login_view.dart';
import '../myAccountView/myAccountMenu/main_balance_overlay.dart';
import '../newSportsView/new_sports_com_tile.dart';
import '../openBetsView/bets_tab_item.dart';
import '../sportsView/betSlipOrder/sports_bet_slip_order_card_for_odds.dart';
import '../sportsView/bmBetView/bookmaker_view.dart';
import '../sportsView/cricScore/score_dashboard_iframe.dart';
import '../sportsView/fancyBetView/fancy_bet_header.dart';
import '../sportsView/fancyBetView/fancy_bet_tabs.dart';
import '../sportsView/fancyBetView/fancy_rule_book.dart';
import '../sportsView/matchOddsView/match_odds_header.dart';
import '../sportsView/matchOddsView/match_odds_tile_new.dart';
import '../sportsView/premiumView/new_premium_tabs.dart';
import '../homeView/one_click_bet_footer_card.dart';
import 'new_sports_view_screen.dart';

class NewSportsBetScreenStreamer extends StatelessWidget {
  const NewSportsBetScreenStreamer({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
      builder: (context, state) {
        return NewSportsBetScreen(
          event: event,
          favStakeData: state is FetchFavStakeSuccess ? state.favStakeData : null,
        );
      },
    );
  }
}

enum MarketSection { matchOdds, bookmaker, fancy, score }

class NewSportsBetScreen extends StatefulWidget {
  const NewSportsBetScreen({
    super.key,
    required this.event,
    this.favStakeData,
  });
  final FavStakeData? favStakeData;
  final Event event;

  @override
  State<NewSportsBetScreen> createState() => _NewSportsBetScreenState();
}

class _NewSportsBetScreenState extends State<NewSportsBetScreen> {
  final TextEditingController unit = TextEditingController();

  List<ODDSRunner> moData = [];
  int activeIndex = -1;
  int minBet = 1; // Add this variable
  bool _showLiveTv = false;
  ODDSRunner? selectedRunner;
  String? selectedPrice;
  double? selectedSize;
  bool isBackSelected = false;
  bool showStream = false;
  Map<int, double> runnerPLs = {};
  bool isFancyBet = true;

  List<BetSlipItemForOdds> betSlipItems = [];

  Set<MarketSection> expandedSections = {
    MarketSection.matchOdds,
    MarketSection.bookmaker,
    MarketSection.fancy,
  };

  String get _defaultStake => widget.favStakeData?.defaultStake.toString() ?? '';

  void _setDefaultStake() {
    unit.text = _defaultStake;
  }

  @override
  void initState() {
    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: widget.event.id));
    super.initState();
    _setDefaultStake();
    unit.addListener(_onMainStakeChanged);
    expandedSections = {
      MarketSection.matchOdds,
      MarketSection.score,
      if (widget.event.sid == "4") MarketSection.bookmaker,
      if (widget.event.sid == "4" || widget.event.sid == "1" || widget.event.sid == "2" || widget.event.sid == politicsSID) MarketSection.fancy,
    };
    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
  }

  /// Called when main stake input changes
  void _onMainStakeChanged() {
    final newStake = unit.text;

    // Update all bet slip items' stake
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
    // First recalculate all PLs based on current bets
    _updateAllRunnerPLsFromBetSlip();

    // Then sync main unit controller with active selection's stake
    if (activeIndex != -1 && selectedPrice != null && moData.isNotEmpty) {
      final bet = betSlipItems.firstWhereOrNull((b) => b.runner?.id == moData[activeIndex].id && b.price == selectedPrice && b.isBack == isBackSelected);
      if (bet != null) {
        // Only update if different to avoid infinite loop
        if (unit.text != bet.controller.text) {
          unit.text = bet.controller.text;
        }
      }
    }
  }

  /// Core method to calculate P&L for all runners based on all active bets
  void _updateAllRunnerPLsFromBetSlip() {
    if (moData.isEmpty) return;

    final Map<int, double> updatedPLs = {};

    // Initialize all runners with 0
    for (int i = 0; i < moData.length; i++) {
      updatedPLs[i] = 0.0;
    }

    // Calculate P&L for each active bet
    for (var bet in betSlipItems) {
      final stake = double.tryParse(bet.controller.text) ?? 0.0;
      if (stake <= 0) continue;

      final odds = double.tryParse(bet.price) ?? 0.0;
      if (odds <= 0) continue;

      final runnerIndex = moData.indexWhere((r) => r.id == bet.runner?.id);
      if (runnerIndex == -1) continue;

      // Calculate P&L for all runners for this bet
      for (int i = 0; i < moData.length; i++) {
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
          // Other runners
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

  void toggleSection(MarketSection section) {
    setState(() {
      if (expandedSections.contains(section)) {
        expandedSections.remove(section);
      } else {
        expandedSections.add(section);
      }
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
    required ODDSRunner runner,
    required String price,
    required bool isBack,
    double? size,
    String? defaultStake,
    int? runnerIndex,
  }) {
    final index = betSlipItems.indexWhere((b) => b.runner?.id == runner.id && b.price == price && b.isBack == isBack);

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
        final newBet = BetSlipItemForOdds(
          minBet: minBet,
          event: widget.event,
          price: price,
          isBack: isBack,
          runner: runner,
          defaultStake: stakeToUse,
          onStakeOrPriceChanged: _onBetSlipStakeOrPriceChanged,
        );
        betSlipItems.add(newBet);
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final screenWidth = constraints.maxWidth;
        final middleWidth = screenWidth * 0.70 - 10;
        final rightWidth = screenWidth * 0.30;
        final bool isFancyTab = widget.event.fancyMarket;
        final bool isPremiumMatch = widget.event.premiumMatch;
        return Stack(
          children: [
            Row(
              children: [
                /// MIDDLE SECTION
                SizedBox(
                  width: middleWidth,
                  child: CustomScrollable(
                    children: [
                      SportsBetHeader(
                        title: widget.event.name,
                        toggleExpand: () => toggleSection(MarketSection.score),
                        isExpanded: expandedSections.contains(MarketSection.score),
                      ),
                      if (expandedSections.contains(MarketSection.score) && widget.event.id != winnerEventId)
                        ScoreDashboardWithIframeLogic(
                          eventId: widget.event.id,
                          sportName: widget.event.sid == "4"
                              ? "cricket"
                              : widget.event.sid == "1"
                                  ? "soccer"
                                  : widget.event.sid == "2"
                                      ? "tennis"
                                      : "",
                        ),

                      /// MATCH ODDS SECTION
                      BlocListener<FetchODDSDataBloc, FetchODDSDataState>(
                        listenWhen: (prev, curr) => curr is FetchODDSDataSuccess,
                        listener: (context, state) {
                          if (state is FetchODDSDataSuccess) {
                            final data = state.oddsResponse.data;
                            if (data.runners.isNotEmpty) {
                              context.read<FetchOddsRunnerPLBloc>().add(FetchOddsRunnerPL(eventId: data.eventId, marketId: data.marketId));
                            }
                          }
                        },
                        child: BlocBuilder<FetchODDSDataBloc, FetchODDSDataState>(
                          builder: (context, state) {
                            if (state is FetchODDSDataSuccess) {
                              final data = state.oddsResponse.data;
                              moData = data.runners.where((runner) => runner.status == "ACTIVE").toList();
                              minBet = data.marketCondition.minBet;
                              if (moData.isEmpty) return const SizedBox();
                              return Column(
                                children: [
                                  ///add match odds Header
                                  BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                                    builder: (context, fes) {
                                      List<AddedMMEventItem> favEvents = [];
                                      if (fes is FetchAddedMMEventsSuccess) {
                                        favEvents = fes.favEvents;
                                      }
                                      final isFav = favEvents.any((fav) => fav.eventId == widget.event.id && fav.favType == FavType.odds);
                                      return MultiBlocListener(
                                        listeners: [
                                          BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                            listenWhen: (prev, curr) => curr is AddFavouriteEventsSuccess && prev is! AddFavouriteEventsSuccess,
                                            listener: (context, state) {
                                              if (state is AddFavouriteEventsSuccess && state.eventId == widget.event.id) {
                                                context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                              }
                                            },
                                          ),
                                          BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                            listenWhen: (prev, curr) => curr is RemoveFavouriteEventsSuccess && prev is! RemoveFavouriteEventsSuccess,
                                            listener: (context, state) {
                                              if (state is RemoveFavouriteEventsSuccess && state.eventId == widget.event.id) {
                                                context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                              }
                                            },
                                          ),
                                        ],
                                        child: BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                                          builder: (context, ucs) {
                                            SaveLoginTokenModel? userLogedinSaveData;
                                            if (ucs is UserAuthChangesSuccess) {
                                              userLogedinSaveData = ucs.savedUserAuth;
                                            }
                                            return MatchOddsAddFav(
                                              isFav: isFav,
                                              addFavAction: () {
                                                if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                                  if (isFav) {
                                                    context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: widget.event.id, favType: FavType.odds));
                                                  } else {
                                                    context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: widget.event.id, favType: FavType.odds));
                                                  }
                                                } else {
                                                  desktopLoginView(context);
                                                }
                                              },
                                              refreshAction: () {
                                                context.read<FetchODDSDataBloc>().add(FetchODDSData(eventId: data.eventId));
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  _buildMatchHeader(data),
                                  if (expandedSections.contains(MarketSection.matchOdds)) ...[
                                    MatchOddsBLHeader(
                                      selections: moData.length.toString(),
                                    ),
                                    _buildRunnerList(data),
                                    hb20,
                                  ],
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),

                      /// OTHER SECTIONS
                      if (widget.event.sid == "4" && !widget.event.id.toLowerCase().contains("sr"))
                        Column(
                          children: [
                            BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                              builder: (context, fes) {
                                List<AddedMMEventItem> favEvents = [];
                                if (fes is FetchAddedMMEventsSuccess) {
                                  favEvents = fes.favEvents;
                                }
                                final isFav = favEvents.any((fav) => fav.eventId == widget.event.id && fav.favType == FavType.bookmaker);
                                return MultiBlocListener(
                                  listeners: [
                                    BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                      listenWhen: (prev, curr) => curr is AddFavouriteEventsSuccess && prev is! AddFavouriteEventsSuccess,
                                      listener: (context, state) {
                                        if (state is AddFavouriteEventsSuccess && state.eventId == widget.event.id) {
                                          context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                        }
                                      },
                                    ),
                                    BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                      listenWhen: (prev, curr) => curr is RemoveFavouriteEventsSuccess && prev is! RemoveFavouriteEventsSuccess,
                                      listener: (context, state) {
                                        if (state is RemoveFavouriteEventsSuccess && state.eventId == widget.event.id) {
                                          context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                        }
                                      },
                                    ),
                                  ],
                                  child: BlocBuilder<GetMarketIDBloc, GetMarketIDState>(
                                    builder: (context, getIdState) {
                                      return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                                        builder: (context, ucs) {
                                          SaveLoginTokenModel? userLogedinSaveData;
                                          if (ucs is UserAuthChangesSuccess) {
                                            userLogedinSaveData = ucs.savedUserAuth;
                                          }
                                          return SportsBetHeader(
                                            leading: SvgPicture.asset(
                                              isFav ? AppAssetConstants.removemarket : AppAssetConstants.pinblue,
                                            ),
                                            action: () {
                                              if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                                if (getIdState is GetMarketIDSuccess) {
                                                  if (isFav) {
                                                    context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(
                                                          eventId: widget.event.id,
                                                          marketId: getIdState.bmMarketId,
                                                          favType: FavType.bookmaker,
                                                        ));
                                                  } else {
                                                    context.read<AddFavouriteEventsBloc>().add(
                                                          AddFavouriteEvents(
                                                            eventId: widget.event.id,
                                                            marketId: getIdState.bmMarketId,
                                                            favType: FavType.bookmaker,
                                                          ),
                                                        );
                                                  }
                                                }
                                              } else {
                                                desktopLoginView(context);
                                              }
                                            },
                                            title: "Bookmaker Market",
                                            toggleExpand: () => toggleSection(MarketSection.bookmaker),
                                            isExpanded: expandedSections.contains(MarketSection.bookmaker),
                                            child: Text("| Zero Commission", style: TextStyle(color: greyShade)),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            if (expandedSections.contains(MarketSection.bookmaker))
                              BookmakerView(
                                event: widget.event,
                                favStakeData: widget.favStakeData,
                              ),
                            if (!expandedSections.contains(MarketSection.bookmaker)) hb10,
                          ],
                        ),
                      if (isFancyTab || isPremiumMatch) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isFancyTab && isPremiumMatch)
                                  FancyPremiumBetHeader(
                                    isFancyBet: isFancyBet,
                                    onTapInfo: () {
                                      showFancyRulesDialog(context);
                                    },
                                  )
                                else if (isFancyTab)
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: darkGreen,
                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Fancy Bet',
                                            style: TextStyle(color: white, fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: InkWell(
                                              onTap: () {
                                                showFancyRulesDialog(context);
                                              },
                                              child: Icon(Icons.info, color: whiteOpac, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (isPremiumMatch)
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      gradient: premiumGradient,
                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Premium Fancy Bet',
                                            style: TextStyle(color: white, fontWeight: FontWeight.bold),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: InkWell(
                                              onTap: () {
                                                showFancyRulesDialog(context);
                                              },
                                              child: Icon(Icons.info, color: whiteOpac, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (isFancyTab && isPremiumMatch)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isFancyBet = !isFancyBet;
                                      });
                                    },
                                    child: Container(
                                      height: 30,
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: darkGreen,
                                        borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isFancyBet ? 'Premium Fancy Bet' : 'Fancy Bet',
                                          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                child: InkWell(
                                  onTap: () {
                                    toggleSection(MarketSection.fancy);
                                  },
                                  child: const Icon(Icons.add_box_outlined, size: 18, color: darkGreen),
                                ),
                              ),
                            ),
                          ],
                        ),
                        hb10,
                        if (expandedSections.contains(MarketSection.fancy))
                          if (isFancyTab && isPremiumMatch)
                            if (isFancyBet)
                              FancyBetStreamer(event: widget.event, favStakeData: widget.favStakeData)
                            else
                              NewPremiumStreamer(eventId: widget.event.id, sid: widget.event.sid)
                          else if (isFancyTab)
                            FancyBetStreamer(event: widget.event, favStakeData: widget.favStakeData)
                          else if (isPremiumMatch)
                            NewPremiumStreamer(eventId: widget.event.id, sid: widget.event.sid),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),

                /// RIGHT PANEL - Bet Slip
                SizedBox(
                  width: rightWidth,
                  child: Column(
                    children: [
                      if (widget.event.inPlay) ...[
                        BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                          builder: (context, state) {
                            return state is UserAuthChangesSuccess && state.savedUserAuth != null
                                ? Container(
                                    height: 24,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    color: darkGreen,
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Live TV',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          height: 18,
                                          child: Transform.scale(
                                            scale: 0.80,
                                            alignment: Alignment.center,
                                            child: Switch(
                                              value: _showLiveTv,
                                              onChanged: (value) => setState(() => _showLiveTv = value),
                                              activeThumbColor: white,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                        if (_showLiveTv)
                          ValueListenableBuilder<bool>(
                            valueListenable: mainBalanceOverlayOpenNotifier,
                            builder: (context, isOverlayOpen, child) {
                              return Stack(
                                children: [
                                  // Video container - always present but hidden when overlay is open
                                  Offstage(
                                    offstage: isOverlayOpen,
                                    child: IframeVideoContainer(
                                      height: 180,
                                      width: double.infinity,
                                      videoUrl: "$streamUrl1${widget.event.id}",
                                    ),
                                  ),
                                  // Overlay container - shown when needed
                                  if (isOverlayOpen)
                                    Container(
                                      height: 180,
                                      color: Colors.black,
                                    ),
                                ],
                              );
                            },
                          ),
                      ],
                      Expanded(
                        child: BetsSlipTab(
                          child: SportsBetSlipOrderCardForOdds(
                            width: rightWidth,
                            bets: betSlipItems,
                            onClearAll: onClearAll,
                            onRemove: removeFromBetSlip,
                            onStakeOrPriceChanged: _updateAllRunnerPLsFromBetSlip,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.event.bookMakerMarket || widget.event.fancyMarket || widget.event.oddsMarket)
              Positioned(
                right: screenWidth * 0.30,
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: screenWidth < 900 ? screenWidth * 0.8 : 820,
                    child: const OneClickBetFooterCard(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMatchHeader(ODDSData data) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, state) {
        return MatchOddsHeader(
          event: widget.event,
          data: data,
          onTap: () => setState(() => showStream = !showStream),
          toggleExpand: () => toggleSection(MarketSection.matchOdds),
          isExpanded: expandedSections.contains(MarketSection.matchOdds),
        );
      },
    );
  }

  Widget _buildRunnerList(ODDSData data) {
    return Column(
      children: List.generate(moData.length, (index) {
        final runner = moData[index];

        return MatchOddsTileNew(
          unit: unit,
          runner: runner,
          idx: index,
          favStakeData: widget.favStakeData,
          activeIndex: activeIndex,
          currentPL: runnerPLs[index] ?? 0.0,
          eventId: data.eventId.toString(),
          marketId: data.marketId,
          marketType: data.marketType,
          marketName: data.marketName,
          deylay: data.marketCondition.betDelay,
          sid: widget.event.sid,
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
            toggleBet(
              runner: runner,
              price: price,
              size: size,
              isBack: isBack,
              defaultStake: unit.text,
              runnerIndex: index,
            );
          },
        );
      }),
    );
  }
}

class MatchOddsAddFav extends StatelessWidget {
  const MatchOddsAddFav({
    super.key,
    this.addFavAction,
    this.refreshAction,
    this.isFav = false,
  });
  final void Function()? addFavAction;
  final void Function()? refreshAction;
  final bool isFav;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      color: white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              InkWell(
                onTap: addFavAction,
                child: Container(
                  height: 30,
                  width: 120,
                  decoration: BoxDecoration(
                    color: isFav ? green : darkGreen,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AppAssetConstants.pinblue, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 22, width: 22),
                  ),
                ),
              ),
              VerticalDivider(
                color: white,
                width: 1,
              ),
              InkWell(
                onTap: refreshAction,
                child: Container(
                  height: 30,
                  width: 120,
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AppAssetConstants.refersh, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 22, width: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
