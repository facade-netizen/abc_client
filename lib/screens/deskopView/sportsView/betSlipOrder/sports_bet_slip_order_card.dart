import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../../localDb/token/login_token_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../../reusables/snack_bar.dart';
import '../../../../../reusables/style.dart';
import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/me_signalr_data_streamer.dart';
import '../../../../models/event_with_type_model.dart';
import '../../../../reusables/loader.dart';
import '../../authView/desktop_login_view.dart';
import '../../sportsReusables/custom_cta_button.dart';
import 'sports_bet_slip_section.dart';

class SportsBetSlipOrderCard extends StatefulWidget {
  final List<BetSlipItem> bets;
  final void Function()? onClearAll;
  final void Function(int index)? onRemove;
  final double width;

  const SportsBetSlipOrderCard({super.key, required this.bets, this.onRemove, this.onClearAll, required this.width});

  @override
  State<SportsBetSlipOrderCard> createState() => _SportsBetSlipOrderCardState();
}

class _SportsBetSlipOrderCardState extends State<SportsBetSlipOrderCard> {
  bool acceptAnyOdds = true;
  bool showLoader = false;
  Timer? _loaderTimer;

  List<MapEntry<int, BetSlipItem>> get backBets => widget.bets.asMap().entries.where((e) => e.value.isBack).toList();
  List<MapEntry<int, BetSlipItem>> get layBets => widget.bets.asMap().entries.where((e) => !e.value.isBack).toList();

  void startFixedLoader(int durationInSeconds) {
    _loaderTimer?.cancel();
    setState(() {
      showLoader = true;
    });
    _loaderTimer = Timer(Duration(seconds: durationInSeconds), () {
      if (!mounted) return;
      setState(() {
        showLoader = false;
      });
    });
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bets.isEmpty) {
      return Container(
        color: white,
        child: const Center(
          child: Text("Click on the odds to add selections to the betslip.", style: TextStyle(fontSize: 13, color: black)),
        ),
      );
    }

    return BlocConsumer<SendOrderBloc, SendOrderState>(
      listener: (context, sos) {
        if (sos is SendOrderProgress && sos.type == OrderType.multiOrder) {
          startFixedLoader(sos.marketDelay ?? 1);
        }
        if (sos is SendOrderSuccess) {
          widget.onClearAll?.call();
        }
      },
      builder: (context, sos) {
        return Container(
          color: white,
          child: (showLoader && (sos is SendOrderProgress && sos.type == OrderType.multiOrder))
              ? const LoaderContainerWithMessage()
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          if (backBets.isNotEmpty) BetSection(isBack: true, bets: backBets, width: widget.width, onRemove: widget.onRemove),
                          if (layBets.isNotEmpty) BetSection(isBack: false, bets: layBets, width: widget.width, onRemove: widget.onRemove),
                        ],
                      ),
                    ),

                    /// ACTION BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CancelCTAButton(title: 'Cancel All', width: widget.width / 2 - 20, action: widget.onClearAll),
                        BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                          builder: (context, ucs) {
                            SaveLoginTokenModel? user;
                            if (ucs is UserAuthChangesSuccess) {
                              user = ucs.savedUserAuth;
                            }

                            return BlocBuilder<MultiEventsSignalRDataBloc, MultiEventsSignalRDataState>(
                              builder: (context, mes) {
                                List<ABCModel> events = [];
                                if (mes is MultiEventsSignalRDataSuccess) events = mes.me;

                                return CustomCTAButton(
                                  width: widget.width / 2 - 20,
                                  title: "Place Bets",
                                  color: bgCktbet,
                                  action: () {
                                    if (user == null) {
                                      desktopLoginView(context);
                                      return;
                                    }

                                    bool hasInvalidBet = false;

                                    for (final bet in widget.bets) {
                                      final event = events.firstWhereOrNull((e) => e.eventId == bet.event.id);
                                      if (event == null) continue;
                                      final qty = double.tryParse(bet.controller.text) ?? 0;
                                      if (qty < 0) {
                                        showSnackBar(context, "Please enter a valid stake amount for ${bet.runner?.name ?? ""}", error: true);
                                        hasInvalidBet = true;
                                        break;
                                      }
                                    }
                                    if (hasInvalidBet) return;

                                    // Place orders
                                    for (final bet in widget.bets) {
                                      final event = events.firstWhereOrNull((e) => e.eventId == bet.event.id);
                                      if (event == null) continue;
                                      final qty = double.tryParse(bet.controller.text) ?? 0;
                                      Map<String, dynamic> order = {
                                        "bettingType": event.bettingType.value,
                                        "marketId": event.marketId,
                                        "eventId": bet.event.id.toString(),
                                        "runnerID": bet.runner?.runnerId.toString() ?? "",
                                        "stake": qty,
                                        "marketType": event.marketType,
                                        "marketName": event.marketName,
                                        "price": double.tryParse(bet.price) ?? 0,
                                        "line": "",
                                        "side": bet.isBack ? "back" : "lay",
                                        "eventName": bet.event.name,
                                        "runnerName": bet.runner?.name ?? "",
                                      };
                                      log("Order => $order");
                                      context.read<SendOrderBloc>().add(SendOrder(orderMap: order, type: OrderType.multiOrder, marketDelay: event.marketCondition.betDelay));
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

                    /// ACCEPT ODDS
                    Row(
                      children: [
                        Checkbox(value: acceptAnyOdds, activeColor: bgCktbet, onChanged: (v) => setState(() => acceptAnyOdds = v ?? false)),
                        Text("Accept Any Odds", style: n12ts),
                      ],
                    ),
                    hb40,
                  ],
                ),
        );
      },
    );
  }
}

class BetSlipItem {
  final Event event;
  final AbcRunner? runner;
  String price;
  final bool isBack;
  TextEditingController controller;

  BetSlipItem({
    required this.price,
    required this.runner,
    required this.isBack,
    required this.event,
    String? defaultStake, // ✅ ADD THIS
    TextEditingController? controller,
  }) : controller =
           controller ??
           TextEditingController(
             text: defaultStake ?? "0", // ✅ SET DEFAULT STAKE HERE
           );
}
