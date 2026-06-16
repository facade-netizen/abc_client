import 'package:flutter/material.dart';

import '../../../models/open_order_model.dart';
import '../../../models/player_bet_history_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../sportsView/matchOddsView/odds_bet_slip_order_card.dart';

class OpenBetsCardDetails extends StatefulWidget {
  const OpenBetsCardDetails({
    super.key,
    required this.openOrders,
    required this.openInEvent,
  });

  final String openInEvent;
  final List<OpenOrder> openOrders;

  @override
  State<OpenBetsCardDetails> createState() => _OpenBetsCardDetailsState();
}

class _OpenBetsCardDetailsState extends State<OpenBetsCardDetails> {
  bool isShowInfo = false;
  bool isSort = false;

  List<OpenOrder> _sortOrders(List<OpenOrder> orders) {
    final sorted = [...orders];
    sorted.sort((a, b) {
      final at = DateTime.tryParse(a.timeStamp) ?? DateTime(0);
      final bt = DateTime.tryParse(b.timeStamp) ?? DateTime(0);
      return isSort ? at.compareTo(bt) : bt.compareTo(at);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    // Filter and sort back orders
    final backOrders = _sortOrders(
      widget.openOrders.where((e) => e.side.toLowerCase().contains('back')).toList(),
    );

    // Filter and sort lay orders
    final layOrders = _sortOrders(
      widget.openOrders.where((e) => e.side.toLowerCase().contains('lay')).toList(),
    );

    return ListView(
      children: [
        if (backOrders.isNotEmpty)
          BetSection(
            isShowInfo: isShowInfo,
            title: "Back (Bet For)",
            color: backBtn,
            orders: backOrders,
            size: size,
            isBack: true,
          ),

        if (layOrders.isNotEmpty)
          BetSection(
            isShowInfo: isShowInfo,
            title: "Lay (Bet Against)",
            color: layBtn,
            orders: layOrders,
            size: size,
            isBack: false,
          ),

        // Bottom controls
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Row(
            children: [
              InkWell(
                onTap: () => setState(() => isShowInfo = !isShowInfo),
                child: Row(
                  children: [
                    Icon(
                      isShowInfo ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isShowInfo ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text("Bet Info", style: TextStyle(color: black)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => setState(() => isSort = !isSort),
                child: Row(
                  children: [
                    Icon(
                      isSort ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSort ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text("Time Order", style: TextStyle(color: black)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BetSection extends StatelessWidget {
  const BetSection({
    super.key,
    required this.title,
    required this.color,
    required this.orders,
    required this.size,
    required this.isBack,
    required this.isShowInfo,
  });

  final String title;
  final Color color;
  final List<OpenOrder> orders;
  final Size size;
  final bool isBack, isShowInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER (ONCE)
        Container(
          height: rh,
          color: white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(flex: 3, child: BetSlipTitle(title: title, right: false)),
              const Expanded(child: BetSlipTitle(title: "Odds")),
              const Expanded(child: BetSlipTitle(title: "Stake")),
              Expanded(child: BetSlipTitle(title: isBack ? "Profit" : "Liability")),
            ],
          ),
        ),

        /// ITEMS
        ...orders.map((bet) {
          return Column(
            children: [
              Visibility(
                visible: isShowInfo,
                child: Container(
                  width: size.width,
                  height: 20,
                  color: applyOpacity(color, 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ref: ${bet.orderId}   ${bet.timeStamp}",
                    style: TextStyle(fontSize: 10, color: bgColor),
                  ),
                ),
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: applyOpacity(color, 0.5),
                  border: Border(bottom: BorderSide(color: color)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isBack ? backType : layType,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isBack ? "Back" : "Lay",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          wb10,
                          Expanded(child: BetSlipTitle(title: bet.bettingType == BettingType.line ? bet.marketName : bet.runnerName, right: false)),
                        ],
                      ),
                    ),
                    Expanded(child: BetSlipTitle(title: bet.price.toString())),
                    Expanded(child: BetSlipTitle(title: bet.stake.toString())),
                    Expanded(child: BetSlipTitle(title: bet.profit.toString())),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
