import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../blocs/addBloc/recall_cg_balance_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/cg_balance_model.dart';
import '../../../models/user_details_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../services/app_config.dart';
import '../../../services/navigators.dart';

void showTopSheet(BuildContext context, UserAccountDetails userDetails, List<CGBalanceData> cgBalanceData) {
  final rect = const RelativeRect.fromLTRB(0, 60, 0, 0);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "TopSheet",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      UserAccountDetails currentUserDetails = userDetails;
      List<CGBalanceData> cgBalance = cgBalanceData;
      return Stack(
        children: [
          Positioned(
            left: rect.left,
            right: rect.right,
            top: rect.top,
            child: Material(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: lightBlueShade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
                      builder: (context, ucs) {
                        if (ucs is FetchUserAccountDetailsSuccess) {
                          currentUserDetails = ucs.userDetails;
                        }
                        return BlocBuilder<SignalRAccountDataBloc, SignalRAccountDataState>(
                          builder: (context, ras) {
                            if (ras is SignalRAccountDataSuccess) {
                              currentUserDetails = ras.accountDetails;
                            }
                            return Container(
                              padding: const EdgeInsets.all(8),
                              height: 110,
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
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
                                        child: SvgPicture.asset(AppAssetConstants.coinBalance, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 12, width: 12),
                                      ),
                                      wb8,
                                      Text(
                                        currentUserDetails.balancePoint.toStringAsFixed(2),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: black),
                                      ),
                                    ],
                                  ),
                                  hb5,
                                  Divider(),
                                  hb10,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Exposure", style: TextStyle(color: secondaryTextClr)),
                                      Text("(${currentUserDetails.exposure.toStringAsFixed(2)})", style: TextStyle(color: red)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
                            if (cbs is FetchCGBalanceSuccess) {
                              cgBalance = cbs.cgBalanceData;
                            }
                            return cgBalance.isEmpty
                                ? SizedBox()
                                : Container(
                                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        ...List.generate(cgBalance.length, (index) {
                                          final casinoAccount = cgBalance[index];
                                          return BalanceAndExposureTile(
                                            title: "Casino Balance",
                                            balance: casinoAccount.currentBalance.toStringAsFixed(2),
                                            onTap: () {
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
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              double totalAmount = cgBalance.fold(0.0, (prev, e) => prev + e.currentBalance);
                                              Map<String, dynamic> recallCGBalanceMap = {"platformId": appConfig.operatingSystem, "provider": "RG", "amount": totalAmount};
                                              context.read<RecallCGBalanceBloc>().add(RecallCGBalance(recallCGBalanceMap: recallCGBalanceMap));
                                            },
                                            child: Container(
                                              width: 98,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffd9f1ff),
                                                border: Border.all(color: grey),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Recall All",
                                                  style: TextStyle(color: secondaryTextClr, fontSize: 17, fontWeight: FontWeight.bold),
                                                ),
                                              ),
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
                    InkWell(
                      onTap: () {
                        removeScreen(context);
                      },
                      child: Container(
                        width: 207,
                        height: 40,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(color: grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "Close",
                            style: TextStyle(color: black, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}

class BalanceAndExposureTile extends StatelessWidget {
  final String title;
  final String? balance; // 👈 optional
  final Widget? balanceWidget; // 👈 new
  final VoidCallback? onTap;

  const BalanceAndExposureTile({super.key, required this.title, this.balance, this.balanceWidget, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
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
                      decoration: BoxDecoration(color: blncNameBox, borderRadius: BorderRadius.circular(4)),
                      child: SvgPicture.asset(AppAssetConstants.coinBalance, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 12, width: 12),
                    ),
                    const SizedBox(width: 8),

                    /// 👇 MAGIC HERE
                    balanceWidget ??
                        Text(
                          balance ?? "0.00",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: black),
                        ),
                  ],
                ),
              ],
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                width: 72,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xffd9f1ff),
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    "Recall",
                    style: TextStyle(color: secondaryTextClr, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
