import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../blocs/addBloc/send_order_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_user_mm_fancy_pl_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/mm_fancy_model.dart';
import '../../../../models/runners_pl_model.dart';
import '../../../../models/user_mm_pl_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../services/navigators.dart';
import '../../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../../mvEventScreen/mvFancy/fancy_book_bottom_sheet.dart';
import '../../mvEventScreen/mv_bet_slip.dart';

class MMMvFancyMarketCard extends StatefulWidget {
  const MMMvFancyMarketCard({super.key, required this.fancyMarketData, this.favStakeData});

  final FavStakeData? favStakeData;
  final MMFancyMarketData fancyMarketData;

  @override
  State<MMMvFancyMarketCard> createState() => _MMMvFancyMarketCardState();
}

class _MMMvFancyMarketCardState extends State<MMMvFancyMarketCard> {
  final TextEditingController betQtyController = TextEditingController();
  bool showBetSlip = false;
  bool isBack = false;

  String get marketId => widget.fancyMarketData.marketId;
  String get runnerId => widget.fancyMarketData.runners.isNotEmpty ? widget.fancyMarketData.runners.first.id : '';

  bool get isMarketActiveOpen {
    final status = widget.fancyMarketData.status.toLowerCase().trim();
    return !widget.fancyMarketData.sportingEvent && (status.contains('active') || status == 'open' || status == 'online');
  }

  final Map<String, dynamic> _plCache = {};

  String get _betSlipId => 'fancy_${widget.fancyMarketData.marketId}';

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

  String get backPrice =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs.first.price.toString() : '';

  String get layPrice =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays.first.price.toString() : '';

  String get backLine =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty ? widget.fancyMarketData.runners.first.backs.first.line : '';

  String get layLine =>
      widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty ? widget.fancyMarketData.runners.first.lays.first.line : '';

