import 'package:abc_client/reusables/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../blocs/miscBlocs/check_match_stream_live_bloc.dart';
import '../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../constants/app_asset_constants.dart';
import '../models/cg_balance_model.dart';
import '../models/user_details_model.dart';
import '../screens/mobileScreens/mvAccounts/mv_balance_top_sheet.dart';
import '../screens/mobileScreens/mvBets/mv_open_bets_screen.dart';
import '../screens/mobileScreens/mvSetting/mv_setting_screen.dart';
import '../demo/services/demo_session.dart';
import '../services/navigators.dart';
import 'colors.dart';
import 'sized_box_hw.dart';
import 'text_style.dart';
import 'wave_balls_loader.dart';

class CustomSportAppBar extends StatefulWidget {
  const CustomSportAppBar({super.key});
  @override
  State<CustomSportAppBar> createState() => _CustomSportAppBarState();
}

class _CustomSportAppBarState extends State<CustomSportAppBar> {
  bool isPlayed = false;
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
    return Container(
      height: 64,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: bottomBarGradient),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<EnableMatchButtonBloc, EnableMatchButtonState>(
              builder: (context, state) {
                return AppBarButtons(
                  onTap: () {
                    if (DemoSession.isActive) {
                      showSnackBar(context, "This option is disabled in Demo Mode. Check your bets in your account.", error: true);
                    } else {
                      pushSimple(context, MvOpenBetsScreen());
                    }
                  },
                  width: state is EnableMatchButtonSuccess && state.isLive == true ? 136 : 100,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (state is EnableMatchButtonSuccess && state.isLive == true && !DemoSession.isActive)
                        InkWell(
                          onTap: () {
                            setState(() {
                              isPlayed = !isPlayed;
                            });
                            context.read<CheckMatchStreamLiveBloc>().add(CheckMatchStreamLive(isPlayed, "0"));
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(color: isPlayed ? red : darkGreen, borderRadius: BorderRadius.circular(2)),
                            child: Padding(padding: const EdgeInsets.all(2), child: Image.asset(height: 50, isPlayed ? AppAssetConstants.closeTv : AppAssetConstants.livetv)),
                          ),
                        ),
                      wb10,
                      SvgPicture.asset(AppAssetConstants.dollar, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 22, width: 22),
                      wb10,
                      SizedBox(
                        child: Text('Bets', style: customAppBarTitleStyle(), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                );
              },
            ),
            wb10,
            BlocListener<SignalRAccountDataBloc, SignalRAccountDataState>(
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
                      return BlocBuilder<FetchCGBalanceBloc, FetchCGBalanceState>(
                        builder: (context, cbs) {
                          List<CGBalanceData> cgBalanceData = [];
                          if (cbs is FetchCGBalanceSuccess) {
                            cgBalanceData = cbs.cgBalanceData;
                          }
                          return Row(
                            children: [
                              AppBarButtons(
                                onTap: ucs is FetchUserAccountDetailsSuccess
                                    ? () {
                                        context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
                                        context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: "RG"));
                                        showTopSheet(context, currentDetails!, cgBalanceData);
                                      }
                                    : null,
                                width: 197,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                child: ucs is FetchUserAccountDetailsSuccess
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Text(
                                                        'Main',
                                                        style: TextStyle(color: appBarText, fontSize: 11),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    wb2,
                                                    SizedBox(
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                            AppAssetConstants.coinBalance,
                                                            colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn),
                                                            height: 12,
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            ' ${currentDetails!.balancePoint.toStringAsFixed(2)}',
                                                            style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                hb4,
                                                SizedBox(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Exposure',
                                                        style: TextStyle(color: appBarText, fontSize: 11),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      wb2,
                                                      Container(
                                                        decoration: BoxDecoration(color: currentDetails.exposure == 0 ? none : red, borderRadius: BorderRadius.circular(5)),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(2),
                                                          child: Center(
                                                            child: Text(
                                                              currentDetails.exposure == 0 ? "0.0" : '(${currentDetails.exposure.toStringAsFixed(2)})',
                                                              style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Container(
                                              width: 35,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: appBarText),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '+${currentDetails.casinoAccount.length}',
                                                  style: TextStyle(color: appBarText, fontSize: 11, fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : WaveBallsLoader(),
                              ),
                              AppBarButtons(
                                onTap: () {
                                  context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: "RG"));
                                  _handleRefresh(context);
                                },
                                width: 40,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(AppAssetConstants.refersh, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 22, width: 22),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            wb10,
            AppBarButtons(
              onTap: () {
                pushSimple(context, MvSettingScreen());
              },
              width: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AppAssetConstants.setting, colorFilter: ColorFilter.mode(appBarText, BlendMode.srcIn), height: 22, width: 22),
              ),
            ),
            wb5,
          ],
        ),
      ),
    );
  }
}

class AppBarButtons extends StatelessWidget {
  final double? width;
  final Widget? child;
  final void Function()? onTap;
  final BorderRadiusGeometry? borderRadius;
  const AppBarButtons({super.key, this.width, this.child, this.onTap, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          border: Border.all(color: black),
          boxShadow: [BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        width: width,
        child: child,
      ),
    );
  }
}
