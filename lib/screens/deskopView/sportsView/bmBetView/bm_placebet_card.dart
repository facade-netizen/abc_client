import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/book_maker_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loading_screen.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/style.dart';
import '../../authView/desktop_login_view.dart';
import '../../sportsReusables/custom_cta_button.dart';

class BMPlaceBetCard extends StatefulWidget {
  const BMPlaceBetCard({super.key, this.cancel, required this.unit, required this.price, this.isBack, required this.bmData, required this.bmRunner});
  final bool? isBack;
  final String price;
  final BMData bmData;
  final BMRunner bmRunner;
  final void Function()? cancel;
  final TextEditingController unit;

  @override
  State<BMPlaceBetCard> createState() => _BMPlaceBetCardState();
}

class _BMPlaceBetCardState extends State<BMPlaceBetCard> {
  bool acceptAnyOdds = true;
  @override
  Widget build(BuildContext context) {
    Color color = widget.isBack == true ? oddsBackBtn : pinkButtonClr;
    return BlocBuilder<SendOrderBloc, SendOrderState>(
      builder: (context, sos) {
        return sos is SendOrderProgress && sos.type == OrderType.bookMaker
            ? LinearProgress()
            : Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: darkGreen, width: 0.5)),
                  color: white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 55,
                      color: applyOpacity(color, 0.3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  checkColor: black,
                                  activeColor: bgCktbet,
                                  value: acceptAnyOdds,
                                  onChanged: (value) {
                                    setState(() => acceptAnyOdds = value ?? false);
                                  },
                                ),
                                Text("Accept Any Odds", style: n12ts),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CancelCTAButton(
                                  width: 80,
                                  action: () {
                                    widget.cancel!();
                                    setState(() => widget.unit.clear());
                                  },
                                ),

                                // Odds Display
                                Container(
                                  height: 35,
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(color: applyOpacity(white, 0.5), borderRadius: BorderRadius.circular(4)),
                                  child: Center(
                                    child: Text(widget.price, style: TextStyle(color: black, fontSize: 13)),
                                  ),
                                ),
                                SizedBox(width: 8),

                                // Amount Input
                                Container(
                                  height: 35,
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
                                  child: TextField(
                                    controller: widget.unit,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.end,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(fontSize: 13, color: black),
                                    cursorColor: black,
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0), border: InputBorder.none, isDense: true),
                                  ),
                                ),

                                BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                                  builder: (context, ucs) {
                                    SaveLoginTokenModel? userLogedinSaveData;
                                    if (ucs is UserAuthChangesSuccess) {
                                      userLogedinSaveData = ucs.savedUserAuth;
                                    }

                                    return BlocBuilder<SignalRBMDataBloc, SignalRBMDataState>(
                                      builder: (context, bmr) {
                                        ABCModel? bmData;
                                        if (bmr is SignalRBMDataSuccess) {
                                          bmData = bmr.bm;
                                        }
                                        if (bmData != null) {
                                          final matchingRunner = bmData.runner.firstWhereOrNull((r) => r.runnerId == widget.bmRunner.id);
                                          if (matchingRunner != null) {
                                            final newBack = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.price.toString() : '';
                                            final newBackSize = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.size.toString() : '';
                                            final newLay = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.price.toString() : '';
                                            final newLaySize = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.size.toString() : '';
                                            final newStatus = matchingRunner.status.name;
                                            if (widget.bmRunner.backs != newBack ||
                                                widget.bmRunner.backSize != newBackSize ||
                                                widget.bmRunner.lays != newLay ||
                                                widget.bmRunner.laySize != newLaySize ||
                                                widget.bmRunner.status != newStatus) {
                                              widget.bmRunner.backs = newBack;
                                              widget.bmRunner.backSize = newBackSize;
                                              widget.bmRunner.lays = newLay;
                                              widget.bmRunner.laySize = newLaySize;
                                              widget.bmRunner.status = newStatus;
                                            }
                                          }
                                        }
                                        return CustomCTAButton(
                                          color: bgCktbet,
                                          title: "Place Bets",
                                          action: () {
                                            if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                              final betsQty = double.tryParse(widget.unit.text) ?? 0;
                                              if (betsQty > 0) {
                                                Map<String, dynamic> orderBaseModel = {
                                                  "bettingType": 2,
                                                  "marketId": widget.bmData.marketId.toString(),
                                                  "eventId": widget.bmData.eventId.toString(),
                                                  "runnerID": widget.bmRunner.id.toString(),
                                                  "marketType": widget.bmData.marketType,
                                                  "marketName": widget.bmData.marketName,
                                                  "eventName": widget.bmData.eventName,
                                                  "stake": betsQty,
                                                  "price": widget.isBack == true ? double.tryParse(widget.bmRunner.backs) ?? 0.0 : double.tryParse(widget.bmRunner.lays) ?? 0.0,
                                                  "line": "",
                                                  "side": widget.isBack == true ? "back" : "lay",
                                                  "runnerName": widget.bmRunner.name,
                                                  "allRunnerIds": widget.bmData.runners.map((r) => r.id).toList(),
                                                };
                                                context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.bookMaker));
                                              } else {
                                                showSnackBar(context, "Please enter a valid stake amount", error: true);
                                              }
                                            } else {
                                              desktopLoginView(context);
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: applyOpacity(color, 0.5), height: 1),
                    // Quick Amount Buttons
                    QuickUnitButton(color: color, unit: widget.unit),
                  ],
                ),
              );
      },
    );
  }
}
