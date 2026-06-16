import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/mm_bm_signalr_data_streamer.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/favourite_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../models/user_mm_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../sportsReusables/quick_bet_animation.dart';
import 'mm_bm_header.dart';
import 'mm_bm_placebet_card.dart';
import 'mm_bm_runner_feed.dart';

class MmBookmakerView extends StatefulWidget {
  const MmBookmakerView({
    super.key,
    required this.bmData,
    this.favStakeData,
  });
  final FavouriteEventData bmData;
  final FavStakeData? favStakeData;

  @override
  State<MmBookmakerView> createState() => _MmBookmakerViewState();
}

class _MmBookmakerViewState extends State<MmBookmakerView> {
  int activeIndex = -1;
  // Add this to show PL for all tiles in the view
  Map<int, double> runnerPLs = {};
  double? currentStake;
  double? currentOdds;
  bool? currentIsBack;
  int? currentRunnerIndex;

  void updateAllRunnerPLs(int selectedRunnerIndex, double stake, double odds, bool isBack) {
    runnerPLs.clear();

    final bms = context.read<FetchFavouriteBloc>().state;
    if (bms is! FetchFavouriteSuccess) return;

    final runners = widget.bmData.runners;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MmBookmakerMmTile(maxBet: 0, minBet: 0),
        MmBmBackLayHeader(),
        Column(
          children: List.generate(widget.bmData.runners.length, (index) {
            final runner = widget.bmData.runners[index];
            return MmBmTile(
              key: ValueKey(runner.id),
              runner: runner,
              favStakeData: widget.favStakeData,
              bmData: widget.bmData,
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
      ],
    );
  }
}

class MmBmTile extends StatefulWidget {
  final int idx;
  final int activeIndex;
  final FavouriteEventData bmData;
  final FavRunner runner;
  final Function(int) action;
  final double? currentPL;
  final Function(int, double, double, bool) updateAllPLs;
  final VoidCallback clearAllPLs;
  final FavStakeData? favStakeData;

  const MmBmTile({
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
  State<MmBmTile> createState() => _MmBmTileState();
}

class _MmBmTileState extends State<MmBmTile> {
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
  final Map<String, dynamic> _bmCache = {};
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
                  BlocSelector<FetchUserMMPLOddBMBloc, FetchUserMMPLOddBMState, UserMMOddBMPlRunner?>(
                    selector: (state) {
                      if (state is FetchUserMMPLOddBMSuccess) {
                        for (final market in state.runnerPl) {
                          final runner = market.runners.firstWhereOrNull((e) => e.runnerId == widget.runner.id);
                          if (runner != null) return runner;
                        }
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
                          dynamic plData;

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
                          return MmBmBetName(
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
                  BlocBuilder<SignalRMMBMDataBloc, SignalRMMBMDataState>(
                    builder: (context, bmr) {
                      AbcRunner? runner;
                      if (bmr is SignalRMMBMDataSuccess) {
                        runner = bmr.bm.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
                        currentRunner = runner;
                      }

                      return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
                        builder: (context, fostate) {
                          return MmBmRunnerFeedCTA(
                            key: ValueKey(widget.runner.id),
                            runner: widget.runner,
                            backActive: isActive && isBack == true,
                            layActive: isActive && isBack == false,
                            eventId: widget.bmData.id,
                            marketId: widget.bmData.marketId,
                            backAction: () {
                              final price = getCurrentPrice(true);
                              if (price != null) {
                                if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                  final qty = fostate.oneClickData.defaultStake;
                                  Map<String, dynamic> orderBaseModel = {
                                    "bettingType": 2,
                                    "marketId": widget.bmData.marketId.toString(),
                                    "eventId": widget.bmData.id.toString(),
                                    "runnerID": widget.runner.id.toString(),
                                    "marketType": widget.bmData.marketType,
                                    "marketName": widget.bmData.marketName,
                                    "eventName": widget.bmData.name,
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
                                    "eventId": widget.bmData.id.toString(),
                                    "runnerID": widget.runner.id.toString(),
                                    "marketType": widget.bmData.marketType,
                                    "marketName": widget.bmData.marketName,
                                    "eventName": widget.bmData.name,
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
              child: MmBMPlaceBetCard(
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
