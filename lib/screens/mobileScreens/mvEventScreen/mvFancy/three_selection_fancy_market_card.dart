import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/fancy_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../services/navigators.dart';
import '../../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import 'fancy_book_bottom_sheet.dart';
import '../mv_bet_slip.dart';

class ThreeSelectionFancyMarketCard extends StatefulWidget {
  const ThreeSelectionFancyMarketCard({super.key, required this.fancyMarketData, this.favStakeData});
  final FavStakeData? favStakeData;
  final FancyMarketData fancyMarketData;

  @override
  State<ThreeSelectionFancyMarketCard> createState() => _ThreeSelectionFancyMarketCardState();
}

class _ThreeSelectionFancyMarketCardState extends State<ThreeSelectionFancyMarketCard> {
  final TextEditingController betQtyController = TextEditingController();
  bool showBetSlip = false;
  bool isBack = false;
  double pl = 0.0;
  String bLine = "";
  String bPrice = "";
  String lLine = "";
  String lPrice = "";

  final Map<String, FancyRunnerPLData> _plCache = {};
  String get _betSlipId => 'three_fancy_${widget.fancyMarketData.marketId}';
  String get runnerId => widget.fancyMarketData.runners.isNotEmpty ? widget.fancyMarketData.runners.first.id : '';
  String get backPrice =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs.first.price.toString() : '';

  String get layPrice =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays.first.price.toString() : '';

  String get backLine =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs.first.line : '';

  String get layLine =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays.first.line : '';
  //
  String get backPrice1 =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs[1].price.toString() : '';

  String get layPrice1 =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays[1].price.toString() : '';

  String get backLine1 =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs[1].line : '';

  String get layLine1 => widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays[1].line : '';

  bool get isMarketActiveOpen {
    final status = widget.fancyMarketData.status.toLowerCase().trim();
    return !widget.fancyMarketData.sportingEvent && (status.contains('active') || status == 'open' || status == 'online');
  }

  @override
  void initState() {
    super.initState();
    activeBetSlipId.addListener(_handleActiveBetSlipChange);
    betQtyController.addListener(() {
      setState(() {});
    });
  }

  void _handleActiveBetSlipChange() {
    if (!mounted) return;
    if (showBetSlip && activeBetSlipId.value != _betSlipId) {
      setState(() {
        showBetSlip = false;
        betQtyController.clear();
      });
    }
  }

