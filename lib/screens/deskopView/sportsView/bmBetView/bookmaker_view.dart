// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../../blocs/miscBlocs/get_market_id_in_app_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../../models/book_maker_model.dart';
import '../../../../models/event_with_type_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/odd_data_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../sportsReusables/quick_bet_animation.dart';
import 'bm_header.dart';
import 'bm_placebet_card.dart';
import 'bm_runner_feed.dart';

class BookmakerView extends StatefulWidget {
  const BookmakerView({
    super.key,
    required this.event,
    this.favStakeData,
    this.matchOddsRunners,
  });
  final Event event;
  final FavStakeData? favStakeData;
  final List<ODDSRunner>? matchOddsRunners;

  @override
  State<BookmakerView> createState() => _BookmakerViewState();
}

class _BookmakerViewState extends State<BookmakerView> {
  int activeIndex = -1;
  // Add this to show PL for all tiles in the view
  Map<int, double> runnerPLs = {};
  double? currentStake;
  double? currentOdds;
  bool? currentIsBack;
  int? currentRunnerIndex;
  String? _lastRunnersLogKey;

  String _normalizeRunnerName(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  bool _runnerNamesMatch(String a, String b) {
    final normalizedA = _normalizeRunnerName(a);
    final normalizedB = _normalizeRunnerName(b);

    if (normalizedA == normalizedB) {
      return true;
    }

    const minSimilarityRatio = 0.75;
    if (normalizedA.contains(normalizedB) && normalizedB.length >= normalizedA.length * minSimilarityRatio) {
      return true;
    }
    if (normalizedB.contains(normalizedA) && normalizedA.length >= normalizedB.length * minSimilarityRatio) {
      return true;
    }

    return false;
  }

  void _logRunners({
    required List<ODDSRunner> oddsRunners,
    required List<BMRunner> bookmakerSourceRunners,
    required List<BMRunner> bookmakerComparedRunners,
  }) {
    final oddsNames = oddsRunners.map((e) => e.name).join(' | ');
    final bmSourceNames = bookmakerSourceRunners.map((e) => e.name).join(' | ');
    final bmComparedNames = bookmakerComparedRunners.map((e) => e.name).join(' | ');
    final logKey = '$oddsNames || $bmSourceNames || $bmComparedNames';

    if (_lastRunnersLogKey == logKey) return;
    _lastRunnersLogKey = logKey;

    // debugPrint('ODDS RUNNERS: $oddsNames');
    // debugPrint('BOOKMAKER RUNNERS SOURCE: $bmSourceNames');
    // debugPrint('BOOKMAKER RUNNERS COMPARED: $bmComparedNames');
  }

  List<ODDSRunner> _resolvedOddsRunners() {
    if (widget.matchOddsRunners != null && widget.matchOddsRunners!.isNotEmpty) {
      return widget.matchOddsRunners!;
    }

    final oddsState = context.read<FetchODDSDataBloc>().state;
    if (oddsState is FetchODDSDataSuccess && oddsState.oddsResponse.data.runners.isNotEmpty) {
      return oddsState.oddsResponse.data.runners;
    }

    return const <ODDSRunner>[];
  }

  List<BMRunner> _getComparedRunners(List<BMRunner> sourceRunners) {
    final oddsRunners = _resolvedOddsRunners();
    if (oddsRunners.isEmpty) {
      return sourceRunners;
    }

    final remaining = List<BMRunner>.from(sourceRunners);
    final ordered = <BMRunner>[];

    for (final oddRunner in oddsRunners) {
      final bmIndex = remaining.indexWhere(
        (bmRunner) => _runnerNamesMatch(bmRunner.name, oddRunner.name),
      );
      if (bmIndex >= 0) {
        ordered.add(remaining.removeAt(bmIndex));
      }
    }

    _logRunners(
      oddsRunners: oddsRunners,
      bookmakerSourceRunners: sourceRunners,
      bookmakerComparedRunners: ordered,
    );

    return ordered.isNotEmpty ? ordered : sourceRunners;
  }

  void updateAllRunnerPLs(int selectedRunnerIndex, double stake, double odds, bool isBack) {
    runnerPLs.clear();

    final bms = context.read<FetchBookMakerBloc>().state;
    if (bms is! FetchBookMakerSuccess) return;

    final runners = _getComparedRunners(bms.eventResponse.data.runners);

    for (int i = 0; i < runners.length; i++) {
      if (i == selectedRunnerIndex) {
        if (isBack) {
          runnerPLs[i] = (odds / 100) * stake;
        } else {
          runnerPLs[i] = -((odds / 100) * stake);
        }
      } else {
        if (isBack) {
          runnerPLs[i] = -stake;
        } else {
          runnerPLs[i] = stake;
        }
      }
    }

    currentStake = stake;
    currentOdds = odds;
    currentIsBack = isBack;
    currentRunnerIndex = selectedRunnerIndex;
    if (mounted) setState(() {});
  }

  // Clear all PL values when bet is cancelled
  void clearAllPLs() {
    runnerPLs.clear();
    currentStake = null;
    currentOdds = null;
    currentIsBack = null;
    currentRunnerIndex = null;
    if (mounted) setState(() {});
  }

  bool isBmPLFetched = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchBookMakerBloc, FetchBookMakerState>(
      builder: (context, bms) {
        List<BMRunner> runners = [];
        if (bms is FetchBookMakerSuccess) {
          context.read<GetMarketIDBloc>().add(GetMarketID(bms.eventResponse.data.marketId, ''));
          runners = _getComparedRunners(bms.eventResponse.data.runners);
          if (!isBmPLFetched) {
            context.read<FetchBMRunnerPLBloc>().add(FetchBMRunnerPL(eventId: bms.eventResponse.data.eventId, marketId: bms.eventResponse.data.marketId));
            isBmPLFetched = true;
          }
        }
        return bms is FetchBookMakerSuccess && runners.isNotEmpty
            ? Column(
                children: [
                  BookmakerMmTile(marketCondition: bms.eventResponse.data.marketCondition),
                  BMBackLayHeader(),
                  Column(
                    children: List.generate(runners.length, (index) {
                      final runner = runners[index];
                      return BmTile(
                        key: ValueKey(runner.id),
                        runner: runner,
                        favStakeData: widget.favStakeData,
                        bmData: bms.eventResponse.data,
                        idx: index,
                        activeIndex: activeIndex,
                        action: (int selectedIdx) {
                          setState(() {
                            activeIndex = selectedIdx;
                          });
                        },
                        currentPL: runnerPLs[index],
                        updateAllPLs: updateAllRunnerPLs,
                        clearAllPLs: clearAllPLs,
                      );
                    }),
                  ),
                  hb20,
                ],
              )
            : SizedBox();
      },
    );
  }
}

