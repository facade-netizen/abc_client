import 'package:flutter/material.dart';

import '../../../../../reusables/colors.dart';
import '../../../../../reusables/regexes.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/indicator.dart';
import '../../mainTabView/login_text_form_field.dart';
import '../../sportsView/matchOddsView/odds_bet_slip_order_card.dart';
import 'sports_bet_slip_order_card_for_mm_odds.dart';

class BetSectionForMmOdds extends StatefulWidget {
  final bool isBack;
  final List<MapEntry<int, BetSlipItemForMmOdds>> bets;
  final double width;
  final void Function(int index)? onRemove;
  final void Function()? onStakeOrPriceChanged;

  const BetSectionForMmOdds({
    super.key,
    required this.isBack,
    required this.bets,
    required this.width,
    this.onRemove,
    this.onStakeOrPriceChanged,
  });

  @override
  State<BetSectionForMmOdds> createState() => _BetSectionForMmOddsState();
}

class _BetSectionForMmOddsState extends State<BetSectionForMmOdds> {
  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    for (var entry in widget.bets) {
      entry.value.controller.removeListener(onControllerChange);
      entry.value.controller.addListener(onControllerChange);
    }
  }

  void onControllerChange() {
    // Trigger PL recalculation when stake changes
    widget.onStakeOrPriceChanged?.call();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant BetSectionForMmOdds oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bets != oldWidget.bets) {
      for (var entry in oldWidget.bets) {
        entry.value.controller.removeListener(onControllerChange);
      }
      _setupControllers();
    }
  }

  @override
  void dispose() {
    for (var entry in widget.bets) {
      entry.value.controller.removeListener(onControllerChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isBack ? backBtn : layBtn;

    final filteredBets = widget.bets.where((entry) => entry.value.isBack == widget.isBack).toList();

    final Map<String, List<MapEntry<int, BetSlipItemForMmOdds>>> groupedBets = {};
    for (var entry in filteredBets) {
      groupedBets.putIfAbsent(entry.value.event.name, () => []).add(entry);
    }

    return Column(
      children: [
        /// HEADER
        Container(
          height: 25,
          color: const Color(0xFFCED5DA),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(flex: 2, child: BetSlipTitle(title: widget.isBack ? "Back (Bet For)" : "Lay (Bet Against)", right: false)),
              Expanded(flex: 1, child: BetSlipTitle(title: "Odds")),
              Expanded(flex: 1, child: BetSlipTitle(title: "Stake")),
              Expanded(flex: 1, child: BetSlipTitle(title: widget.isBack ? "Profit" : "Liability")),
            ],
          ),
        ),

        ...groupedBets.entries.map((group) {
          final eventName = group.key;
          final eventBets = group.value;

          return Column(
            children: [
              /// EVENT HEADER
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: rh,
                  child: Row(
                    children: [
                      LiveIndicatorForDesktop(isLive: eventBets.first.value.event.inPlay),
                      wb5,
                      Expanded(child: BetSlipTitle(title: eventName, right: false)),
                    ],
                  ),
                ),
              ),

              /// BET ROWS
              ...eventBets.map((entry) {
                final int originalIndex = entry.key;
                final BetSlipItemForMmOdds bet = entry.value;
                final double stake = double.tryParse(bet.controller.text) ?? 0;
                final double odds = double.tryParse(bet.price) ?? 0;

                // Calculate profit/liability based on C# logic
                final double value;
                if (bet.isBack) {
                  // BACK: Profit = (odds - 1) * stake
                  value = (odds - 1) * stake;
                } else {
                  // LAY: Liability = (odds - 1) * stake
                  value = (odds - 1) * stake;
                }

                return Container(
                  color: applyOpacity(color, 0.5),
                  child: Column(
                    children: [
                      /// BET BODY
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Row(
                              spacing: 8,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => widget.onRemove?.call(originalIndex),
                                        child: const Icon(Icons.close, size: 18, color: red),
                                      ),
                                      wb5,
                                      Expanded(
                                        child: BetSlipTitle(
                                          title: bet.runner?.name ?? '-',
                                          right: false,
                                          maxLines: 1,
                                        ),
                                      ),
                                      wb5,
                                      BetSlipTitle(
                                        title: "Match Odds",
                                        color: grey,
                                        right: false,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.all(Radius.circular(4))),
                                      padding: EdgeInsetsDirectional.all(2),
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: bet.priceController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontSize: 13, color: black),
                                        cursorColor: black,
                                        autofocus: true,
                                        inputFormatters: [greaterThanOrEqualToZeroWithDecimal],
                                        onChanged: (value) {
                                          // Update bet price and trigger recalculation
                                          bet.updatePrice(value);
                                          widget.onStakeOrPriceChanged?.call();
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          isDense: false,
                                          hintText: '0.00',
                                          hintStyle: const TextStyle(fontSize: 12, color: black),
                                          fillColor: white,
                                          errorBorder: border(color: red),
                                          focusedBorder: border(),
                                          disabledBorder: border(color: none),
                                          enabledBorder: border(color: transparent),
                                          border: border(color: grey),
                                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.all(Radius.circular(4))),
                                      padding: EdgeInsetsDirectional.all(2),
                                      child: TextField(
                                        controller: bet.controller,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontSize: 13, color: black),
                                        cursorColor: black,
                                        inputFormatters: [integers],
                                        onChanged: (_) {
                                          widget.onStakeOrPriceChanged?.call();
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          isDense: false,
                                          hintStyle: const TextStyle(fontSize: 12, color: black),
                                          fillColor: white,
                                          errorBorder: border(color: red),
                                          focusedBorder: border(),
                                          disabledBorder: border(color: none),
                                          enabledBorder: border(color: transparent),
                                          border: border(color: grey),
                                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: BetSlipTitle(
                                    title: value.toStringAsFixed(2),
                                    color: black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: color))),
                        child: BetSlipQuickButton(
                          unit: bet.controller,
                          width: widget.width,
                          onChanged: () {
                            widget.onStakeOrPriceChanged?.call();
                            setState(() {});
                          },
                        ),
                      ),
                      Container(
                        height: 25,
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color))),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BetSlipTitle(title: "Min Bet: ${bet.minBet}"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}