  @override
  void dispose() {
    activeBetSlipId.removeListener(_handleActiveBetSlipChange);
    betQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendOrderBloc, SendOrderState>(
      listener: (context, sos) {
        if (sos is SendOrderSuccess) {
          showBetSlip = false;
          betQtyController.clear();
          if (activeBetSlipId.value == _betSlipId) {
            activeBetSlipId.value = null;
          }
        }
      },
      builder: (context, sos) {
        return Column(
          children: [
            // Runner header
            Container(
              width: double.infinity,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xffe4f1f9),
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.fancyMarketData.marketName,
                      style: const TextStyle(color: secondaryTextClr, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.info_outline),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          height: 35,
                          padding: EdgeInsets.all(2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Min / Max", style: TextStyle(color: Color(0xff577c94))),
                                  hb4,
                                  Text(
                                    "${widget.fancyMarketData.marketCondition != null ? widget.fancyMarketData.marketCondition!.minBet : "-"} / ${widget.fancyMarketData.marketCondition != null ? widget.fancyMarketData.marketCondition?.maxBet : "-"}",
                                  ),
                                ],
                              ),
                              Icon(Icons.close, size: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            BlocSelector<FetchFancyRunnerPLBloc, FetchFancyRunnerPLState, FancyRunnerPLData?>(
              selector: (state) {
                if (state is FetchFancyRunnerPLSuccess) {
                  return state.runnerPl.firstWhereOrNull((e) => e.runnerId == runnerId);
                }
                return null;
              },
              builder: (context, runnerPLData) {
                return BlocSelector<FancyProfitLossBloc, FancyProfitLossState, FancyRunnerPLData?>(
                  selector: (state) {
                    if (state is FancyProfitLossSuccess) {
                      final found = state.fancyPl.firstWhereOrNull((e) => e.runnerId == runnerId);
                      return found;
                    }
                    return null;
                  },
                  builder: (context, profitLossData) {
                    FancyRunnerPLData? plData;

                    if (profitLossData != null && profitLossData.runnerId == runnerId) {
                      _plCache[runnerId] = profitLossData;
                      plData = profitLossData;
                    } else if (runnerPLData != null && runnerPLData.runnerId == runnerId) {
                      _plCache[runnerId] = runnerPLData;
                      plData = runnerPLData;
                    } else {
                      plData = _plCache[runnerId];
                    }
                    final isShowBook = plData != null && plData.runnerId == runnerId;
                    return Container(
                      color: white,
                      height: 50,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 10,
                            top: 30,
                            child: Row(
                              children: [
                                Visibility(
                                  visible: showBetSlip || plData != null,
                                  child: Text(
                                    plData != null && plData.net != 0
                                        ? plData.net > 0
                                              ? plData.net.toStringAsFixed(2)
                                              : "(${plData.net.toStringAsFixed(2).replaceAll('-', '')})"
                                        : '',
                                    style: TextStyle(fontSize: 12, color: (plData != null && plData.net > 0) ? green : red, fontWeight: FontWeight.w400),
                                  ),
                                ),
                                wb5,
                                Visibility(
                                  visible: showBetSlip,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(AppAssetConstants.arrowTo, height: 9, width: 9, colorFilter: ColorFilter.mode(green, BlendMode.srcIn)),
                                      wb5,
                                      Text(
                                        (() {
                                          final stake = double.tryParse(betQtyController.text) ?? 0.0;
                                          if (stake > 0) {
                                            if (!isBack) {
                                              double priceVal = double.tryParse(layPrice) ?? 0.0;
                                              final exposure = (plData?.net ?? 0) - (priceVal * stake / 100);
                                              return "(${exposure.toStringAsFixed(2).replaceAll('-', "")})";
                                            } else {
                                              double priceVal = double.tryParse(backPrice) ?? 0.0;
                                              final exposure = (plData?.net ?? 0) + priceVal;
                                              return "(${exposure.toStringAsFixed(2).replaceAll('-', "")})";
                                            }
                                          }

                                          return '';
                                        })(),
                                        style: TextStyle(fontSize: 12, color: red, fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Book Button
                          Positioned(
                            right: 180,
                            bottom: 0,
                            top: 20,
                            child: Visibility(
                              visible: (showBetSlip || isShowBook) && plData != null && plData.net != 0,
                              child: InkWell(
                                onTap: () {
                                  context.read<FetchFancyBookBloc>().add(FetchFancyBook(marketId: widget.fancyMarketData.marketId));
                                  showFancyBookBottomSheet(context, widget.fancyMarketData.marketName);
                                },
                                child: Container(
                                  width: 60,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffcc51),
                                    border: Border.all(color: black),
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: const Center(
                                    child: Text("Book", style: TextStyle(color: black)),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Back / Lay Boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FancyRunnerBox(
                                key: ValueKey("lay_$layPrice$layLine"),
                                line: layLine,
                                price: layPrice,
                                isBack: false,
                                onTap: layPrice.isEmpty && layLine.isEmpty || !isMarketActiveOpen
                                    ? null
                                    : () {
                                        setState(() {
                                          isBack = false;
                                          lLine = layLine;
                                          lPrice = layPrice;
                                          showBetSlip = true;
                                          activeBetSlipId.value = _betSlipId;
                                          betQtyController.text = widget.favStakeData?.defaultStake.toString() ?? '';
                                        });
                                      },
                              ),
                              wb2,
                              FancyRunnerBox(
                                key: ValueKey("back_$backPrice$backLine"),
                                line: backLine,
                                price: backPrice,
                                isBack: true,
                                onTap: backPrice.isEmpty && backLine.isEmpty || !isMarketActiveOpen
                                    ? null
                                    : () {
                                        setState(() {
                                          isBack = true;
                                          bLine = backLine;
                                          bPrice = backPrice;
                                          showBetSlip = true;
                                          activeBetSlipId.value = _betSlipId;
                                          betQtyController.text = widget.favStakeData?.defaultStake.toString() ?? '';
                                        });
                                      },
                              ),
                            ],
                          ),
                          // Status overlay
                          _buildStatusOverlay(widget.fancyMarketData),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            Container(
              color: white,
              height: 50,
              child: Stack(
                children: [
                  // Back / Lay Boxes 2nd Runner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FancyRunnerBox(
                        key: ValueKey("lay_$layLine1$layPrice1"),
                        line: layLine1,
                        price: layPrice1,
                        isBack: false,
                        onTap: layPrice1.isEmpty && layLine1.isEmpty || !isMarketActiveOpen
                            ? null
                            : () {
                                setState(() {
                                  isBack = false;
                                  lPrice = layPrice1;
                                  lLine = layLine1;
                                  showBetSlip = true;
                                  activeBetSlipId.value = _betSlipId;
                                  betQtyController.text = widget.favStakeData?.defaultStake.toString() ?? '';
                                });
                              },
                      ),
                      wb2,
                      FancyRunnerBox(
                        key: ValueKey("back_$backPrice1$backLine1"),
                        line: backLine1,
                        price: backPrice1,
                        isBack: true,
                        onTap: backPrice1.isEmpty && backLine1.isEmpty || !isMarketActiveOpen
                            ? null
                            : () {
                                setState(() {
                                  isBack = true;
                                  bPrice = backPrice1;
                                  bLine = backLine1;
                                  showBetSlip = true;
                                  activeBetSlipId.value = _betSlipId;
                                  betQtyController.text = widget.favStakeData?.defaultStake.toString() ?? '';
                                });
                              },
                      ),
                    ],
                  ),

                  // Status overlay
                  _buildStatusOverlay(widget.fancyMarketData),
                ],
              ),
            ),

            // Bet slip
            BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
              builder: (context, ucs) {
                SaveLoginTokenModel? userLogedinSaveData;
                if (ucs is UserAuthChangesSuccess) {
                  userLogedinSaveData = ucs.savedUserAuth;
                }

                final shouldShowBetSlip = showBetSlip && isMarketActiveOpen;
                if (showBetSlip && !isMarketActiveOpen) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      showBetSlip = false;
                      betQtyController.clear();
                    });
                    if (activeBetSlipId.value == _betSlipId) {
                      activeBetSlipId.value = null;
                    }
                  });
                }
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const SizedBox.shrink(),
                  secondChild: sos is SendOrderProgress
                      ? LoaderContainerWithMessage()
                      : MVBetSlipCard(
                          isVisible: shouldShowBetSlip,
                          isBack: isBack,
                          price: isBack ? bPrice : lPrice,
                          betSize: isBack ? bLine : lLine,
                          betQtyController: betQtyController,
                          cancelOnTap: () {
                            setState(() {
                              showBetSlip = false;
                              betQtyController.clear();
                            });
                            if (activeBetSlipId.value == _betSlipId) {
                              activeBetSlipId.value = null;
                            }
                          },
                          betPlaceOnTap: () {
                            if (userLogedinSaveData?.userId != null) {
                              final betsQty = double.tryParse(betQtyController.text) ?? 0;
                              if (betsQty > 0) {
                                Map<String, dynamic> orderBaseModel = {
                                  "bettingType": 1,
                                  "marketId": widget.fancyMarketData.marketId.toString(),
                                  "eventId": widget.fancyMarketData.eventId.toString(),
                                  "runnerID": runnerId,
                                  "marketType": widget.fancyMarketData.marketType,
                                  "marketName": widget.fancyMarketData.marketName,
                                  "stake": betsQty,
                                  "price": isBack ? double.tryParse(bPrice) ?? 0.0 : double.tryParse(lPrice) ?? 0.0,
                                  "line": "$bLine,$lLine",
                                  "side": isBack ? "back" : "lay",
                                  "runnerName": widget.fancyMarketData.marketName,
                                };
                                context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.fancy));
                              } else {
                                showSnackBar(context, "Please enter a valid stake amount", error: true);
                              }
                            } else {
                              pushSimple(context, MVLogin());
                            }
                          },
                        ),
                  crossFadeState: showBetSlip ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusOverlay(FancyMarketData market) {
    final inactiveStatuses = {'SUSPENDED', 'SUSPEND', 'INACTIVE', 'CLOSED', 'VOID', 'OFFLINE', 'VOIDED', 'SETTLED', 'BALL_RUN', 'SETTLE_PROCESSING', 'VOID_PROCESSING'};
    final show = inactiveStatuses.contains(market.status) || market.sportingEvent == true || (backLine.isEmpty && layLine.isEmpty) || (backLine1.isEmpty && layLine1.isEmpty);
    if (!show) return const SizedBox.shrink();
    final text = market.sportingEvent == true || market.status == 'BALL_RUN'
        ? "Ball Running"
        : market.status == 'OFFLINE' ||
              market.status == 'SUSPENDED' ||
              market.status == 'SUSPEND' ||
              (backLine.isEmpty && layLine.isEmpty) ||
              (backLine1.isEmpty && layLine1.isEmpty)
        ? "Suspended"
        : "";
    return Positioned(
      right: 0,
      child: Container(
        color: black.withValues(alpha: 0.4),
        height: 50,
        width: 162,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class FancyRunnerBox extends StatefulWidget {
  final String price;
  final String line;
  final VoidCallback? onTap;
  final bool isBack;

  const FancyRunnerBox({super.key, required this.price, required this.line, this.onTap, required this.isBack});

  @override
  State<FancyRunnerBox> createState() => _FancyRunnerBoxState();
}

class _FancyRunnerBoxState extends State<FancyRunnerBox> {
  late Color bgColor;

  @override
  void initState() {
    super.initState();
    bgColor = widget.isBack ? backBtn : layBtn;
    _flashYellow();
  }

  @override
  void didUpdateWidget(covariant FancyRunnerBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.price != widget.price || oldWidget.line != widget.line || oldWidget.isBack != widget.isBack) {
      _flashYellow();
    }
  }

  void _flashYellow() {
    setState(() {
      bgColor = appYellow.withValues(alpha: 0.5);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        bgColor = widget.isBack ? backBtn : layBtn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: 80,
        decoration: BoxDecoration(color: bgColor),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.line,
                style: const TextStyle(fontSize: 17, color: Color(0xff1e1e1e), fontWeight: FontWeight.bold),
              ),
              Text(
                widget.price,
                style: const TextStyle(fontSize: 15, color: Color(0xff1e1e1e), fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
