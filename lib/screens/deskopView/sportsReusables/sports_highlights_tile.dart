import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../blocs/addBloc/send_order_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/me_signalr_data_streamer.dart';
import '../../../constants/app_string_constants.dart';
import '../../../models/event_with_type_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/indicator.dart';
import '../../../reusables/sized_box_hw.dart';
import '../newSportsView/new_sports_view_screen.dart';
import '../sportsView/betSlipOrder/sports_bet_slip_order_card.dart';
import 'custom_cta_button.dart';
import 'sports_highlights_header.dart';
import 'sports_tags.dart';

class SportsHighlightsTile extends StatefulWidget {
  const SportsHighlightsTile({
    super.key,
    this.event,
    this.action,
    this.sid,
    this.isSelected = false,
    required this.selectedBets,
    required this.onLayBackTap,
  });
  final String? sid;
  final Event? event;
  final bool isSelected;
  final void Function()? action;

  /// Pass the current selected bets
  final List<BetSlipItem> selectedBets;

  /// Callback to toggle lay/back selection
  final void Function({
    required Event event,
    required AbcRunner? runner,
    required String price,
    required bool isBack,
  }) onLayBackTap;

  @override
  State<SportsHighlightsTile> createState() => _SportsHighlightsTileState();
}

class _SportsHighlightsTileState extends State<SportsHighlightsTile> {
  bool isHovered = false;

  // Store last known backs/lays per runner
  Map<String, String> lastBacks = {};
  Map<String, String> lastLays = {};

  // Flash handling - only show flash when price actually changes
  final Map<String, double> previousPrices = {};
  final Map<String, Color> flashColors = {};

