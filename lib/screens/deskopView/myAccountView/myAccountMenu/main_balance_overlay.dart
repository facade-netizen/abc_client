import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../blocs/addBloc/recall_cg_balance_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../models/cg_balance_model.dart';
import '../../../../models/user_details_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/wave_balls_loader.dart';
import '../../../../services/app_config.dart';
import '../../sportsReusables/custom_cta_button.dart';

final ValueNotifier<bool> mainBalanceOverlayOpenNotifier = ValueNotifier(false);

class MainBalanceOverlay extends StatefulWidget {
  const MainBalanceOverlay({super.key});

  @override
  State<MainBalanceOverlay> createState() => _MainBalanceOverlayState();
}

class _MainBalanceOverlayState extends State<MainBalanceOverlay> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  final GlobalKey balanceKey = GlobalKey();

  void toggleBalanceOverlay() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
      mainBalanceOverlayOpenNotifier.value = false;
      return;
    }

    final overlay = Overlay.of(context);
    RenderBox renderBox = balanceKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    UserAccountDetails? currentDetails;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            ModalBarrier(dismissible: true, color: Colors.transparent, onDismiss: toggleBalanceOverlay),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: mbw,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: Offset(offset.dy - 10, size.height + 5),
                child: Material(
                  elevation: 6,
                  color: lightBlueShade,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
                      builder: (context, ucs) {
                        return BlocBuilder<SignalRAccountDataBloc, SignalRAccountDataState>(
                          builder: (context, ras) {
                            if (ucs is FetchUserAccountDetailsSuccess) {
                              currentDetails = ucs.userDetails;
                            }
                            if (ras is SignalRAccountDataSuccess) {
                              currentDetails = ras.accountDetails;
                            }
                            if (currentDetails != null) {
                              context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: currentDetails!.casinoAccount.first.name));
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// MAIN BALANCE
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  height: 110,
                                  decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(6)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Main Balance",
                                        style: TextStyle(fontWeight: FontWeight.bold, color: secondaryTextClr),
                                      ),
                                      hb4,
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: blncNameBox, borderRadius: BorderRadius.circular(4)),
                                            child: SvgPicture.asset(
                                              AppAssetConstants.coinBalance,
                                              colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn),
                                              height: 12,
                                              width: 12,
                                            ),
                                          ),
                                          wb8,
                                          Text(
                                            currentDetails?.balancePoint.toStringAsFixed(2) ?? '0.00',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: black),
                                          ),
                                        ],
                                      ),
                                      hb5,
                                      const Divider(),
                                      hb10,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Exposure", style: TextStyle(color: secondaryTextClr)),
                                          Text("(${currentDetails?.exposure.toStringAsFixed(2) ?? '0.00'})", style: const TextStyle(color: red)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                hb10,
                                BlocConsumer<RecallCGBalanceBloc, RecallCGBalanceState>(
                                  listener: (context, rcb) {
                                    if (rcb is RecallCGBalanceSuccess) {
                                      context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: "RG"));
                                      context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
                                    }
                                  },
                                  builder: (context, rcb) {
                                    return BlocBuilder<FetchCGBalanceBloc, FetchCGBalanceState>(
                                      builder: (context, cbs) {
                                        List<CGBalanceData> cgBalance = [];
                                        if (cbs is FetchCGBalanceSuccess) {
                                          cgBalance = cbs.cgBalanceData;
                                        }
                                        return cgBalance.isEmpty
                                            ? SizedBox()
                                            : Container(
                                                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(6)),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    ...List.generate(cgBalance.length, (index) {
                                                      final casinoAccount = cgBalance[index];
                                                      return ExposureAndRecallTile(
                                                        title: "Casino Balance",
                                                        balance: casinoAccount.currentBalance.toStringAsFixed(2),
                                                        action: () {
                                                          Map<String, dynamic> recallCGBalanceMap = {
                                                            "platformId": appConfig.operatingSystem,
                                                            "provider": casinoAccount.name,
                                                            "amount": casinoAccount.currentBalance,
                                                          };
                                                          context.read<RecallCGBalanceBloc>().add(RecallCGBalance(recallCGBalanceMap: recallCGBalanceMap));
                                                        },
                                                      );
                                                    }),
                                                    hb10,
                                                    SizedBox(
                                                      width: 300,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: RecallCTAButton(
                                                          action: () {
                                                            double totalAmount = cgBalance.fold(0.0, (prev, e) => prev + e.currentBalance);
                                                            Map<String, dynamic> recallCGBalanceMap = {
                                                              "platformId": appConfig.operatingSystem,
                                                              "provider": "RG",
                                                              "amount": totalAmount,
                                                            };
                                                            context.read<RecallCGBalanceBloc>().add(RecallCGBalance(recallCGBalanceMap: recallCGBalanceMap));
                                                          },
                                                          title: "Recall All",
                                                          width: 98,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                  ],
                                                ),
                                              );
                                      },
                                    );
                                  },
                                ),
                                hb10,
                                CancelCTAButton(width: mbw + 50, action: toggleBalanceOverlay),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry!);
    mainBalanceOverlayOpenNotifier.value = true;
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    overlayEntry = null;
    mainBalanceOverlayOpenNotifier.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: MainBalanceButton(
        key: balanceKey,
        action: () {
          context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
          toggleBalanceOverlay();
        },
      ),
    );
  }
}

