import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../services/navigators.dart';

Future<dynamic> oddsBetPlaceDialog(BuildContext context, Map<String, dynamic> oddBetsMap, String pl, {int? marketDelay}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext ctxt) {
      return MvOddsPlaceDialogBody(
        oddBetsMap: oddBetsMap,
        pl: pl,
        marketDelay: marketDelay,
      );
    },
  );
}

class MvOddsPlaceDialogBody extends StatefulWidget {
  const MvOddsPlaceDialogBody({super.key, required this.oddBetsMap, required this.pl, this.marketDelay});
  final Map<String, dynamic> oddBetsMap;
  final String pl;
  final int? marketDelay;
  @override
  State<MvOddsPlaceDialogBody> createState() => _MvOddsPlaceDialogBodyState();
}

class _MvOddsPlaceDialogBodyState extends State<MvOddsPlaceDialogBody> {
  @override
  Widget build(BuildContext context) {
    final value = widget.oddBetsMap;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      backgroundColor: white,
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 400,
        height: 200,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(gradient: bottomBarGradient),
              padding: EdgeInsets.only(top: 10, left: 5),
              child: Text(
                "Please Confirm Your Bet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appYellow),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(color: value["side"] == "back" ? oddsBackBtn : oddsLayBtn, borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        value["side"] == "back" ? "Back" : "Lay",
                        style: TextStyle(
                          color: black,
                        ),
                      ),
                    ),
                  ),
                  wb5,
                  Text(
                    value["runnerName"],
                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Odds",
                    style: TextStyle(color: black),
                  ),
                  Text(
                    "Stake",
                    style: TextStyle(color: black),
                  ),
                  Text(
                    "Profit",
                    style: TextStyle(color: black),
                  ),
                ],
              ),
            ),
            hb5,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value["price"].toStringAsFixed(2),
                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value["stake"].toStringAsFixed(2),
                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.pl,
                    style: TextStyle(color: black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            hb10,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        removeScreen(context);
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFFFFF), Color(0xFFEEEEEE)],
                            stops: [0.0, 0.89],
                          ),
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "Back",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.read<SendOrderBloc>().add(SendOrder(orderMap: widget.oddBetsMap, type: OrderType.oddsMatch, marketDelay: widget.marketDelay ?? 0));
                        removeScreen(context);
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(gradient: blackGrdntButton, borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(color: appBarText, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