  void detectPriceChange(String key, double current) {
    // Don't flash during initial load or if price is 0
    if (current == 0) {
      previousPrices[key] = current;
      return;
    }

    // Only start detecting after widget
    if (previousPrices.containsKey(key)) {
      final prev = previousPrices[key]!;
      if (current != prev) {
        if (current > prev) {
          flashColors[key] = priceIncreased;
        } else if (current < prev) {
          flashColors[key] = priceDecreased;
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && flashColors.containsKey(key)) {
            setState(() => flashColors.remove(key));
          }
        });
      }
    }

    previousPrices[key] = current;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final showDraw = widget.sid == "1" || widget.sid == "4";
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? whiteOpac1
              : isHovered
                  ? highlightTileHover
                  : white,
          border: Border(bottom: BorderSide(color: whiteOpac1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: widget.action,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                LiveIndicatorForDesktop(isLive: widget.event?.inPlay ?? false),
                                wb5,
                                Expanded(
                                  child: HighlightText(
                                    widget.event?.name ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: highlightTileText,
                                      fontWeight: FontWeight.w600,
                                      decoration: isHovered ? TextDecoration.underline : TextDecoration.none,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            if (!horseAndGreyRacingEnabledForSid(widget.sid ?? "0"))
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  spacing: 4,
                                  children: widget.event == null
                                      ? []
                                      : buildEventTags(widget.event!).map((tag) {
                                          return TagSelector(
                                            label: tag,
                                            isLive: widget.event?.inPlay ?? false,
                                          );
                                        }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text("", style: const TextStyle(color: black, fontSize: 13)),
                      ),
                      VerticalDivider(color: whiteOpac1, width: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            horseAndGreyRacingEnabledForSid(widget.sid ?? "0")
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TimeForHorseAndGreyRacing(event: widget.event!, action: widget.action),
                      AddFevEvent(eventId: widget.event?.id ?? "0"),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// lays and backs CTA
                      BlocBuilder<MultiEventsSignalRDataBloc, MultiEventsSignalRDataState>(
                        builder: (context, mes) {
                          AbcRunner? runner1;
                          AbcRunner? runner2;
                          AbcRunner? runner3;
                          ABCModel? event;
                          if (mes is MultiEventsSignalRDataSuccess) {
                            event = mes.me.firstWhereOrNull((e) => e.eventId == widget.event?.id);
                            final runners = mes.me.firstWhereOrNull((e) => e.eventId == widget.event?.id)?.runner ?? [];

                            if (runners.isNotEmpty) runner1 = runners[0];
                            if (runners.length > 1) runner2 = runners[1];
                            if (runners.length > 2) runner3 = runners[2]; // DRAW runner
                          }

                          Widget buildCell(AbcRunner? runner, String keyPrefix, {bool isDraw = false}) {
                            // Back / Lay prices
                            double backPrice = (runner?.backs.isNotEmpty ?? false) ? runner!.backs.first.price : 0;
                            double layPrice = (runner?.lays.isNotEmpty ?? false) ? runner!.lays.first.price : 0;

                            detectPriceChange('$keyPrefix-BACK', backPrice);
                            detectPriceChange('$keyPrefix-LAY', layPrice);

                            // Check if selected
                            final backSelected = widget.selectedBets.any((b) => b.event.id == widget.event?.id && b.price == backPrice.toString() && b.isBack);
                            final laySelected = widget.selectedBets.any((b) => b.event.id == widget.event?.id && b.price == layPrice.toString() && !b.isBack);

                            final bool isSuspended =
                                runner != null && (runner.status.name.toLowerCase().contains('suspended') || runner.status.name.toLowerCase().contains('suspend'));

                            // Show status only if not draw OR prices exist
                            final showStatus = !isDraw || (backPrice > 0 || layPrice > 0);

                            // For DRAW, display "--" if price is 0, else display price
                            final displayBack = isDraw && backPrice == 0 ? "--" : (backPrice > 0 ? backPrice.toString() : "");
                            final displayLay = isDraw && layPrice == 0 ? "--" : (layPrice > 0 ? layPrice.toString() : "");
                            final backDisabled = backPrice > maxPrice;
                            final layDisabled = layPrice > maxPrice;

                            return BlocBuilder<SendOrderBloc, SendOrderState>(
                              builder: (context, state) {
                                return BlocBuilder<FetchOneClickDataBloc, FetchOneClickDataState>(
                                  builder: (context, fostate) {
                                    return Stack(
                                      children: [
                                        Row(
                                          children: [
                                            LayBackCTA(
                                                key: ValueKey('$keyPrefix-BACK'),
                                                price: displayBack,
                                                isBack: true,
                                                isSelected: backSelected,
                                                isFlash: flashColors.containsKey('$keyPrefix-BACK'),
                                                flashColor: flashColors['$keyPrefix-BACK'],
                                                disabled: backDisabled,
                                                action: backDisabled || backPrice <= 0
                                                    ? null
                                                    : () {
                                                        if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                                          final qty = fostate.oneClickData.defaultStake;
                                                          Map<String, dynamic> order = {
                                                            "bettingType": event?.bettingType.value,
                                                            "marketId": event?.marketId,
                                                            "eventId": widget.event?.id.toString(),
                                                            "runnerID": runner?.runnerId.toString() ?? "",
                                                            "stake": qty,
                                                            "marketType": event?.marketType,
                                                            "marketName": event?.marketName,
                                                            "price": double.tryParse(backPrice.toString()) ?? 0,
                                                            "line": "",
                                                            "side": "back",
                                                            "runnerName": runner?.name ?? "",
                                                          };
                                                          log("Order Inplay Back single  => $order");
                                                          context.read<SendOrderBloc>().add(
                                                                SendOrder(
                                                                  orderMap: order,
                                                                  type: OrderType.oddsMatch,
                                                                  marketDelay: event?.marketCondition.betDelay,
                                                                ),
                                                              );
                                                        } else {
                                                          widget.onLayBackTap(event: widget.event!, price: backPrice.toString(), isBack: true, runner: runner);
                                                        }
                                                      }),
                                            LayBackCTA(
                                                key: ValueKey('$keyPrefix-LAY'),
                                                price: displayLay,
                                                isBack: false,
                                                isSelected: laySelected,
                                                isFlash: flashColors.containsKey('$keyPrefix-LAY'),
                                                flashColor: flashColors['$keyPrefix-LAY'],
                                                disabled: layDisabled,
                                                action: layDisabled || layPrice <= 0
                                                    ? null
                                                    : () {
                                                        if (fostate is FetchOneClickDataSuccess && fostate.oneClickData.isClicked == true) {
                                                          final qty = fostate.oneClickData.defaultStake;
                                                          Map<String, dynamic> order = {
                                                            "bettingType": event?.bettingType.value,
                                                            "marketId": event?.marketId,
                                                            "eventId": widget.event?.id.toString(),
                                                            "runnerID": runner?.runnerId.toString() ?? "",
                                                            "stake": qty,
                                                            "marketType": event?.marketType,
                                                            "marketName": event?.marketName,
                                                            "price": double.tryParse(layPrice.toString()) ?? 0,
                                                            "line": "",
                                                            "side": "lay",
                                                            "runnerName": runner?.name ?? "",
                                                          };
                                                          log("Order Inplay Lay single  => $order");
                                                          context.read<SendOrderBloc>().add(
                                                                SendOrder(
                                                                  orderMap: order,
                                                                  type: OrderType.oddsMatch,
                                                                  marketDelay: event?.marketCondition.betDelay,
                                                                ),
                                                              );
                                                        } else {
                                                          widget.onLayBackTap(event: widget.event!, price: layPrice.toString(), isBack: false, runner: runner);
                                                        }
                                                      }),
                                          ],
                                        ),
                                        if (showStatus || (state is SendOrderProgress && state.eventId == widget.event?.id.toString()))
                                          Visibility(
                                            visible: isSuspended || (state is SendOrderProgress && state.eventId == widget.event?.id.toString()),
                                            child: EventStatus(
                                              status: state is SendOrderProgress ? "" : 'SUSPENDED',
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildCell(runner1, 'R1'), // 1st runner
                              const VerticalDivider(width: 10),
                              if (showDraw) buildCell(runner3, 'R3', isDraw: true), // DRAW runner
                              if (showDraw) const VerticalDivider(width: 10),
                              buildCell(runner2, 'R2'), // 2nd runner
                            ],
                          );
                        },
                      ),
                      AddFevEvent(eventId: widget.event?.id ?? "0"),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
