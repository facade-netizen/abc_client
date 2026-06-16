import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/event_with_type_model.dart';
import '../../../../models/odd_data_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/regexes.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/style.dart';
import '../../authView/desktop_login_view.dart';
import '../../sportsReusables/custom_cta_button.dart';

class BetSlipOrderCard extends StatefulWidget {
  const BetSlipOrderCard({
    super.key,
    required this.oddsData,
    required this.event,
    required this.runner,
    this.selectedPrice,
    this.selectedSize,
    this.isBack = false,
    this.cancel,
    required this.width,
    required this.unit,
  });
  final double width;
  final ODDSData oddsData;
  final Event event;
  final ODDSRunner runner;
  final String? selectedPrice;
  final double? selectedSize;
  final bool isBack;
  final void Function()? cancel;
  final TextEditingController unit;
  @override
  State<BetSlipOrderCard> createState() => _BetSlipOrderCardState();
}

class _BetSlipOrderCardState extends State<BetSlipOrderCard> {
  bool acceptAnyOdds = true;

  @override
  Widget build(BuildContext context) {
    // Use isBackSelected to determine color instead of isBacks
    Color? color = widget.isBack ? backBtn : layBtn;

    return BlocConsumer<SendOrderBloc, SendOrderState>(
      listener: (context, sos) {
        if (sos is SendOrderSuccess) {
          widget.cancel!();
        }
      },
      builder: (context, sos) {
        return Container(
          color: white,
          child: sos is SendOrderProgress && sos.type == OrderType.oddsMatch
              ? LoaderContainerWithMessage()
              : Column(
                  children: [
                    Container(
                      color: applyOpacity(color, 0.3),
                      height: rh,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 2, child: BetSlipTitle(title: widget.isBack ? "Back (Bet For)" : "Lay (Bet Against)", right: false)),
                            Expanded(flex: 1, child: BetSlipTitle(title: "Odds")),
                            Expanded(flex: 1, child: BetSlipTitle(title: "Stake")),
                            Expanded(flex: 1, child: BetSlipTitle(title: widget.isBack ? "Profit" : "Liability")),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SizedBox(
                        height: rh,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.circle, color: widget.event.inPlay ? green : grey, size: 12),
                            wb5,
                            Expanded(child: BetSlipTitle(title: widget.event.name, right: false)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: applyOpacity(color, 0.5),
                      child: Column(
                        children: [
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
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child: BetSlipTitle(title: widget.runner.name, right: false, maxLines: 1)),
                                          wb5,
                                          BetSlipTitle(title: "Match Odds", color: grey, right: false, maxLines: 1),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: widget.selectedPrice ?? "0.00",
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(fontSize: 13, color: black),
                                              cursorColor: black,
                                              inputFormatters: [integers],
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: '0.00',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(4)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: TextField(
                                              controller: widget.unit,
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(fontSize: 13, color: black),
                                              cursorColor: black,
                                              inputFormatters: [integers],
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                                border: InputBorder.none,
                                                isDense: true,
                                                hintText: '0.00',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 1, child: BetSlipTitle(title: calculateProfitLiability())),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(color: color, height: 1),
                          // Quick Amount Buttons
                          BetSlipQuickButton(unit: widget.unit, width: widget.width),
                          Divider(color: color, height: 1),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              height: rh,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [BetSlipTitle(title: "Min Bet: 100")],
                              ),
                            ),
                          ),
                          Divider(color: color, height: 1),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: rh,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BetSlipTitle(title: "Liability"),
                            SizedBox(width: 10),
                            BetSlipTitle(title: calculateProfitLiability(), color: red),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CancelCTAButton(width: (widget.width) / 2 - 20, action: widget.cancel),
                        BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                          builder: (context, ucs) {
                            SaveLoginTokenModel? userLogedinSaveData;
                            if (ucs is UserAuthChangesSuccess) {
                              userLogedinSaveData = ucs.savedUserAuth;
                            }

                            return BlocBuilder<SignalRODDSDataBloc, SignalRODDSDataState>(
                              builder: (context, odr) {
                                ABCModel? oddsData;
                                if (odr is SignalRODDSDataSuccess) {
                                  oddsData = odr.oddsData;
                                }
                                if (oddsData != null) {
                                  final matchingRunner = oddsData.runner.firstWhereOrNull((r) => r.runnerId == widget.runner.id);
                                  if (matchingRunner != null) {
                                    final newBack = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.price.toString() : '';
                                    final newBackSize = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.size.toString() : '';
                                    final newLay = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.price.toString() : '';
                                    final newLaySize = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.size.toString() : '';
                                    final newStatus = matchingRunner.status.name;
                                    if (widget.runner.backs != newBack ||
                                        widget.runner.backSize != newBackSize ||
                                        widget.runner.lays != newLay ||
                                        widget.runner.laySize != newLaySize ||
                                        widget.runner.status != newStatus) {
                                      widget.runner.backs = newBack;
                                      widget.runner.backSize = newBackSize;
                                      widget.runner.lays = newLay;
                                      widget.runner.laySize = newLaySize;
                                      widget.runner.status = newStatus;
                                    }
                                  }
                                }
                                return CustomCTAButton(
                                  width: (widget.width) / 2 - 20,
                                  color: bgCktbet,
                                  title: "Place Bets",
                                  action: () {
                                    if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                      final betsQty = double.tryParse(widget.unit.text) ?? 0;
                                      if (betsQty > 0) {
                                        Map<String, dynamic> orderBaseModel = {
                                          "bettingType": 0,
                                          "marketId": widget.oddsData.marketId.toString(),
                                          "eventId": widget.oddsData.eventId.toString(),
                                          "runnerID": widget.runner.id.toString(),
                                          "stake": betsQty,
                                          "marketType": widget.oddsData.marketType,
                                          "marketName": widget.oddsData.marketName,
                                          "eventName": widget.event.name,
                                          "price": widget.isBack ? double.tryParse(widget.runner.backs) ?? 0.0 : double.tryParse(widget.runner.lays) ?? 0.0,
                                          "line": "",
                                          "side": widget.isBack ? "back" : "lay",
                                          "runnerName": widget.runner.name,
                                          "allRunnerIds": widget.oddsData.runners.map((r) => r.id).toList(),
                                        };
                                        context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.oddsMatch));
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
                    Divider(color: whiteOpac1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          checkColor: white,
                          activeColor: bgCktbet,
                          value: acceptAnyOdds,
                          onChanged: (value) {
                            setState(() => acceptAnyOdds = value ?? false);
                          },
                        ),
                        Text("Accept Any Odds", style: n12ts),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  String calculateProfitLiability() {
    if (widget.unit.text.isEmpty || widget.selectedPrice == null) return "0.00";

    try {
      final stake = double.tryParse(widget.unit.text) ?? 0.0;
      final price = double.tryParse(widget.selectedPrice!) ?? 0.0;

      if (widget.isBack) {
        // For Back: Profit = Stake × (Odds - 1)
        final profit = stake * (price - 1);
        return profit.toStringAsFixed(2);
      } else {
        // For Lay: Liability = Stake × (Odds - 1)
        final liability = stake * (price - 1);
        return liability.toStringAsFixed(2);
      }
    } catch (e) {
      return "0.00";
    }
  }
}

double? rh = 30;

class BetSlipTitle extends StatelessWidget {
  const BetSlipTitle({super.key, required this.title, this.color, this.right = true, this.maxLines = 1});
  final String title;
  final Color? color;
  final bool right;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: TextStyle(color: color ?? black, fontSize: 12, fontWeight: FontWeight.normal),
    );
  }
}

class BetSlipQuickButton extends StatefulWidget {
  const BetSlipQuickButton({super.key, required this.unit, required this.width, this.onChanged});

  final double width;
  final TextEditingController unit;
  final VoidCallback? onChanged;

  @override
  State<BetSlipQuickButton> createState() => _BetSlipQuickButtonState();
}

class _BetSlipQuickButtonState extends State<BetSlipQuickButton> {
  List<double> favStakesList = [];
  final double spacing = 5;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
      builder: (context, state) {
        // ✅ LOAD FROM API
        if (state is FetchFavStakeSuccess) {
          final favStakes = state.favStakeData.favStakes;

          if (favStakes.isNotEmpty) {
            favStakesList = favStakes.split(',').map((e) => double.tryParse(e.trim())).where((e) => e != null && e > 0).cast<double>().toList()..sort((a, b) => a.compareTo(b));
          }
        }
        // ✅ DEFAULT VALUES
        if (favStakesList.isEmpty) {
          favStakesList = [100, 300, 500, 1000, 1500, 2000];
        }

        final availableWidth = widget.width - spacing * 2 - spacing * (favStakesList.length - 1);

        final buttonWidth = availableWidth / favStakesList.length;

        return Padding(
          padding: EdgeInsets.all(spacing),
          child: Row(
            children: favStakesList.map((amount) {
              final amountStr = amount == amount.toInt() ? amount.toInt().toString() : amount.toString();

              return Padding(
                padding: EdgeInsets.only(right: amount != favStakesList.last ? spacing : 0),
                child: SizedBox(
                  width: buttonWidth,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        widget.unit.text = amountStr;
                      });

                      widget.onChanged?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: white,
                      side: BorderSide(color: greyShade),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                    ),
                    child: Text(amountStr, style: n12ts, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
