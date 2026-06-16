import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../../localDb/token/login_token_model.dart';
import '../../../../../reusables/colors.dart';
import '../../../../../reusables/sized_box_hw.dart';
import '../../../../../reusables/snack_bar.dart';
import '../../../../../reusables/style.dart';
import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../../models/event_with_type_model.dart';
import '../../../../models/odd_data_model.dart';
import '../../../../reusables/loader.dart';
import '../../authView/desktop_login_view.dart';
import '../../sportsReusables/custom_cta_button.dart';
import 'sports_bet_slip_section_for_odds.dart';

class SportsBetSlipOrderCardForOdds extends StatefulWidget {
  final List<BetSlipItemForOdds> bets;
  final void Function()? onClearAll;
  final void Function(int index)? onRemove;
  final void Function()? onStakeOrPriceChanged;
  final double width;

  const SportsBetSlipOrderCardForOdds({super.key, this.onRemove, this.onClearAll, required this.bets, required this.width, this.onStakeOrPriceChanged});

  @override
  State<SportsBetSlipOrderCardForOdds> createState() => _SportsBetSlipOrderCardForOddsState();
}

class _SportsBetSlipOrderCardForOddsState extends State<SportsBetSlipOrderCardForOdds> {
  bool acceptAnyOdds = true;
  bool showLoader = false;
  Timer? _loaderTimer;
  List<MapEntry<int, BetSlipItemForOdds>> get backBets => widget.bets.asMap().entries.where((e) => e.value.isBack).toList();
  List<MapEntry<int, BetSlipItemForOdds>> get layBets => widget.bets.asMap().entries.where((e) => !e.value.isBack).toList();

  void startFixedLoader(int durationInSeconds) {
    _loaderTimer?.cancel();
    setState(() {
      showLoader = true;
    });
    _loaderTimer = Timer(Duration(seconds: durationInSeconds), () {
      if (!mounted) return;
      setState(() {
        widget.onClearAll?.call();
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
    if (showLoader) {
      return Container(color: white, child: const LoaderContainerWithMessage());
    }

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
          child: (showLoader || (sos is SendOrderProgress && sos.type == OrderType.multiOrder))
              ? const LoaderContainerWithMessage()
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          if (backBets.isNotEmpty)
                            BetSectionForOdds(isBack: true, bets: backBets, width: widget.width, onRemove: widget.onRemove, onStakeOrPriceChanged: widget.onStakeOrPriceChanged),
                          if (layBets.isNotEmpty)
                            BetSectionForOdds(isBack: false, bets: layBets, width: widget.width, onRemove: widget.onRemove, onStakeOrPriceChanged: widget.onStakeOrPriceChanged),
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

                            return BlocBuilder<SignalRODDSDataBloc, SignalRODDSDataState>(
                              builder: (context, mes) {
                                ABCModel? events;
                                if (mes is SignalRODDSDataSuccess) events = mes.oddsData;

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
                                      final event = events?.eventId == bet.event.id ? events : null;
                                      if (event == null) continue;
                                      final qty = double.tryParse(bet.controller.text) ?? 0;
                                      if (qty <= 0) {
                                        showSnackBar(context, "Please enter a valid stake amount for ${bet.runner?.name ?? ""}", error: true);
                                        hasInvalidBet = true;
                                        break;
                                      }
                                      final odds = double.tryParse(bet.price);
                                      if (odds == null || odds <= 0) {
                                        showSnackBar(context, "Please enter a valid odds for ${bet.runner?.name ?? ""}", error: true);
                                        hasInvalidBet = true;
                                        break;
                                      }
                                    }
                                    if (hasInvalidBet) return;

                                    // Place orders
                                    for (final bet in widget.bets) {
                                      final event = events?.eventId == bet.event.id ? events : null;
                                      if (event == null) continue;
                                      final qty = double.tryParse(bet.controller.text) ?? 0;
                                      final odds = double.tryParse(bet.price) ?? 0;

                                      Map<String, dynamic> order = {
                                        "bettingType": event.bettingType.value,
                                        "marketId": event.marketId,
                                        "eventId": bet.event.id.toString(),
                                        "runnerID": bet.runner?.id.toString() ?? "",
                                        "stake": qty,
                                        "marketType": event.marketType,
                                        "marketName": event.marketName,
                                        "price": odds,
                                        "line": "",
                                        "side": bet.isBack ? "back" : "lay",
                                        "eventName": bet.event.name,
                                        "runnerName": bet.runner?.name ?? "",
                                      };
                                      log("Order => $order");
                                      context.read<SendOrderBloc>().add(SendOrder(orderMap: order, type: OrderType.multiOrder, marketDelay: events?.marketCondition.betDelay ?? 0));
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

class BetSlipItemForOdds {
  final int minBet;
  final Event event;
  final ODDSRunner? runner;
  String price;
  final bool isBack;
  final TextEditingController controller;
  final TextEditingController priceController;
  final VoidCallback? onStakeOrPriceChanged;
  final VoidCallback? onPriceChanged;
  final VoidCallback? onBetRemoved;

  BetSlipItemForOdds({
    required this.price,
    required this.minBet,
    required this.runner,
    required this.isBack,
    required this.event,
    String? defaultStake,
    TextEditingController? controller,
    this.onStakeOrPriceChanged,
    this.onPriceChanged,
    this.onBetRemoved,
  }) : controller = controller ?? TextEditingController(text: defaultStake ?? "0"),
       priceController = TextEditingController(text: price) {
    this.controller.addListener(_onStakeChanged);
    priceController.addListener(_onPriceChanged);
  }

  void _onStakeChanged() {
    onStakeOrPriceChanged?.call();
  }

  void _onPriceChanged() {
    final newPrice = priceController.text;
    if (price != newPrice) {
      price = newPrice;
      onStakeOrPriceChanged?.call();
      onPriceChanged?.call();
    }
  }

  void updatePrice(String newPrice) {
    if (price != newPrice) {
      price = newPrice;
      if (priceController.text != newPrice) {
        priceController.text = newPrice;
      }
      onStakeOrPriceChanged?.call();
      onPriceChanged?.call();
    }
  }

  void dispose() {
    controller.removeListener(_onStakeChanged);
    controller.dispose();
    priceController.removeListener(_onPriceChanged);
    priceController.dispose();
  }
}
