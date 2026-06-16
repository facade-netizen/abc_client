import 'package:flutter/material.dart';

import '../../../../../reusables/colors.dart';
import '../../../../../reusables/regexes.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/indicator.dart';
import '../../mainTabView/login_text_form_field.dart';
import '../matchOddsView/odds_bet_slip_order_card.dart';
import 'sports_bet_slip_order_card.dart';

class BetSection extends StatefulWidget {
  final bool isBack;
  final List<MapEntry<int, BetSlipItem>> bets;
  final double width;
  final void Function(int index)? onRemove;

  const BetSection({
    super.key,
    required this.isBack,
    required this.bets,
    required this.width,
    this.onRemove,
  });

  @override
  State<BetSection> createState() => _BetSectionState();
}

class _BetSectionState extends State<BetSection> {
  @override
  void initState() {
    super.initState();
    // Add listeners for all controllers
    _setupControllers();
  }

  void _setupControllers() {
    for (var entry in widget.bets) {
      entry.value.controller.removeListener(onControllerChange);
      entry.value.controller.addListener(onControllerChange);
    }
  }

  void onControllerChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant BetSection oldWidget) {
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

    // Filter bets according to Back / Lay
    final filteredBets = widget.bets.where((entry) => entry.value.isBack == widget.isBack).toList();

    // Group by event name
    final Map<String, List<MapEntry<int, BetSlipItem>>> groupedBets = {};
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
                final BetSlipItem bet = entry.value;
                final double stake = double.tryParse(bet.controller.text) ?? 0;
                /* do not remove this, these are profit and liability
                final double stake = double.tryParse(bet.controller.text) ?? 0;
                final double odds = double.tryParse(bet.price) ?? 0;
                final double value = (odds - 1) * stake; */

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
                                        controller: TextEditingController(text: bet.price),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontSize: 13, color: black),
                                        cursorColor: black,
                                        autofocus: true,
                                        inputFormatters: [greaterThanOrEqualToZeroWithDecimal],
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
                                        /*  suffix: Padding(
                                            padding: const EdgeInsets.all(1),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: white,
                                                border: Border.all(color: applyOpacity(grey, 0.4)),
                                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          bet.price = _incrementPrice(bet.price);
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.keyboard_arrow_up,
                                                        size: 14,
                                                        color: black,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          bet.price = _decrementPrice(bet.price);
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.keyboard_arrow_down,
                                                        size: 14,
                                                        color: black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),*/
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
                                Expanded(
                                  flex: 1,
                                  child: BetSlipTitle(title: stake.toStringAsFixed(2)),
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
                            // Force rebuild when quick button changes value
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
                            children: const [
                              BetSlipTitle(title: "Min Bet: 100"),
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

/*
double _getIncrementValue(double currentPrice) {
  double decimalPart = currentPrice - currentPrice.floor();
  // 2.10 → 0.10 step
  if ((decimalPart * 100) % 10 == 0) {
    return 0.10;
  }

  // 1.01 → 0.01 step
  return 0.01;
}

String _incrementPrice(String currentPriceStr) {
  double currentPrice = double.tryParse(currentPriceStr) ?? 0;
  double step = _getIncrementValue(currentPrice);
  return (currentPrice + step).toStringAsFixed(2);
}

String _decrementPrice(String currentPriceStr) {
  double currentPrice = double.tryParse(currentPriceStr) ?? 0;
  double step = _getIncrementValue(currentPrice);
  double newPrice = currentPrice - step;

  if (newPrice < 1.01) newPrice = 1.01;

  return newPrice.toStringAsFixed(2);
}*/