double mbw = 350;

class AppBarCTAButton extends StatelessWidget {
  const AppBarCTAButton({
    super.key,
    this.color,
    this.width,
    this.action,
    this.height,
    this.gradientColor,
    this.title,
    this.leading,
    this.traling,
    this.msg,
    this.titleWidget,
    this.isDisabled = false,
    this.isProcessing = false,
  });

  final Widget? leading;
  final Widget? traling;
  final Color? color;
  final String? title;
  final double? height;
  final double? width;
  final Function()? action;
  final LinearGradient? gradientColor;
  final bool isDisabled;
  final bool isProcessing;
  final String? msg;
  final Widget? titleWidget;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled || isProcessing ? null : action,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: height ?? 35,
          width: width ?? 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: black),
            boxShadow: [BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: isProcessing
                ? Text(msg ?? "Please wait..", style: TextStyle(color: white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(child: leading),
                      leading == null ? wb0 : wb5,
                      titleWidget ??
                          Text(
                            title ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDisabled ? black : color ?? white),
                          ),
                      traling == null ? wb0 : wb5,
                      SizedBox(child: traling),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class MainBalanceButton extends StatefulWidget {
  const MainBalanceButton({super.key, this.action});
  final Function()? action;

  @override
  State<MainBalanceButton> createState() => _MainBalanceButtonState();
}

class _MainBalanceButtonState extends State<MainBalanceButton> {
  bool _justRefreshed = false;

  void _handleRefresh(BuildContext context) {
    setState(() {
      _justRefreshed = true;
    });
    context.read<SignalRAccountDataBloc>().add(SetToInitialSignalRAccount());
    context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignalRAccountDataBloc, SignalRAccountDataState>(
      listener: (context, state) {
        if (_justRefreshed && state is SignalRAccountDataSuccess) {
          setState(() {
            _justRefreshed = false;
          });
        }
      },
      child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
        builder: (context, ucs) {
          UserAccountDetails? userDetails;
          if (ucs is FetchUserAccountDetailsSuccess) {
            userDetails = ucs.userDetails;
          }
          return BlocBuilder<SignalRAccountDataBloc, SignalRAccountDataState>(
            builder: (context, ras) {
              UserAccountDetails? currentDetails = userDetails;
              if (!_justRefreshed && ras is SignalRAccountDataSuccess) {
                currentDetails = ras.accountDetails;
              }
              return AppBarCTAButton(
                action: widget.action,
                width: mbw,
                titleWidget: ucs is FetchUserAccountDetailsSuccess
                    ? FittedBox(
                        child: Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Main  Balance',
                                style: TextStyle(color: appBarText, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            wb5,
                            SizedBox(
                              child: Row(
                                children: [
                                  SvgPicture.asset(AppAssetConstants.coinBalance, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 12, width: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${currentDetails?.balancePoint.toStringAsFixed(2) ?? 0.0}',
                                    style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            wb10,
                            Text(
                              'Exposure',
                              style: TextStyle(color: appBarText, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            wb5,
                            Text(
                              currentDetails?.exposure == 0 ? "0.0" : currentDetails?.exposure.toStringAsFixed(2) ?? '0.0',
                              style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            wb10,
                            Container(
                              width: 30,
                              height: 18,
                              decoration: BoxDecoration(
                                border: Border.all(color: appBarText),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '+ ${(currentDetails?.casinoAccount.length ?? 0)}',
                                  style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : WaveBallsLoader(),
                traling: InkWell(
                  onTap: () {
                    context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: "RG"));
                    _handleRefresh(context);
                  },
                  child: SvgPicture.asset(AppAssetConstants.refersh, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 22, width: 22),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExposureAndRecallTile extends StatelessWidget {
  final String title;
  final String balance;
  final VoidCallback? action;

  const ExposureAndRecallTile({super.key, required this.title, required this.balance, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: black),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: blncNameBox, // original PIN box color
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SvgPicture.asset(AppAssetConstants.coinBalance, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 12, width: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      balance,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: black),
                    ),
                  ],
                ),
              ],
            ),
            RecallCTAButton(action: action),
          ],
        ),
      ),
    );
  }
}

class RecallCTAButton extends StatelessWidget {
  const RecallCTAButton({super.key, this.action, this.title, this.width});
  final void Function()? action;
  final String? title;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        width: width ?? 72,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xffd9f1ff),
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            title ?? "Recall",
            style: TextStyle(color: secondaryTextClr, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
