import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_odds_runners_pl_bloc.dart';
import '../../../../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../constants/app_string_constants.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/odd_data_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/formatters.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../services/navigators.dart';
import '../../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../mv_bet_slip.dart';
import 'mv_odds_place_dialog.dart';

class MVOddsRunnerCard extends StatefulWidget {
  const MVOddsRunnerCard({super.key, required this.runner, required this.oddsData, this.favStakeData});
  final FavStakeData? favStakeData;
  final ODDSRunner runner;
  final ODDSData oddsData;
  @override
  State<MVOddsRunnerCard> createState() => _OddsRunnerCardState();
}

class _OddsRunnerCardState extends State<MVOddsRunnerCard> {
  final TextEditingController betQtyController = TextEditingController();
  bool showBetSlip = false;
  bool isBack = false;
  double pl = 0.0;
  String? price;
  String? runnerId;
  String? runnerName;
  final Map<String, OddsRunnerPLData> plCache = {};

  String get _betSlipId => 'odds_${widget.oddsData.marketId}_${widget.runner.id}';

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
          if (activeBetSlipId.value == _betSlipId) {
            activeBetSlipId.value = null;
          }
        }
      },
      builder: (context, sos) {
        return Column(
          children: [
            // Main Card
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 210,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.runner.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17, color: Color(0xff1e1e1e), fontWeight: FontWeight.bold),
                          ),
                          BlocSelector<FetchOddsRunnerPLBloc, FetchOddsRunnerPLState, OddsRunnerPLData?>(
                            selector: (state) {
                              if (state is FetchOddsRunnerPLSuccess) {
                                return state.runnerPl.firstWhereOrNull((e) => e.runnerId == widget.runner.id);
                              }
                              return null;
                            },
                            builder: (context, runnerPLData) {
                              return BlocSelector<OddsProfitLossBloc, OddsProfitLossState, OddsRunnerPLData?>(
                                selector: (state) {
                                  if (state is OddsProfitLossSuccess) {
                                    return state.oddsPl.firstWhereOrNull((e) => e.runnerId == widget.runner.id);
                                  }
                                  return null;
                                },
                                builder: (context, profitLossData) {
                                  OddsRunnerPLData? plData;
                                  if (profitLossData != null && profitLossData.runnerId == widget.runner.id) {
                                    plCache[widget.runner.id] = profitLossData;
                                    plData = profitLossData;
                                  } else if (runnerPLData != null && runnerPLData.runnerId == widget.runner.id) {
                                    plCache[widget.runner.id] = runnerPLData;
                                    plData = runnerPLData;
                                  } else {
                                    plData = plCache[widget.runner.id];
                                  }
                                  final isVisible = (plData != null && plData.runnerId == widget.runner.id) || showBetSlip;
                                  return Row(
                                    children: [
                                      Visibility(
                                        visible: isVisible,
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
                                        visible: showBetSlip,
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
                                                  double currentValue;
                                                  if (isBack) {
                                                    currentValue = (odds - 1) * stake;
                                                  } else {
                                                    currentValue = -(odds - 1) * stake;
                                                  }
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
                                                    double currentValue;
                                                    if (isBack) {
                                                      currentValue = (odds - 1) * stake;
                                                    } else {
                                                      currentValue = -(odds - 1) * stake;
                                                    }
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
                  BlocBuilder<SignalRODDSDataBloc, SignalRODDSDataState>(
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
                      return Stack(
                        children: [
                          Row(
                            children: [
                              //Back
                              OddsPriceBox(
                                price: widget.runner.backs,
                                size: widget.runner.backSize,
                                isBack: true,
                                isDisable:
                                    widget.runner.status.toLowerCase().contains('loser') ||
                                    (double.tryParse(widget.runner.lays) ?? 0) > (widget.oddsData.sid == "4" ? maxPrice : soccerAndTennis) ||
                                    (double.tryParse(widget.runner.backs) ?? 0) > (widget.oddsData.sid == "4" ? maxPrice : soccerAndTennis),
                                onTap: widget.runner.backs.isNotEmpty && widget.runner.backSize != '0'
                                    ? () {
                                        setState(() {
                                          price = widget.runner.backs;
                                          runnerId = widget.runner.id;
                                          runnerName = widget.runner.name;
                                          showBetSlip = true;
                                          isBack = true;
                                          activeBetSlipId.value = _betSlipId;
                                          betQtyController.text = widget.favStakeData != null && widget.favStakeData!.defaultStake != 0
                                              ? widget.favStakeData!.defaultStake.toString()
                                              : "";
                                        });
                                      }
                                    : null,
                              ),
                              wb2,
                              // Lay
                              OddsPriceBox(
                                price: widget.runner.lays,
                                size: widget.runner.laySize,
                                isDisable:
                                    widget.runner.status.toLowerCase().contains('loser') ||
                                    (double.tryParse(widget.runner.lays) ?? 0) > (widget.oddsData.sid == "4" ? maxPrice : soccerAndTennis) ||
                                    (double.tryParse(widget.runner.backs) ?? 0) > (widget.oddsData.sid == "4" ? maxPrice : soccerAndTennis),
                                isBack: false,
                                onTap: widget.runner.lays.isNotEmpty && widget.runner.laySize != '0'
                                    ? () {
                                        setState(() {
                                          price = widget.runner.lays;
                                          runnerId = widget.runner.id;
                                          runnerName = widget.runner.name;
                                          showBetSlip = true;
                                          isBack = false;
                                          activeBetSlipId.value = _betSlipId;
                                          betQtyController.text = widget.favStakeData != null && widget.favStakeData!.defaultStake != 0
                                              ? widget.favStakeData!.defaultStake.toString()
                                              : "";
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          Visibility(
                            visible:
                                sos is SendOrderProgress ||
                                widget.runner.status.toString().toLowerCase().contains('suspend') ||
                                widget.runner.status.toString().toLowerCase().contains('suspended') ||
                                widget.runner.status.toLowerCase().contains('loser'),
                            child: Container(
                              color: black.withValues(alpha: 0.4),
                              height: 55,
                              width: 160,
                              child: Center(
                                child: Text(
                                  widget.runner.status.toString().toLowerCase().contains('suspend') || widget.runner.status.toString().toLowerCase().contains('suspended')
                                      ? "SUSPENDED"
                                      : sos is SendOrderProgress
                                      ? ""
                                      : widget.runner.status.toUpperCase().toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                      : BlocBuilder<SignalRODDSDataBloc, SignalRODDSDataState>(
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
                            return MVBetSlipCard(
                              isVisible: showBetSlip,
                              price: isBack ? widget.runner.backs : widget.runner.lays,
                              isBack: isBack,
                              favStakeData: widget.favStakeData,
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
                                if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                                  final betsQty = double.tryParse(betQtyController.text) ?? 0;
                                  if (betsQty > 0) {
                                    Map<String, dynamic> orderBaseModel = {
                                      "bettingType": 0,
                                      "marketId": widget.oddsData.marketId.toString(),
                                      "eventId": widget.oddsData.eventId.toString(),
                                      "runnerID": runnerId.toString(),
                                      "stake": betsQty,
                                      "marketType": widget.oddsData.marketType,
                                      "marketName": widget.oddsData.marketName,
                                      "price": isBack ? double.tryParse(widget.runner.backs) ?? 0.0 : double.tryParse(widget.runner.lays) ?? 0.0,
                                      "line": "",
                                      "side": isBack ? "back" : "lay",
                                      "runnerName": runnerName,
                                    };
                                    oddsBetPlaceDialog(context, orderBaseModel, pl.toStringAsFixed(2), marketDelay: widget.oddsData.marketCondition.betDelay);
                                  } else {
                                    showSnackBar(context, "Please enter a valid stake amount", error: true);
                                  }
                                } else {
                                  pushSimple(context, MVLogin());
                                }
                              },
                            );
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

class OddsPriceBox extends StatefulWidget {
  final String price;
  final String size;
  final bool isBack;
  final bool isDisable;
  final VoidCallback? onTap;

  const OddsPriceBox({super.key, required this.price, required this.size, required this.isBack, this.isDisable = false, this.onTap});

  @override
  State<OddsPriceBox> createState() => _OddsPriceBoxState();
}

class _OddsPriceBoxState extends State<OddsPriceBox> {
  late Color bgColor;

  @override
  void initState() {
    super.initState();
    bgColor = widget.isBack ? oddsBackBtn : oddsLayBtn;
    _flashYellow();
  }

  @override
  void didUpdateWidget(covariant OddsPriceBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.price != widget.price || oldWidget.isBack != widget.isBack) {
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
        bgColor = widget.isBack ? oddsBackBtn : oddsLayBtn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isDisable,
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          children: [
            /// Main Box
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 55,
              width: 80,
              decoration: BoxDecoration(color: bgColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.price,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e1e1e)),
                    ),
                    Text(
                      formattedMobileAmounts(double.tryParse(widget.size) ?? 0),
                      style: const TextStyle(fontSize: 14, color: Color(0xff1e1e1e), fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),

            /// Disable Overlay
            if (widget.isDisable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(color: black.withValues(alpha: 0.15)),
                  child: Image.asset(AppAssetConstants.bgDisabled, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
