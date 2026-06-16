import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loading_screen.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/style.dart';
import '../../authView/desktop_login_view.dart';
import '../../sportsReusables/custom_cta_button.dart';

class FancyPlaceBetCard extends StatefulWidget {
  const FancyPlaceBetCard({
    super.key,
    this.cancel,
    required this.unit,
    required this.price,
    required this.line,
    required this.runnerId,
    this.isYes,
    required this.fancyMarketData,
    required this.activeButtonKey,
  });

  final bool? isYes; // true for BACK, false for LAY
  final String price, line, runnerId;
  final void Function()? cancel;
  final TextEditingController unit;
  final FancyMarketData fancyMarketData;
  final String? activeButtonKey;

  @override
  State<FancyPlaceBetCard> createState() => _FancyPlaceBetCardState();
}

class _FancyPlaceBetCardState extends State<FancyPlaceBetCard> {
  bool acceptAnyOdds = true;

  FancyRunner? lastValidRunner;

  @override
  void initState() {
    super.initState();
    if (widget.fancyMarketData.runners.isNotEmpty) {
      lastValidRunner = widget.fancyMarketData.runners.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    // BACK button color (YES) = oddsBackBtn, LAY button color (NO) = pinkButtonClr
    Color color = widget.isYes == true ? oddsBackBtn : pinkButtonClr;

    return BlocBuilder<SendOrderBloc, SendOrderState>(
      builder: (context, sos) {
        return sos is SendOrderProgress && sos.type == OrderType.fancy
            ? const LinearProgress()
            : Column(
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(widget.line, style: const TextStyle(color: black, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(widget.price, style: const TextStyle(color: grey, fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

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

                                  return BlocBuilder<SignalRFancyDataBloc, SignalRFancyDataState>(
                                    builder: (context, frd) {
                                      FancyRunner? runner;

                                      if (frd is SignalRFancyDataSuccess) {
                                        final market = frd.fancy.values.where((m) => m.marketId == widget.fancyMarketData.marketId).toList();
                                        if (market.isNotEmpty && market.first.runners.isNotEmpty) {
                                          runner = market.first.runners.first;
                                          // Update persistent last valid runner
                                          lastValidRunner = runner;
                                        }
                                      }

                                      // Fallback to last valid
                                      runner ??= lastValidRunner;

                                      // Safety check
                                      if (runner == null) {
                                        return CustomCTAButton(color: bgCktbet, title: "Place Bets", action: null);
                                      }

                                      // Get both BACKS and LAYS lines based on which button is clicked
                                      String backsLine = '';
                                      String laysLine = '';

                                      if (widget.activeButtonKey == '1_lays1' || widget.activeButtonKey == '1_backs1') {
                                        // First row selections
                                        if (runner.backs.isNotEmpty) {
                                          backsLine = runner.backs.first.line.toString(); // BACKS1
                                        }
                                        if (runner.lays.isNotEmpty) {
                                          laysLine = runner.lays.first.line.toString(); // LAYS1
                                        }
                                      }

                                      if (widget.activeButtonKey == '2_backs2' || widget.activeButtonKey == '2_lays2') {
                                        // Second row selections
                                        if (runner.backs.length > 1) {
                                          backsLine = runner.backs[1].line.toString(); // BACKS2
                                        }
                                        if (runner.lays.length > 1) {
                                          laysLine = runner.lays[1].line.toString(); // LAYS2
                                        }
                                      }

                                      // Determine which price to use based on active button
                                      String selectedPrice = '';

                                      if (widget.activeButtonKey == '1_lays1') {
                                        // First row LAYS1 (NO)
                                        if (runner.lays.isNotEmpty) {
                                          selectedPrice = runner.lays.first.price.toString();
                                        }
                                      } else if (widget.activeButtonKey == '1_backs1') {
                                        // First row BACKS1 (YES)
                                        if (runner.backs.isNotEmpty) {
                                          selectedPrice = runner.backs.first.price.toString();
                                        }
                                      } else if (widget.activeButtonKey == '2_backs2') {
                                        // Second row BACKS2
                                        if (runner.backs.length > 1) {
                                          selectedPrice = runner.backs[1].price.toString();
                                        }
                                      } else if (widget.activeButtonKey == '2_lays2') {
                                        // Second row LAYS2
                                        if (runner.lays.length > 1) {
                                          selectedPrice = runner.lays[1].price.toString();
                                        }
                                      }

                                      final runnerId = runner.id;

                                      return CustomCTAButton(
                                        color: bgCktbet,
                                        title: "Place Bets",
                                        action: () {
                                          if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                            final betsQty = double.tryParse(widget.unit.text) ?? 0;
                                            if (betsQty > 0) {
                                              Map<String, dynamic> orderBaseModel = {
                                                "bettingType": 1,
                                                "marketId": widget.fancyMarketData.marketId.toString(),
                                                "eventId": widget.fancyMarketData.eventId.toString(),
                                                "runnerID": runnerId.toString(),
                                                "marketType": widget.fancyMarketData.marketType,
                                                "marketName": widget.fancyMarketData.marketName,
                                                "eventName": widget.fancyMarketData.eventName ?? '',
                                                "stake": betsQty,
                                                "price": double.tryParse(selectedPrice) ?? 0.0,
                                                "line": "$backsLine,$laysLine",
                                                "side": widget.isYes == true ? "back" : "lay",
                                                "runnerName": widget.fancyMarketData.marketName,
                                              };

                                              log(orderBaseModel.toString());
                                              context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.fancy));
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
              );
      },
    );
  }
}
