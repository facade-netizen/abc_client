import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/mm_bm_signalr_data_streamer.dart';
import '../../../../models/favourite_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/style.dart';
import '../../sportsView/matchOddsView/match_odds_header.dart';
import 'mm_bm_header.dart';

class MmBmRunnerFeedCTA extends StatefulWidget {
  const MmBmRunnerFeedCTA({
    super.key,
    this.backAction,
    this.layAction,
    required this.runner,
    required this.backActive,
    required this.layActive,
    required this.eventId,
    required this.marketId,
  });

  final bool backActive;
  final bool layActive;
  final FavRunner runner;
  final String eventId;
  final String marketId;
  final void Function()? backAction;
  final void Function()? layAction;

  @override
  State<MmBmRunnerFeedCTA> createState() => _MmBmRunnerFeedCTAState();
}

class _MmBmRunnerFeedCTAState extends State<MmBmRunnerFeedCTA> {
  final Map<String, double> previousPrices = {};
  final Map<String, Color> flashColors = {};
  AbcRunner? lastValidRunner;

  /// Detect price changes for BACK or LAY
  void detectPriceChange(List<ABCPrice> prices, String side) {
    for (int i = 0; i < prices.length; i++) {
      final priceObj = prices[i];
      final key = '${widget.runner.id}-$side-$i';
      final currentPrice = priceObj.price.toDouble();

      if (previousPrices.containsKey(key)) {
        final prevPrice = previousPrices[key]!;
        if (currentPrice > prevPrice) {
          flashColors[key] = priceIncreased; // price increased
        } else if (currentPrice < prevPrice) {
          flashColors[key] = priceDecreased; // price decreased
        }
      }

      previousPrices[key] = currentPrice;
    }

    // Clear flash after 2-3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => flashColors.clear());
    });
  }

  /// Check if runner is suspended
  bool isSuspended(String status) {
    return status.toLowerCase() == 'suspended' || status.toLowerCase() == 'suspend';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignalRMMBMDataBloc, SignalRMMBMDataState>(
      builder: (context, bmr) {
        ABCModel? bmData;
        AbcRunner? currentRunner;
        String status = "";
        String statusMarket = "";

        // Get latest runner from stream
        if (bmr is SignalRMMBMDataSuccess) {
          bmData = bmr.bm;

          currentRunner = bmr.bm.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
          // Store valid runner data
          if (currentRunner != null) {
            lastValidRunner = currentRunner;
          }
        }
        if (bmData != null) {
          final matchingRunner = bmData.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
          final newStatus = matchingRunner?.status.name;
          status = newStatus ?? "";
          statusMarket = bmData.status.toString();
        }
        // Use current runner or last valid one
        final runnerToUse = currentRunner ?? lastValidRunner;

        // Get status from runner
        if (runnerToUse != null) {
          status = runnerToUse.status.name;
        }

        // Check if suspended
        final suspended = isSuspended(status);

        // Get prices from runner - if suspended, use empty prices
        List<ABCPrice> backs = [];
        List<ABCPrice> lays = [];

        if (!suspended) {
          backs = List<ABCPrice>.from(runnerToUse?.backs ?? []);
          lays = List<ABCPrice>.from(runnerToUse?.lays ?? []);
        }

        // Ensure we have 3 price slots (will show empty spaces if suspended)
        backs = getThreePrices(backs, isBack: true);
        lays = getThreePrices(lays, isBack: false);

        // Detect price changes only if we have data and not suspended
        if (runnerToUse != null && !suspended) {
          detectPriceChange(backs, 'BACK');
          detectPriceChange(lays, 'LAY');
        }

        return BlocBuilder<SendOrderBloc, SendOrderState>(
          builder: (context, oss) {
            return Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /// BACKS (last clickable)
                    Container(
                      height: bbh,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            applyOpacity(oddsBackBtn, 0.1),
                            applyOpacity(oddsBackBtn, 0.3),
                            applyOpacity(oddsBackBtn, 0.6),
                          ],
                        ),
                      ),
                      child: Row(
                        spacing: 4,
                        children: backs.asMap().entries.toList().reversed.map((entry) {
                          final index = entry.key;
                          final price = entry.value;
                          final key = '${widget.runner.id}-BACK-$index';
                          final hasPrice = !suspended && price.price > 0.0;

                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: MmBmBackLayCTA(
                                    key: ValueKey(key),
                                    active: widget.backActive,
                                    price: hasPrice ? price.price.toString() : ' ',
                                    action: hasPrice ? widget.backAction : null,
                                    color: flashColors[key],
                                    isFlash: flashColors.containsKey(key),
                                    isBack: true,
                                  ),
                                )
                              : Container(
                                  height: bbh,
                                  width: blw(context),
                                  alignment: Alignment.center,
                                  child: Text(
                                    hasPrice ? price.price.toString() : ' ',
                                    style: b13ts(),
                                  ),
                                );
                        }).toList(),
                      ),
                    ),

                    /// LAYS (first clickable)
                    Container(
                      height: bbh,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            applyOpacity(pinkButtonClr, 0.6),
                            applyOpacity(pinkButtonClr, 0.3),
                            applyOpacity(pinkButtonClr, 0.1),
                          ],
                        ),
                      ),
                      child: Row(
                        spacing: 4,
                        children: lays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final price = entry.value;
                          final key = '${widget.runner.id}-LAY-$index';
                          final hasPrice = !suspended && price.price > 0.0;

                          return index == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: MmBmBackLayCTA(
                                    key: ValueKey(key),
                                    active: widget.layActive,
                                    price: hasPrice ? price.price.toString() : ' ',
                                    action: hasPrice ? widget.layAction : null,
                                    color: flashColors[key],
                                    isFlash: flashColors.containsKey(key),
                                    isBack: false,
                                  ),
                                )
                              : Container(
                                  height: bbh,
                                  width: blw(context),
                                  alignment: Alignment.center,
                                  child: Text(
                                    hasPrice ? price.price.toString() : ' ',
                                    style: b13ts(),
                                  ),
                                );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: statusMarket == "BALL_RUN" ||
                      suspended ||
                      !status.toLowerCase().contains('active') ||
                      (oss is SendOrderProgress && oss.marketId == widget.marketId && oss.eventId == widget.eventId),
                  child: MmBMStatus(
                    status: (oss is SendOrderProgress && oss.marketId == widget.marketId && oss.eventId == widget.eventId)
                        ? ""
                        : suspended
                            ? "SUSPENDED"
                            : (statusMarket == "BALL_RUN" && status.toLowerCase().contains('active') ? "Ball Running" : status),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Helper to ensure we always have 3 price slots
  List<ABCPrice> getThreePrices(List<ABCPrice> prices, {required bool isBack}) {
    // Remove invalid prices
    List<ABCPrice> validPrices = prices.where((p) => p.price > 0).toList();

    // Sort properly
    validPrices.sort((a, b) => a.price.compareTo(b.price));

    // For BACK → highest should be clickable → reverse
    if (isBack) {
      validPrices = validPrices.reversed.toList();
    }

    final result = List<ABCPrice>.from(validPrices);

    if (result.isEmpty) {
      return List.generate(3, (_) => ABCPrice()..price = 0.0);
    }

    while (result.length < 3) {
      final last = result.last;

      double step = 1;

      double newPrice = isBack
          ? last.price - step // BACK ↓
          : last.price + step; // LAY ↑

      // rounding fix
      newPrice = double.parse(newPrice.toStringAsFixed(2));

      // safety check (avoid crazy values like 65 jump)
      if (newPrice <= 0 || newPrice > 1000) {
        result.add(ABCPrice()..price = 0.0);
      } else {
        result.add(ABCPrice()..price = newPrice);
      }
    }

    return result.take(3).toList();
  }
}
