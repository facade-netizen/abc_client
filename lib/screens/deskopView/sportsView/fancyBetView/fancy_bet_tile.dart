import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../models/fancy_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/style.dart';
import '../../sportsReusables/custom_cta_button.dart';
import '../../sportsReusables/quick_bet_animation.dart';
import '../matchOddsView/match_odds_header.dart';
import 'fancy_bet_header.dart';
import 'fancy_placebet_card.dart';
import 'show_fancy_book_view.dart';

class FancyBetTile extends StatefulWidget {
  const FancyBetTile({
    super.key,
    required this.eventId,
    required this.idx,
    required this.action,
    required this.fancyBet,
    required this.activeIndex,
    this.favStakeData,
    required this.marketType,
    required this.marketName,
    required this.eventName,
  });
  final FavStakeData? favStakeData;
  final int idx;
  final int activeIndex;
  final String eventId;
  final String marketType;
  final String marketName;
  final String eventName;
  final FancyMarketData fancyBet;
  final Function(int) action;

  @override
  State<FancyBetTile> createState() => _FancyBetTileState();
}

class _FancyBetTileState extends State<FancyBetTile> {
  final TextEditingController unit = TextEditingController();

  bool isBack = false; // true = BACK, false = LAY
  String selectedPrice = '';
  String selectedLine = '';
  String runnerId = '';
  String lay1Price = '';
  String back1Price = '';

  // For THREE_SELECTIONS markets
  String back2Price = '';
  String back2Line = '';
  String lay2Price = '';
  String lay2Line = '';

  // Track which button is active (row and selection)
  String? activeButtonKey;

  FancyRunner? lastValidRunner;

  /// Hover
  bool isHovered = false;
  bool isClicked = false;

  /// Flash logic
  final Map<String, Color> flashColors = {};
  final Map<String, double> previousPrices = {};
  Timer? _flashTimer;
  final Map<String, FancyRunnerPLData> _plCache = {};

