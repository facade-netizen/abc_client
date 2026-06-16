import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/book_maker_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../services/navigators.dart';
import '../../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../mv_bet_slip.dart';

class BMRunnerCard extends StatefulWidget {
  const BMRunnerCard({super.key, required this.bmRunner, required this.bmData, this.favStakeData});
  final FavStakeData? favStakeData;
  final BMRunner bmRunner;
  final BMData bmData;

  @override
  State<BMRunnerCard> createState() => _BMRunnerCardState();
}

class _BMRunnerCardState extends State<BMRunnerCard> {
  final TextEditingController betQtyController = TextEditingController();
  bool showBetSlip = false;
  bool isBack = false;
  double pl = 0.0;
  String? price;
  String? runnerId;
  String? runnerName;

  final Map<String, BMRunnerPLData> _bmCache = {};

  double _calculateProjectedValue({required double odds, required double stake}) {
    return double.parse(((odds / 100) * stake).toStringAsFixed(2));
  }

  String get _betSlipId => 'bm_${widget.bmData.marketId}_${widget.bmRunner.id}';

  @override
  void initState() {
    super.initState();
    activeBetSlipId.addListener(_handleActiveBetSlipChange);
    betQtyController.addListener(() {
      if (showBetSlip) setState(() {});
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
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: grey),
                  top: BorderSide(color: grey),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bmRunner.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black),
                          ),
                          BlocSelector<FetchBMRunnerPLBloc, FetchBMRunnerPLState, BMRunnerPLData?>(
                            selector: (state) {
                              if (state is FetchBMRunnerPLSuccess) {
                                return state.runnerPl.firstWhereOrNull((e) => e.runnerId == widget.bmRunner.id);
                              }
                              return null;
                            },
                            builder: (context, runnerPLData) {
                              return BlocSelector<BmProfitLossBloc, BmProfitLossState, BMRunnerPLData?>(
                                selector: (state) {
                                  if (state is BmProfitLossSuccess) {
                                    return state.bmPl.firstWhereOrNull((e) => e.runnerId == widget.bmRunner.id);
                                  }
                                  return null;
                                },
                                builder: (context, profitLossData) {
                                  BMRunnerPLData? plData;

                                  if (profitLossData != null) {
                                    _bmCache[widget.bmRunner.id] = profitLossData;
                                    plData = profitLossData;
                                  } else if (runnerPLData != null) {
                                    _bmCache[widget.bmRunner.id] = runnerPLData;
                                    plData = runnerPLData;
                                  } else {
                                    plData = _bmCache[widget.bmRunner.id];
                                  }
                                  final isShowBook = plData != null && plData.runnerId == widget.bmRunner.id;
                                  return Row(
                                    children: [
                                      Visibility(
                                        visible: showBetSlip || isShowBook,
                                        child: Text(
                                          plData != null && plData.net > 0
                                              ? plData.net.toStringAsFixed(2)
                                              : plData != null && plData.net < 0
                                              ? "(${plData.net.toStringAsFixed(2).replaceAll('-', "")})"
                                              : "",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12, color: plData != null && plData.net > 0 ? green : red, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      wb5,
                                      Visibility(
                                        visible: showBetSlip || isShowBook,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(AppAssetConstants.arrowTo, height: 9, width: 9, colorFilter: ColorFilter.mode(green, BlendMode.srcIn)),
                                            wb5,
                                            Text(
                                              (() {
                                                final stake = double.tryParse(betQtyController.text) ?? 0.0;
                                                final odds = double.tryParse(price ?? '') ?? 0.0;
                                                if (stake > 0 && odds > 0) {
                                                  final oldValue = plData?.net ?? 0.0;
                                                  final projectedValue = _calculateProjectedValue(odds: odds, stake: stake);
                                                  final currentValue = isBack ? projectedValue : -projectedValue;
                                                  pl = currentValue;
                                                  final totalValue = oldValue + currentValue;
                                                  return totalValue.toStringAsFixed(2).replaceAll("-", "");
                                                }
                                                return '';
                                              })(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: (() {
                                                  final stake = double.tryParse(betQtyController.text) ?? 0.0;
                                                  final odds = double.tryParse(price ?? '') ?? 0.0;
                                                  if (stake > 0 && odds > 0) {
                                                    final oldValue = plData?.net ?? 0.0;
                                                    final projectedValue = _calculateProjectedValue(odds: odds, stake: stake);
                                                    final currentValue = isBack ? projectedValue : -projectedValue;
                                                    final totalValue = oldValue + currentValue;
                                                    return totalValue < 0 ? red : green;
                                                  }
                                                  return green;
                                                })(),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<SignalRBMDataBloc, SignalRBMDataState>(
                    builder: (context, bmr) {
                      ABCModel? bmData;
                      String status = "";
                      String statusMarket = "";

                      // ✅ Get latest runner & store last valid
                      if (bmr is SignalRBMDataSuccess) {
                        bmData = bmr.bm;
                      }
                      if (bmData != null) {
                        statusMarket = bmData.status.toString();
                        final matchingRunner = bmData.runner.firstWhereOrNull((r) => r.runnerId == widget.bmRunner.id);
                        if (matchingRunner != null) {
                          final newBack = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.price.toString() : '';
                          final newBackSize = matchingRunner.backs.isNotEmpty ? matchingRunner.backs.first.size.toString() : '';
                          final newLay = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.price.toString() : '';
                          final newLaySize = matchingRunner.lays.isNotEmpty ? matchingRunner.lays.first.size.toString() : '';
                          status = matchingRunner.status.name;
                          if (widget.bmRunner.backs != newBack ||
                              widget.bmRunner.backSize != newBackSize ||
                              widget.bmRunner.lays != newLay ||
                              widget.bmRunner.laySize != newLaySize ||
                              widget.bmRunner.status != status) {
                            widget.bmRunner.backs = newBack;
                            widget.bmRunner.backSize = newBackSize;
                            widget.bmRunner.lays = newLay;
                            widget.bmRunner.laySize = newLaySize;
                            widget.bmRunner.status = status;
                          }
                        }
                      }
                      return Stack(
                        children: [
                          Row(
                            children: [
                              BMRunnerButton(
                                text: status.toLowerCase().contains('suspend') || status.toLowerCase() == 'suspend' ? "" : widget.bmRunner.backs,
                                isBack: true,
                                onTap: () {
                                  setState(() {
                                    price = widget.bmRunner.backs;
                                    runnerId = widget.bmRunner.id;
                                    runnerName = widget.bmRunner.name;
                                    isBack = true;
                                    showBetSlip = true;
                                    activeBetSlipId.value = _betSlipId;
                                    betQtyController.text = widget.favStakeData != null && widget.favStakeData!.defaultStake != 0
                                        ? widget.favStakeData!.defaultStake.toString()
                                        : "";
                                  });
                                },
                              ),
                              wb2,
                              BMRunnerButton(
                                text: status.toLowerCase().contains('suspend') || status.toLowerCase() == 'suspend' ? "" : widget.bmRunner.lays,
                                isBack: false,
                                onTap: () {
                                  setState(() {
                                    price = widget.bmRunner.lays;
                                    runnerId = widget.bmRunner.id;
                                    runnerName = widget.bmRunner.name;
                                    showBetSlip = true;
                                    isBack = false;
                                    activeBetSlipId.value = _betSlipId;
                                    betQtyController.text = widget.favStakeData != null && widget.favStakeData!.defaultStake != 0
                                        ? widget.favStakeData!.defaultStake.toString()
                                        : "";
                                  });
                                },
                              ),
                            ],
                          ),
                          Visibility(
                            visible: statusMarket == "BALL_RUN" || (!status.toLowerCase().contains('active') && !status.toLowerCase().contains('online')),
                            child: Container(
                              color: black.withValues(alpha: 0.4),
                              height: 50,
                              width: 180,
                              child: Center(
                                child: Text(
                                  statusMarket == "BALL_RUN" && status.toLowerCase().contains('active') ? "Ball Running" : status,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
              builder: (context, ucs) {
                SaveLoginTokenModel? userLogedinSaveData;
                if (ucs is UserAuthChangesSuccess) {
                  userLogedinSaveData = ucs.savedUserAuth;
                }
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const SizedBox.shrink(),
                  secondChild: sos is SendOrderProgress
                      ? LoaderContainerWithMessage()
                      : MVBetSlipCard(
                          isVisible: showBetSlip,
                          price: isBack ? widget.bmRunner.backs : widget.bmRunner.lays,
                          isBack: isBack,
                          betQtyController: betQtyController,
                          favStakeData: widget.favStakeData,
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
                            if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                              final betsQty = double.tryParse(betQtyController.text) ?? 0;
                              if (betsQty > 0) {
                                Map<String, dynamic> orderBaseModel = {
                                  "bettingType": 2,
                                  "marketId": widget.bmData.marketId.toString(),
                                  "eventId": widget.bmData.eventId.toString(),
                                  "runnerID": runnerId.toString(),
                                  "marketType": widget.bmData.marketType,
                                  "marketName": widget.bmData.marketName,
                                  "eventName": widget.bmData.eventName,
                                  "stake": betsQty,
                                  "price": isBack ? double.tryParse(widget.bmRunner.backs) ?? 0.0 : double.tryParse(widget.bmRunner.lays) ?? 0.0,
                                  "line": "",
                                  "side": isBack ? "back" : "lay",
                                  "runnerName": runnerName,
                                  "allRunnerIds": widget.bmData.runners.map((r) => r.id).toList(),
                                };
                                context.read<SendOrderBloc>().add(SendOrder(orderMap: orderBaseModel, type: OrderType.bookMaker));
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
}

class BMRunnerButton extends StatefulWidget {
  final String text;
  final bool isBack;
  final void Function()? onTap;

  const BMRunnerButton({super.key, required this.text, required this.isBack, this.onTap});

  @override
  State<BMRunnerButton> createState() => _BMRunnerButtonState();
}

class _BMRunnerButtonState extends State<BMRunnerButton> {
  late Color innerColor;

  @override
  void initState() {
    super.initState();
    innerColor = widget.isBack ? backBtn : layBtn;
    _flashYellow();
  }

  @override
  void didUpdateWidget(covariant BMRunnerButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text || oldWidget.isBack != widget.isBack) {
      _flashYellow();
    }
  }

  void _flashYellow() {
    setState(() {
      innerColor = appYellow.withValues(alpha: 0.5);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        innerColor = widget.isBack ? backBtn : layBtn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          color: widget.isBack ? const Color.fromARGB(234, 169, 212, 243) : const Color.fromARGB(135, 249, 183, 198),
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: innerColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: grey),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
