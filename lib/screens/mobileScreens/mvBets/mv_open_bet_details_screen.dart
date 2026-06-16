import 'package:flutter/material.dart';

import '../../../models/open_order_model.dart';
import '../../../models/player_bet_history_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/custom_headers.dart';
import '../../../reusables/formatters.dart';
import '../../../reusables/sized_box_hw.dart';

class MVOpenBetDetailScreen extends StatefulWidget {
  const MVOpenBetDetailScreen({super.key, required this.toggleScreen, required this.openOrders, required this.openInEvent});
  final String openInEvent;
  final List<OpenOrder> openOrders;
  final Function(List<OpenOrder> item) toggleScreen;

  @override
  State<MVOpenBetDetailScreen> createState() => _MVOpenBetDetailScreenState();
}

class _MVOpenBetDetailScreenState extends State<MVOpenBetDetailScreen> {
  bool isShowInfo = false;
  bool isSort = false;
  List<OpenOrder> get _sortedOrders {
    final orders = [...widget.openOrders];
    if (isSort) {
      orders.sort((a, b) {
        final at = DateTime.tryParse(b.timeStamp) ?? DateTime(0);
        final bt = DateTime.tryParse(a.timeStamp) ?? DateTime(0);
        return at.compareTo(bt);
      });
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final orders = _sortedOrders;
    return Column(
      children: [
        // Header
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: grey),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  widget.toggleScreen(widget.openOrders);
                },
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(border: Border.all(color: grey)),
                  child: Center(child: Icon(Icons.arrow_left, color: white, size: 25)),
                ),
              ),
              wb10,
              Expanded(
                child: Center(
                  child: Text(
                    widget.openInEvent,
                    style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Matched header
        CustomHeadersBlueGredWithTitle(headerTitle: "Matched"),
        // Orders
        SizedBox(
          height: (size.height * 0.8) - 22,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final openOrder = orders[index];
              return Container(
                color: white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 180,
                            child: Text(openOrder.side.toLowerCase().contains('back') ? "Back" : "Lay", style: TextStyle(color: black)),
                          ),
                          Text("Odds", style: TextStyle(color: black)),
                          Text("Stack", style: TextStyle(color: black)),
                          Text("Profit", style: TextStyle(color: black)),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isShowInfo,
                      child: Container(
                        width: double.infinity,
                        color: openOrder.side.toLowerCase().contains('back') ? Colors.blue[50] : Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text("Ref: ${openOrder.orderId}   ${formattedDate(openOrder.timeStamp)}", style: TextStyle(fontSize: 12, color: bgColor)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      color: openOrder.side.toLowerCase().contains('back') ? Colors.blue[100] : Colors.red[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: openOrder.side.toLowerCase().contains('back') ? backBtn : layBtn, borderRadius: BorderRadius.circular(4)),
                                child: Center(
                                  child: Text(
                                    openOrder.bettingType == BettingType.line
                                        ? openOrder.side.toLowerCase().contains('back')
                                            ? "Yes"
                                            : "No"
                                        : openOrder.side.toLowerCase().contains('back')
                                            ? "Back"
                                            : "Lay",
                                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              wb8,
                              SizedBox(
                                width: 80,
                                child: Text(
                                  openOrder.bettingType == BettingType.line ? openOrder.marketName : openOrder.runnerName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: black),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              if (openOrder.bettingType == BettingType.line) Text(openOrder.line, style: TextStyle(color: black)),
                              hb5,
                              Text("${openOrder.price}", style: TextStyle(color: black)),
                            ],
                          ),
                          Text("${openOrder.stake}", style: TextStyle(color: black)),
                          Text("${openOrder.profit}", style: TextStyle(color: black)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom controls
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[200],
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isShowInfo = !isShowInfo;
                  });
                },
                child: Row(
                  children: [
                    Icon(isShowInfo ? Icons.check_circle : Icons.radio_button_unchecked, color: isShowInfo ? Colors.blue : Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    const Text("Bet Info", style: TextStyle(color: black)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () {
                  setState(() {
                    isSort = !isSort;
                  });
                },
                child: Row(
                  children: [
                    Icon(isSort ? Icons.check_circle : Icons.radio_button_unchecked, color: isSort ? Colors.blue : Colors.grey, size: 20),
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