  void _placeBet(SaveLoginTokenModel? user) {
    final stake = double.tryParse(betQtyController.text) ?? 0.0;
    if (user?.userId == null) {
      pushSimple(context, MVLogin());
      return;
    }
    if (stake <= 0) {
      showSnackBar(context, "Please enter a valid stake amount", error: true);
      return;
    }
    Map<String, dynamic> order = {
      "bettingType": 1,
      "marketId": marketId,
      "eventId": widget.fancyMarketData.eventId,
      "runnerID": widget.fancyMarketData.runners.first.id,
      "marketType": widget.fancyMarketData.marketType,
      "marketName": widget.fancyMarketData.marketName,
      "stake": stake,
      "price": isBack ? double.tryParse(backPrice) ?? 0.0 : double.tryParse(layPrice) ?? 0.0,
      "line": "$backLine,$layLine",
      "side": isBack ? "back" : "lay",
      "runnerName": widget.fancyMarketData.marketName,
    };
    context.read<SendOrderBloc>().add(SendOrder(orderMap: order, type: OrderType.fancy));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendOrderBloc, SendOrderState>(
      listener: (_, state) {
        if (state is SendOrderSuccess) {
          setState(() {
            showBetSlip = false;
            betQtyController.clear();
          });
          if (activeBetSlipId.value == _betSlipId) {
            activeBetSlipId.value = null;
          }
        }
      },
      builder: (context, sos) {
        return Column(
          children: [
            _buildRunnerHeader(),
            BlocSelector<FetchUserMMFancyPLBloc, FetchUserMMFancyPLState, UserMMPLFancyRunner?>(
              selector: (state) {
                if (state is FetchUserMMFancyPLSuccess) {
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
                    dynamic plData;
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
                            top: 10,
                            child: Row(
                              children: [
                                Visibility(
                                  visible: showBetSlip || isShowBook,
                                  child: Text(
                                    isShowBook && plData.net != 0
                                        ? plData.net > 0
                                              ? plData.net.toStringAsFixed(2)
                                              : "(${plData.net.abs().toStringAsFixed(2)})"
                                        : '',
                                    key: ValueKey('${showBetSlip}_${isShowBook}_${betQtyController.text}_${plData?.net ?? 0}'),
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
                                              bool isCheckRunner = widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.lays.isNotEmpty;
                                              final value = isCheckRunner ? widget.fancyMarketData.runners.first.lays.first.price.toString() : '';
                                              double priceVal = double.tryParse(value) ?? 0.0;
                                              final exposure = (plData?.net ?? 0) - (priceVal * stake / 100);
                                              return "(${exposure.toStringAsFixed(2).replaceAll('-', "")})";
                                            } else {
                                              bool isCheckRunner = widget.fancyMarketData.runners.isNotEmpty && widget.fancyMarketData.runners.first.backs.isNotEmpty;
                                              final value = isCheckRunner ? widget.fancyMarketData.runners.first.backs.first.price.toString() : '';
                                              double priceVal = double.tryParse(value) ?? 0.0;
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
                            bottom: 10,
                            top: 10,
                            child: Visibility(
                              visible: (showBetSlip || isShowBook) && plData != null && plData.net != 0,
                              child: InkWell(
                                onTap: () {
                                  context.read<FetchFancyBookBloc>().add(FetchFancyBook(marketId: marketId));
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [_buildFancyRunnerBox(isBack: false), wb2, _buildFancyRunnerBox(isBack: true)],
                          ),
                          _buildStatusOverlay(widget.fancyMarketData),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            _buildBetSlip(sos),
          ],
        );
      },
    );
  }

  Widget _buildFancyRunnerBox({required bool isBack}) {
    final price = isBack ? backPrice : layPrice;
    final line = isBack ? backLine : layLine;
    return FancyRunnerBox(
      key: ValueKey("${isBack ? 'back' : 'lay'}_$marketId"),
      isBack: isBack,
      price: price,
      line: line,
      onTap: isMarketActiveOpen
          ? () {
              setState(() {
                this.isBack = isBack;
                showBetSlip = true;
                activeBetSlipId.value = _betSlipId;
                betQtyController.text = widget.favStakeData?.defaultStake.toString() ?? '';
              });
            }
          : null,
    );
  }

  Widget _buildStatusOverlay(MMFancyMarketData market) {
    final inactiveStatuses = {'SUSPENDED', 'SUSPEND', 'INACTIVE', 'CLOSED', 'VOID', 'OFFLINE', 'VOIDED', 'SETTLED', 'BALL_RUN', 'SETTLE_PROCESSING', 'VOID_PROCESSING'};
    final show = inactiveStatuses.contains(market.status) || market.sportingEvent == true || (backLine.isEmpty && layLine.isEmpty);
    if (!show) return const SizedBox.shrink();

    final text = market.sportingEvent == true || market.status == 'BALL_RUN'
        ? "Ball Running"
        : market.status == 'OFFLINE' || market.status == 'SUSPENDED' || market.status == 'SUSPEND' || (backLine.isEmpty && layLine.isEmpty)
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

  Widget _buildRunnerHeader() {
    final market = widget.fancyMarketData;
    return Container(
      width: double.infinity,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xffe4f1f9),
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            market.marketName,
            style: const TextStyle(color: secondaryTextClr, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.info_outline),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 1,
                height: 35,
                padding: EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Min / Max", style: TextStyle(color: Color(0xff577c94))),
                        hb4,
                        Text("${market.marketCondition?.minBet ?? "-"} / ${market.marketCondition?.maxBet ?? "-"}"),
                      ],
                    ),
                    const Icon(Icons.close, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetSlip(SendOrderState sos) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        final user = ucs is UserAuthChangesSuccess ? ucs.savedUserAuth : null;
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
                  price: isBack ? backPrice : layPrice,
                  betSize: isBack ? backLine : layLine,
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
                  betPlaceOnTap: () => _placeBet(user),
                ),
          crossFadeState: shouldShowBetSlip ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        );
      },
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