  @override
  void initState() {
    super.initState();
    unit.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    unit.dispose();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _select(String buttonKey, bool yes, String price, String line) {
    if (widget.activeIndex != widget.idx) {
      widget.action(widget.idx);
    }

    final defaultStake = widget.favStakeData?.defaultStake.toString() ?? '';
    setState(() {
      activeButtonKey = buttonKey;
      isBack = yes; // true for BACK, false for LAY
      selectedPrice = price;
      selectedLine = line;
      isClicked = !isClicked;

      // ✅ IMPORTANT FIX: set unit value
      if (defaultStake.isNotEmpty) {
        unit.text = defaultStake;
      }
    });
  }

  void _reset() {
    widget.action(-1);
    setState(() {
      activeButtonKey = null;
      isBack = false;
      selectedPrice = '';
      selectedLine = '';
      unit.clear();
    });
  }

  /// DETECT PRICE CHANGES (BACKS1/LAYS1) - Fixed naming
  void detectPriceChanges(FancyRunner? newRunner) {
    if (newRunner == null) return;
    final marketId = widget.fancyBet.marketId;
    final isThreeSelections = widget.fancyBet.marketType.startsWith("THREE_SELECTIONS");

    // BACKS1 - First selection backs
    if (newRunner.backs.isNotEmpty) {
      final currentPrice = newRunner.backs.first.price.toDouble();
      final backs1Key = '$marketId-BACKS1';
      if (previousPrices.containsKey(backs1Key)) {
        final prevPrice = previousPrices[backs1Key]!;
        if (currentPrice > prevPrice) {
          flashColors[backs1Key] = priceIncreased;
        } else if (currentPrice < prevPrice) {
          flashColors[backs1Key] = priceDecreased;
        }
      }
      previousPrices[backs1Key] = currentPrice;
    }

    // LAYS1 - First selection lays
    if (newRunner.lays.isNotEmpty) {
      final currentPrice = newRunner.lays.first.price.toDouble();
      final lays1Key = '$marketId-LAYS1';

      if (previousPrices.containsKey(lays1Key)) {
        final prevPrice = previousPrices[lays1Key]!;
        if (currentPrice > prevPrice) {
          flashColors[lays1Key] = priceIncreased;
        } else if (currentPrice < prevPrice) {
          flashColors[lays1Key] = priceDecreased;
        }
      }
      previousPrices[lays1Key] = currentPrice;
    }

    // For THREE_SELECTIONS markets - Second selection
    if (isThreeSelections) {
      // BACKS2 (second backs)
      if (newRunner.backs.length > 1) {
        final currentPrice = newRunner.backs[1].price.toDouble();
        final backs2Key = '$marketId-BACKS2';

        if (previousPrices.containsKey(backs2Key)) {
          final prevPrice = previousPrices[backs2Key]!;
          if (currentPrice > prevPrice) {
            flashColors[backs2Key] = pinkButtonClr;
          } else if (currentPrice < prevPrice) {
            flashColors[backs2Key] = oddsBackBtn;
          }
        }
        previousPrices[backs2Key] = currentPrice;
      }

      // LAYS2 (second lays)
      if (newRunner.lays.length > 1) {
        final currentPrice = newRunner.lays[1].price.toDouble();
        final lays2Key = '$marketId-LAYS2';

        if (previousPrices.containsKey(lays2Key)) {
          final prevPrice = previousPrices[lays2Key]!;
          if (currentPrice > prevPrice) {
            flashColors[lays2Key] = pinkButtonClr;
          } else if (currentPrice < prevPrice) {
            flashColors[lays2Key] = oddsBackBtn;
          }
        }
        previousPrices[lays2Key] = currentPrice;
      }
    }

    // Clear flash after 3 seconds
    if (flashColors.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => flashColors.clear());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bet = widget.fancyBet;
    final isActive = widget.activeIndex == widget.idx;
    final marketId = bet.marketId;
    final isThreeSelections = bet.marketType.startsWith("THREE_SELECTIONS");

    return BlocListener<SendOrderBloc, SendOrderState>(
      listener: (_, s) {
        if (s is SendOrderSuccess) _reset();
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: isHovered ? highlightTileHover : white,
            border: const Border(
              bottom: BorderSide(color: black, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Combined PL data using nested BlocSelectors with proper builder
                  BlocSelector<FetchFancyRunnerPLBloc, FetchFancyRunnerPLState, FancyRunnerPLData?>(
                    selector: (state) {
                      if (state is FetchFancyRunnerPLSuccess) {
                        return state.runnerPl.firstWhereOrNull((e) => e.runnerId == marketId);
                      }
                      return null;
                    },
                    builder: (context, runnerPLData) {
                      return BlocSelector<FancyProfitLossBloc, FancyProfitLossState, FancyRunnerPLData?>(
                        selector: (state) {
                          if (state is FancyProfitLossSuccess) {
                            final found = state.fancyPl.firstWhereOrNull((e) => e.runnerId == marketId);
                            return found;
                          }
                          return null;
                        },
                        builder: (context, profitLossData) {
                          FancyRunnerPLData? plData;

                          if (profitLossData != null && profitLossData.runnerId == marketId) {
                            _plCache[marketId] = profitLossData;
                            plData = profitLossData;
                          } else if (runnerPLData != null && runnerPLData.runnerId == marketId) {
                            _plCache[marketId] = runnerPLData;
                            plData = runnerPLData;
                          } else {
                            plData = _plCache[marketId];
                          }
                          final isShowBook = plData != null && plData.runnerId == marketId;
                          return FancyBetName(
                            key: ValueKey('${unit.text}_${plData?.net ?? 0}'),
                            bet: bet,
                            isActive: isActive,
                            fancyNetVisible: isShowBook,
                            fancyNet: isShowBook && plData.net != 0
                                ? plData.net > 0
                                    ? plData.net.toStringAsFixed(2)
                                    : "(${plData.net.abs().toStringAsFixed(2)})"
                                : '',
                            color: isShowBook && plData.net > 0 ? green : red,
                            fancyExposure: (() {
                              final stake = double.tryParse(unit.text) ?? 0.0;
                              if (stake > 0) {
                                if (!isBack) {
                                  double priceVal = double.tryParse(isThreeSelections ? lay2Price : lay1Price) ?? 0.0;
                                  final exposure = (plData?.net ?? 0) - (priceVal * stake / 100);
                                  return "(${exposure.toStringAsFixed(2).replaceAll('-', "")})";
                                } else {
                                  double priceVal = double.tryParse(isThreeSelections ? back2Price : back1Price) ?? 0.0;
                                  final exposure = (plData?.net ?? 0) + priceVal;
                                  return "(${exposure.toStringAsFixed(2).replaceAll('-', "")})";
                                }
                              }
                              return '';
                            })(),
                            showBook: isShowBook && plData.net != 0,
                            bookAction: () {
                              context.read<FetchFancyBookBloc>().add(FetchFancyBook(marketId: bet.marketId));
                              showFancyBookView(context, bet.marketName);
                            },
                          );
                        },
                      );
                    },
                  ),
                  Column(
                    children: [
                      BlocBuilder<SignalRFancyDataBloc, SignalRFancyDataState>(
                        builder: (_, frd) {
                          FancyRunner? runner;

                          if (frd is SignalRFancyDataSuccess) {
                            final market = frd.fancy.values.where((m) => m.marketId == marketId).toList();

                            if (market.isNotEmpty && market.first.runners.isNotEmpty) {
                              runner = market.first.runners.first;
                              lastValidRunner = runner;
                            }
                          }

                          runner ??= lastValidRunner;

                          detectPriceChanges(runner);

                          /// Runner null fallback
                          final hasBacks1 = runner?.backs.isNotEmpty ?? false;
                          final hasLays1 = runner?.lays.isNotEmpty ?? false;

                          back1Price = runner?.backs.isNotEmpty == true ? runner!.backs.first.price.toString() : ''; // BACKS1
                          final back1Line = runner?.backs.isNotEmpty == true ? runner!.backs.first.line.toString() : '';

                          lay1Price = runner?.lays.isNotEmpty == true ? runner!.lays.first.price.toString() : ''; // LAYS1
                          final lay1Line = runner?.lays.isNotEmpty == true ? runner!.lays.first.line.toString() : '';

                          runnerId = runner?.id ?? '';

                          return BlocBuilder<SendOrderBloc, SendOrderState>(
                            builder: (context, oss) {
                              return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
                                builder: (context, fostate) {
                                  return Stack(
                                    children: [
                                      Row(
                                        children: [
                                          // LAYS1 button
                                          YesNoCTAButton(
                                            key: ValueKey('$marketId-LAYS1'),
                                            type: 0, // LAY type
                                            active: isActive && activeButtonKey == '1_lays1',
                                            price: lay1Price,
                                            line: lay1Line,
                                            isFlash: flashColors.containsKey('$marketId-LAYS1'),
                                            flashColor: flashColors['$marketId-LAYS1'],
                                            action: hasLays1
                                                ? () {
                                                    if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                                      final qty = fostate.oneClickData.defaultStake;
                                                      Map<String, dynamic> orderBaseModel = {
                                                        "bettingType": 1,
                                                        "marketId": marketId.toString(),
                                                        "eventId": widget.eventId,
                                                        "runnerID": runnerId.toString(),
                                                        "marketType": widget.marketType,
                                                        "marketName": widget.marketName,
                                                        "eventName": widget.eventName,
                                                        "stake": qty,
                                                        "price": double.tryParse(lay1Price) ?? 0.0,
                                                        "line": "$back1Line,$lay1Line",
                                                        "side": "lay",
                                                        "runnerName": runner?.name ?? '',
                                                      };
                                                      context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.fancy));
                                                    } else {
                                                      _select('1_lays1', false, lay1Price, lay1Line);
                                                    }
                                                  }
                                                : null,
                                          ),
                                          // BACKS1 button
                                          YesNoCTAButton(
                                            key: ValueKey('$marketId-BACKS1'),
                                            type: 1, // BACK type
                                            active: isActive && activeButtonKey == '1_backs1',
                                            price: back1Price,
                                            line: back1Line,
                                            isFlash: flashColors.containsKey('$marketId-BACKS1'),
                                            flashColor: flashColors['$marketId-BACKS1'],
                                            action: hasBacks1
                                                ? () {
                                                    if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                                      final qty = fostate.oneClickData.defaultStake;
                                                      Map<String, dynamic> orderBaseModel = {
                                                        "bettingType": 1,
                                                        "marketId": marketId.toString(),
                                                        "eventId": widget.eventId,
                                                        "runnerID": runnerId.toString(),
                                                        "marketType": widget.marketType,
                                                        "marketName": widget.marketName,
                                                        "eventName": widget.eventName,
                                                        "stake": qty,
                                                        "price": double.tryParse(back1Price) ?? 0.0,
                                                        "line": "$back1Line,$lay1Line",
                                                        "side": "back",
                                                        "runnerName": runner?.name ?? '',
                                                      };
                                                      context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.fancy));
                                                    } else {
                                                      _select('1_backs1', true, back1Price, back1Line);
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),

                                      /// STATUS OVERLAY
                                      oss is SendOrderProgress && oss.eventId == widget.eventId.toString() && oss.marketId == marketId
                                          ? Container(
                                              height: 45,
                                              width: blw(context) * 2,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(color: applyOpacity(black, 0.2)),
                                              child: Center(
                                                child: Text("", style: b13ts(color: white)),
                                              ))
                                          : FBStatus(
                                              market: bet,
                                              backLine1: back1Line,
                                              layLine1: lay1Line,
                                              backLine2: '',
                                              layLine2: '',
                                            ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      /// THREE_SELECTIONS MARKET - Second Row
                      if (isThreeSelections)
                        BlocBuilder<SignalRFancyDataBloc, SignalRFancyDataState>(
                          builder: (_, frd) {
                            FancyRunner? runner;

                            if (frd is SignalRFancyDataSuccess) {
                              final market = frd.fancy.values.where((m) => m.marketId == marketId).toList();

                              if (market.isNotEmpty && market.first.runners.isNotEmpty) {
                                runner = market.first.runners.first;
                                lastValidRunner = runner;
                              }
                            }

                            runner ??= lastValidRunner;

                            detectPriceChanges(runner);

                            /// Runner null fallback for second row
                            final hasBacks2 = runner != null && runner.backs.length > 1 && runner.backs[1].price.toString() != '0';
                            final hasLays2 = runner != null && runner.lays.length > 1 && runner.lays[1].price.toString() != '0';

                            back2Price = runner != null && runner.backs.length > 1 ? runner.backs[1].price.toString() : '';
                            back2Line = runner != null && runner.backs.length > 1 ? runner.backs[1].line.toString() : '';

                            lay2Price = runner != null && runner.lays.length > 1 ? runner.lays[1].price.toString() : '';
                            lay2Line = runner != null && runner.lays.length > 1 ? runner.lays[1].line.toString() : '';

                            runnerId = runner?.id ?? '';

                            return Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      // LAYS2 button
                                      YesNoCTAButton(
                                        key: ValueKey('$marketId-LAYS2'),
                                        type: 0,
                                        active: isActive && activeButtonKey == '2_lays2',
                                        price: lay2Price,
                                        line: lay2Line,
                                        isFlash: flashColors.containsKey('$marketId-LAYS2'),
                                        flashColor: flashColors['$marketId-LAYS2'],
                                        action: hasLays2 ? () => _select('2_lays2', false, lay2Price, lay2Line) : null,
                                      ),
                                      // BACKS2 button
                                      YesNoCTAButton(
                                        key: ValueKey('$marketId-BACKS2'),
                                        type: 1,
                                        active: isActive && activeButtonKey == '2_backs2',
                                        price: back2Price,
                                        line: back2Line,
                                        isFlash: flashColors.containsKey('$marketId-BACKS2'),
                                        flashColor: flashColors['$marketId-BACKS2'],
                                        action: hasBacks2 ? () => _select('2_backs2', true, back2Price, back2Line) : null,
                                      ),
                                    ],
                                  ),

                                  /// STATUS OVERLAY for second row
                                  FBStatus(
                                    market: bet,
                                    backLine1: '',
                                    layLine1: '',
                                    backLine2: back2Line,
                                    layLine2: lay2Line,
                                    isSecondRow: true,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  FancyMmInfo(bet: bet),
                ],
              ),
              BlocListener<SignalRFancyDataBloc, SignalRFancyDataState>(
                listenWhen: (prev, curr) => curr is SignalRFancyDataSuccess,
                listener: (context, state) {
                  if (state is! SignalRFancyDataSuccess) return;

                  final marketId = widget.fancyBet.marketId;
                  final marketList = state.fancy.values.where((m) => m.marketId == marketId).toList();

                  if (marketList.isEmpty) return;

                  final m = marketList.first;
                  final runner = m.runners.isNotEmpty ? m.runners.first : null;
                  final activeStatuses = {'OPEN', 'ACTIVE', 'ONLINE'};

                  final status = m.status.toUpperCase();
                  final isThree = m.marketType.startsWith("THREE_SELECTIONS");

                  final hasBack1 = runner?.backs.isNotEmpty ?? false;
                  final hasLay1 = runner?.lays.isNotEmpty ?? false;

                  final hasBack2 = isThree && (runner != null && runner.backs.length > 1);
                  final hasLay2 = isThree && (runner != null && runner.lays.length > 1);

                  final noPrices = (!hasBack1 && !hasLay1) || (isThree && !hasBack2 && !hasLay2);

                  final shouldClose = !activeStatuses.contains(status) || noPrices || m.sportingEvent == true;
                  if (shouldClose && activeButtonKey != null) {
                    _reset();
                  }
                },
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        /// PLACE BET CARD
                        if (isActive && activeButtonKey != null && selectedPrice.isNotEmpty)
                          QuickBetAnimation(
                            key: ValueKey(isClicked),
                            isBackClicked: isClicked,
                            child: FancyPlaceBetCard(
                              runnerId: runnerId,
                              fancyMarketData: bet,
                              price: selectedPrice,
                              line: selectedLine,
                              isYes: isBack,
                              unit: unit,
                              cancel: _reset,
                              activeButtonKey: activeButtonKey,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
