import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/mm_odds_signalr_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../constants/app_string_constants.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/favourite_model.dart';
import '../../../../models/oneclick_bet_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../models/user_mm_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/highlighted_text_widget.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/style.dart';
import 'sports_bet_slip_order_card_for_mm_odds.dart';
import '../../sportsView/matchOddsView/match_odds_header.dart';

class MmMatchOddsTileNew extends StatefulWidget {
  const MmMatchOddsTileNew({
    super.key,
    this.favStakeData,
    required this.runner,
    required this.idx,
    required this.activeIndex,
    required this.action,
    required this.onBetSlipSelected,
    required this.unit,
    required this.currentPL,
    required this.updateAllPLs,
    required this.clearAllPLs,
    required this.selectedBets,
    required this.eventId,
    required this.marketId,
    required this.marketType,
    required this.marketName,
  });

  final int idx;
  final int activeIndex;
  final FavRunner runner;
  final FavStakeData? favStakeData;
  final Function(int) action;
  final Function(FavRunner, String, double, bool) onBetSlipSelected;
  final TextEditingController unit;
  final double? currentPL;
  final Function(int, double, double, bool) updateAllPLs;
  final VoidCallback clearAllPLs;
  final List<BetSlipItemForMmOdds> selectedBets;
  final String eventId;
  final String marketId;
  final String marketType;
  final String marketName;

  @override
  State<MmMatchOddsTileNew> createState() => _MmMatchOddsTileNewState();
}

class _MmMatchOddsTileNewState extends State<MmMatchOddsTileNew> {
  String? activeBackKey;
  String? activeLayKey;
  bool isHovered = false;

  final Map<String, double> _previousPrices = {};
  final Map<String, Color> _flashColors = {};
  AbcRunner? _lastValidRunner;
  Timer? _flashTimer;

  bool get isActive => widget.activeIndex == widget.idx;

  @override
  void didUpdateWidget(covariant MmMatchOddsTileNew oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear active keys when bets are removed from slip (e.g. after order placed)
    if (activeBackKey != null) {
      final hasBack = widget.selectedBets.any(
        (b) => b.runner?.id == widget.runner.id && b.event.id == widget.eventId && b.event.marketId == widget.marketId && b.isBack,
      );
      if (!hasBack) activeBackKey = null;
    }
    if (activeLayKey != null) {
      final hasLay = widget.selectedBets.any(
        (b) => b.runner?.id == widget.runner.id && b.event.id == widget.eventId && b.event.marketId == widget.marketId && !b.isBack,
      );
      if (!hasLay) activeLayKey = null;
    }
  }

  bool isBetSelected(String price, bool isBack) => widget.selectedBets.any(
        (bet) => bet.runner?.id == widget.runner.id && bet.event.id == widget.eventId && bet.event.marketId == widget.marketId && bet.price == price && bet.isBack == isBack,
      );

  void _handleSelection(bool isBack, String key, String price, double size) {
    final bool isAlreadyInBetSlip = isBetSelected(price, isBack);

    setState(() {
      if (isAlreadyInBetSlip) {
        if (isBack) {
          activeBackKey = null;
        } else {
          activeLayKey = null;
        }
      } else {
        final existingBet = widget.selectedBets
            .firstWhereOrNull((bet) => bet.runner?.id == widget.runner.id && bet.event.id == widget.eventId && bet.event.marketId == widget.marketId && bet.isBack == isBack);
        if (existingBet != null) {
          widget.onBetSlipSelected(widget.runner, existingBet.price, 0, isBack);
        }

        widget.action(widget.idx);
        if (isBack) {
          activeBackKey = key;
        } else {
          activeLayKey = key;
        }
      }
    });

    widget.onBetSlipSelected(widget.runner, price, size, isBack);
  }