class BmTile extends StatefulWidget {
  final int idx;
  final int activeIndex;
  final BMData bmData;
  final BMRunner runner;
  final Function(int) action;
  final double? currentPL;
  final Function(int, double, double, bool) updateAllPLs;
  final VoidCallback clearAllPLs;
  final FavStakeData? favStakeData;

  const BmTile({
    super.key,
    required this.idx,
    required this.activeIndex,
    required this.bmData,
    required this.runner,
    required this.action,
    this.currentPL,
    required this.updateAllPLs,
    required this.clearAllPLs,
    this.favStakeData,
  });

  @override
  State<BmTile> createState() => _BmTileState();
}

class _BmTileState extends State<BmTile> {
  final TextEditingController unit = TextEditingController();
  bool? isBack;
  String selectedPrice = '';
  AbcRunner? currentRunner;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    unit.addListener(() {
      final stake = double.tryParse(unit.text) ?? 0.0;
      final odds = double.tryParse(selectedPrice) ?? 0.0;
      if (stake > 0 && odds > 0 && isBack != null) {
        widget.updateAllPLs(widget.idx, stake, odds, isBack!);
      } else if (unit.text.isEmpty) {
        widget.clearAllPLs();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    unit.dispose();
    super.dispose();
  }

  // Handle selection - get price from live data
  void handleSelection(bool back, String price) {
    widget.action(widget.idx);
    final defaultStake = widget.favStakeData?.defaultStake.toString() ?? '';
    setState(() {
      isBack = back;
      selectedPrice = price;
      isClicked = !isClicked;

      // ✅ IMPORTANT: set default stake
      if (defaultStake.isNotEmpty) {
        unit.text = defaultStake;
      }
    });

    final stake = double.tryParse(unit.text) ?? 0.0;
    final odds = double.tryParse(price) ?? 0.0;
    if (stake > 0 && odds > 0) {
      widget.updateAllPLs(widget.idx, stake, odds, back);
    }
  }

  String? getCurrentPrice(bool isBack) {
    if (currentRunner == null) return null;
    if (isBack) {
      // Get last back price (highest price)
      final backs = currentRunner!.backs;
      if (backs.isNotEmpty) {
        return backs.first.price.toString();
      }
    } else {
      // Get first lay price (lowest price)
      final lays = currentRunner!.lays;
      if (lays.isNotEmpty) {
        return lays.first.price.toString();
      }
    }
    return null;
  }

  // Reset the selection and close the bet card
  void cancelSelection() {
    widget.action(-1);
    widget.clearAllPLs();
    setState(() {
      selectedPrice = '';
      isBack = null;
      unit.clear();
    });
  }

  bool isHovered = false;
  final Map<String, BMRunnerPLData> _bmCache = {};
  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeIndex == widget.idx;

    return BlocListener<SendOrderBloc, SendOrderState>(
      listener: (context, sos) {
        if (sos is SendOrderSuccess) {
          cancelSelection();
        }
      },
      child: Column(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
                color: isHovered ? Color(0xFFFFFEEE) : creamyColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocSelector<FetchBMRunnerPLBloc, FetchBMRunnerPLState, BMRunnerPLData?>(
                    selector: (state) {
                      if (state is FetchBMRunnerPLSuccess) {
                        return state.runnerPl.firstWhereOrNull((e) => e.runnerId == widget.runner.id);
                      }
                      return null;
                    },
                    builder: (context, runnerPLData) {
                      return BlocSelector<BmProfitLossBloc, BmProfitLossState, BMRunnerPLData?>(
                        selector: (state) {
                          if (state is BmProfitLossSuccess) {
                            return state.bmPl.firstWhereOrNull((e) => e.runnerId == widget.runner.id);
                          }
                          return null;
                        },
                        builder: (context, profitLossData) {
                          BMRunnerPLData? plData;

                          if (profitLossData != null) {
                            _bmCache[widget.runner.id] = profitLossData;
                            plData = profitLossData;
                          } else if (runnerPLData != null) {
                            _bmCache[widget.runner.id] = runnerPLData;
                            plData = runnerPLData;
                          } else {
                            plData = _bmCache[widget.runner.id];
                          }

                          final isVisible = plData != null && plData.runnerId == widget.runner.id;
                          return BmBetName(
                            bmRunner: widget.runner,
                            currentPL: widget.currentPL,
                            bmNet: isVisible && plData.net > 0
                                ? plData.net.toStringAsFixed(2)
                                : isVisible && plData.net < 0
                                    ? "(${plData.net.abs().toStringAsFixed(2)})"
                                    : "",
                            bmNetVisible: isVisible,
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<SignalRBMDataBloc, SignalRBMDataState>(
                    builder: (context, bmr) {
                      AbcRunner? runner;
                      if (bmr is SignalRBMDataSuccess) {
                        runner = bmr.bm.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
                        currentRunner = runner;
                      }

                      return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
                        builder: (context, fostate) {
                          return BmRunnerFeedCTA(
                            key: ValueKey(widget.runner.id),
                            runner: widget.runner,
                            backActive: isActive && isBack == true,
                            layActive: isActive && isBack == false,
                            eventId: widget.bmData.eventId,
                            marketId: widget.bmData.marketId,
                            backAction: () {
                              final price = getCurrentPrice(true);
                              if (price != null) {
                                if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                  final qty = fostate.oneClickData.defaultStake;
                                  Map<String, dynamic> orderBaseModel = {
                                    "bettingType": 2,
                                    "marketId": widget.bmData.marketId.toString(),
                                    "eventId": widget.bmData.eventId.toString(),
                                    "runnerID": widget.runner.id.toString(),
                                    "marketType": widget.bmData.marketType,
                                    "marketName": widget.bmData.marketName,
                                    "eventName": widget.bmData.eventName,
                                    "stake": qty,
                                    "price": price.toString(),
                                    "line": "",
                                    "side": "back",
                                    "runnerName": widget.runner.name,
                                    "allRunnerIds": widget.bmData.runners.map((r) => r.id).toList(),
                                  };
                                  context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.bookMaker));
                                } else {
                                  handleSelection(true, price);
                                }
                              }
                            },
                            layAction: () {
                              final price = getCurrentPrice(false);
                              if (price != null) {
                                if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                  final qty = fostate.oneClickData.defaultStake;
                                  Map<String, dynamic> orderBaseModel = {
                                    "bettingType": 2,
                                    "marketId": widget.bmData.marketId.toString(),
                                    "eventId": widget.bmData.eventId.toString(),
                                    "runnerID": widget.runner.id.toString(),
                                    "marketType": widget.bmData.marketType,
                                    "marketName": widget.bmData.marketName,
                                    "eventName": widget.bmData.eventName,
                                    "stake": qty,
                                    "price": price.toString(),
                                    "line": "",
                                    "side": "lay",
                                    "runnerName": widget.runner.name,
                                    "allRunnerIds": widget.bmData.runners.map((r) => r.id).toList(),
                                  };
                                  context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.bookMaker));
                                } else {
                                  handleSelection(false, price);
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Show the betting card if active and a choice is made
          if (isActive && isBack != null && selectedPrice.isNotEmpty)
            QuickBetAnimation(
              key: ValueKey(isClicked),
              isBackClicked: isClicked,
              child: BMPlaceBetCard(
                bmData: widget.bmData,
                bmRunner: widget.runner,
                price: selectedPrice,
                isBack: isBack,
                unit: unit,
                cancel: cancelSelection,
              ),
            ),
        ],
      ),
    );
  }
}