  void _checkPriceChanges(List<ABCPrice> prices, String side) {
    final Map<String, Color> newFlashColors = {};
    bool hasChanges = false;

    for (int i = 0; i < prices.length; i++) {
      final price = prices[i];
      final key = '${widget.runner.id}-$side-$i';
      final currentPrice = price.price.toDouble();

      if (_previousPrices.containsKey(key)) {
        final prevPrice = _previousPrices[key]!;
        if (currentPrice > prevPrice) {
          newFlashColors[key] = priceIncreased;
          hasChanges = true;
        } else if (currentPrice < prevPrice) {
          newFlashColors[key] = priceDecreased;
          hasChanges = true;
        }
      }

      _previousPrices[key] = currentPrice;
    }

    if (hasChanges && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _flashColors.addAll(newFlashColors));
          _flashTimer?.cancel();
          _flashTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) setState(() => _flashColors.clear());
          });
        }
      });
    }
  }

  Color _getButtonColor({
    required bool hasPrice,
    required bool isInBetSlip,
    required String key,
    required Color activeColor,
    required Color defaultColor,
    required double opacity,
  }) {
    if (_flashColors.containsKey(key)) return _flashColors[key]!;
    if (isInBetSlip && hasPrice) return activeColor;
    return applyOpacity(defaultColor, opacity);
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: isHovered ? highlightTileHover : white,
          border: Border(bottom: BorderSide(color: darkGreen, width: 0.8)),
        ),
        child: Row(
          children: [
            _buildRunnerName(),
            _buildOddsPrices(),
          ],
        ),
      ),
    );
  }

  Widget _buildRunnerName() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            const Icon(Icons.bar_chart, color: darkGreen, size: 18),
            wb10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightText(
                    widget.runner.name,
                    style: b14ts,
                    overflow: TextOverflow.ellipsis,
                  ),
                  MmMatchOddsTile(
                    runnerId: widget.runner.id,
                    currentPL: widget.currentPL,
                    eventId: widget.eventId,
                    marketId: widget.marketId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOddsPrices() {
    return BlocBuilder<SignalRMMODDSDataBloc, SignalRMMODDSDataState>(
      builder: (context, state) {
        final runner = _getRunner(state);

        List<ABCPrice> backs = getThreePrices(runner?.backs ?? []);
        List<ABCPrice> lays = getThreePrices(runner?.lays ?? []);

        final bool isSuspended = widget.runner.status.toLowerCase().contains('suspended') || widget.runner.status.toLowerCase().contains('loser');

        if (runner != null) {
          widget.runner.status = runner.status.name;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkPriceChanges(backs, 'BACK');
              _checkPriceChanges(lays, 'LAY');
            }
          });
        }

        return BlocBuilder<SendOrderBloc, SendOrderState>(
          builder: (context, state) {
            return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
              builder: (context, fostate) {
                return Stack(
                  children: [
                    Row(
                      children: [
                        ..._buildBackButtons(backs, fostate is FetchOneClickDataSuccess ? fostate.oneClickData : null),
                        ..._buildLayButtons(lays, fostate is FetchOneClickDataSuccess ? fostate.oneClickData : null),
                      ],
                    ),
                    if (isSuspended || (state is SendOrderProgress && state.eventId == widget.eventId.toString() && state.marketId == widget.marketId))
                      _buildStatusOverlay(orderProgress: state is SendOrderProgress ? "" : widget.runner.status.toUpperCase()),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  AbcRunner? _getRunner(SignalRMMODDSDataState state) {
    if (state is SignalRMMODDSDataSuccess) {
      final marketModel = state.oddsDataByMarket[widget.marketId];
      final runner = marketModel?.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
      if (runner != null) _lastValidRunner = runner;
    }
    return _lastValidRunner;
  }

  List<Widget> _buildBackButtons(List<ABCPrice> backs, OneClickBetData? oneClickData) {
    return backs.asMap().entries.toList().reversed.map((entry) {
      final index = entry.key;
      final price = entry.value.price;
      final size = entry.value.size;
      final key = '${widget.runner.id}-BACK-$index';
      final hasPrice = price > 0;
      final isInBetSlip = isBetSelected(price.toString(), true);
      // If we have a tracked activeBackKey, use it exclusively so edited price doesn't shift highlight
      final bool isActiveButton = activeBackKey != null ? (activeBackKey == key) : (isInBetSlip && hasPrice);
      return BackLayAllCTAButton(
        title: hasPrice ? price.toString() : ' ',
        value: hasPrice ? formattedAmounts(size.toDouble()) : ' ',
        isFlash: _flashColors.containsKey(key),
        disabled: hasPrice && price > maxPrice,
        color: _getButtonColor(
          hasPrice: hasPrice,
          isInBetSlip: isActiveButton,
          key: key,
          activeColor: oddsBackBtn,
          defaultColor: backBtn,
          opacity: getBackOpacity(index),
        ),
        active: isActiveButton,
        action: hasPrice && index == 0 && price <= maxPrice
            ? () {
                if (oneClickData != null && oneClickData.isClicked == true) {
                  final qty = oneClickData.defaultStake;
                  Map<String, dynamic> order = {
                    "bettingType": 0,
                    "marketId": widget.marketId,
                    "eventId": widget.eventId.toString(),
                    "runnerID": widget.runner.id.toString(),
                    "stake": qty,
                    "marketType": widget.marketType,
                    "marketName": widget.marketName,
                    "price": double.tryParse(price.toString()) ?? 0,
                    "line": "",
                    "side": "back",
                    "runnerName": widget.runner.name,
                  };
                  context.read<SendOrderBloc>().add(
                        SendOrder(
                          orderMap: order,
                          type: OrderType.oddsMatch,
                          marketDelay: 5,
                        ),
                      );
                } else {
                  _handleSelection(true, key, price.toString(), size.toDouble());
                }
              }
            : null,
      );
    }).toList();
  }

  List<Widget> _buildLayButtons(List<ABCPrice> lays, OneClickBetData? oneClickData) {
    return lays.asMap().entries.map((entry) {
      final index = entry.key;
      final price = entry.value.price;
      final size = entry.value.size;
      final key = '${widget.runner.id}-LAY-$index';
      final hasPrice = price > 0;
      final isInBetSlip = isBetSelected(price.toString(), false);
      // If we have a tracked activeLayKey, use it exclusively so edited price doesn't shift highlight
      final bool isActiveButton = activeLayKey != null ? (activeLayKey == key) : (isInBetSlip && hasPrice);

      return BackLayAllCTAButton(
        title: hasPrice ? price.toString() : ' ',
        value: hasPrice ? formattedAmounts(size.toDouble()) : ' ',
        isFlash: _flashColors.containsKey(key),
        disabled: hasPrice && price > maxPrice,
        color: _getButtonColor(
          hasPrice: hasPrice,
          isInBetSlip: isActiveButton,
          key: key,
          activeColor: pinkButtonClr,
          defaultColor: layBtn,
          opacity: getLayOpacity(index),
        ),
        active: isActiveButton,
        action: hasPrice && index == 0 && price <= maxPrice
            ? () {
                if (widget.favStakeData != null && widget.favStakeData!.singleClick) {
                  final qty = widget.favStakeData?.defaultStake ?? 0.0;
                  Map<String, dynamic> order = {
                    "bettingType": 0,
                    "marketId": widget.marketId,
                    "eventId": widget.eventId.toString(),
                    "runnerID": widget.runner.id.toString(),
                    "stake": qty,
                    "marketType": widget.marketType,
                    "marketName": widget.marketName,
                    "price": double.tryParse(price.toString()) ?? 0,
                    "line": "",
                    "side": "lay",
                    "runnerName": widget.runner.name,
                  };
                  context.read<SendOrderBloc>().add(
                        SendOrder(
                          orderMap: order,
                          type: OrderType.oddsMatch,
                          marketDelay: 5,
                        ),
                      );
                } else {
                  _handleSelection(false, key, price.toString(), size.toDouble());
                }
              }
            : null,
      );
    }).toList();
  }

  Widget _buildStatusOverlay({String? orderProgress}) {
    return MOStatus(
      status: orderProgress ?? (widget.runner.status.toUpperCase().contains('SUSPENDED') ? widget.runner.status.toUpperCase() : 'SUSPENDED'),
    );
  }

  List<ABCPrice> getThreePrices(List<ABCPrice> prices) {
    final result = List<ABCPrice>.from(prices);
    while (result.length < 3) {
      result.add(ABCPrice()..price = 0.0);
    }
    return result;
  }
}

class MmMatchOddsTile extends StatefulWidget {
  const MmMatchOddsTile({
    super.key,
    this.currentPL,
    required this.runnerId,
    required this.eventId,
    required this.marketId,
  });
  final double? currentPL;
  final String runnerId;
  final String eventId;
  final String marketId;

  @override
  State<MmMatchOddsTile> createState() => _MmMatchOddsTileState();
}

class _MmMatchOddsTileState extends State<MmMatchOddsTile> {
  final Map<String, dynamic> _plCache = {};

  @override
  void didUpdateWidget(covariant MmMatchOddsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runnerId != widget.runnerId || oldWidget.eventId != widget.eventId || oldWidget.marketId != widget.marketId) {
      _plCache.clear();
    }
  }

  dynamic _getPLData(dynamic apiData, OddsRunnerPLData? signalData) {
    final cacheKey = '${widget.runnerId}-${widget.eventId}-${widget.marketId}';
    if (signalData != null && signalData.runnerId == widget.runnerId) {
      return _plCache[cacheKey] = signalData;
    }
    if (apiData is OddsRunnerPLData && apiData.runnerId == widget.runnerId) {
      return _plCache[cacheKey] = apiData;
    }
    if (apiData is UserMMOddBMPlRunner && apiData.runnerId == widget.runnerId) {
      return _plCache[cacheKey] = apiData;
    }
    return _plCache[cacheKey];
  }

  @override
  Widget build(BuildContext context) {
    final currentEventId = widget.eventId;

    return BlocSelector<FetchUserMMPLOddBMBloc, FetchUserMMPLOddBMState, UserMMOddBMPlRunner?>(
      selector: (state) {
        if (state is FetchUserMMPLOddBMSuccess) {
          for (final market in state.runnerPl) {
            final runner = market.runners.firstWhereOrNull((e) => e.runnerId == widget.runnerId);
            if (runner != null) return runner;
          }
        }
        return null;
      },
      builder: (context, apiData) {
        return BlocSelector<OddsProfitLossBloc, OddsProfitLossState, OddsRunnerPLData?>(
          selector: (state) {
            if (currentEventId.isEmpty) return null;
            return state is OddsProfitLossSuccess ? state.oddsPl.firstWhereOrNull((e) => e.runnerId == widget.runnerId) : null;
          },
          builder: (context, signalData) {
            final plData = _getPLData(apiData, signalData);
            final isVisible = plData != null && plData.runnerId == widget.runnerId;

            return Row(
              children: [
                if (isVisible) _buildNetPL(plData),
                wb5,
                if (widget.currentPL != null && widget.currentPL != 0) _buildCurrentPL(plData),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNetPL(dynamic plData) {
    return HighlightText(
      plData.net > 0
          ? plData.net.toStringAsFixed(2)
          : plData.net < 0
              ? "(${plData.net.abs().toStringAsFixed(2)})"
              : "",
      style: TextStyle(
        fontSize: 12,
        color: plData.net > 0 ? green : red,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildCurrentPL(dynamic plData) {
    final oldPL = plData?.net ?? 0.0;
    final totalPL = oldPL + (widget.currentPL ?? 0);
    final color = totalPL < 0 ? red : green;

    return Row(
      children: [
        SvgPicture.asset(AppAssetConstants.arrowTo, height: 9, width: 9, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        wb5,
        HighlightText(
          totalPL.toStringAsFixed(2).replaceAll('-', ''),
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
