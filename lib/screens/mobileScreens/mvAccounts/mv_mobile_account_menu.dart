import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../blocs/authBlocs/user_logout_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../../../blocs/miscBlocs/sports_left_panel_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/user_details_model.dart';
import '../../../reusables/loader.dart';
import '../../../reusables/snack_bar.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/app_config.dart';
import '../../../services/navigators.dart';
import '../mvSetting/mv_setting_screen.dart';
import 'mv_account_string_list.dart';
import 'mv_new_account_menu.dart';

class MobileAccountMenu extends StatefulWidget {
  const MobileAccountMenu({super.key});

  @override
  State<MobileAccountMenu> createState() => _MobileAccountMenuState();
}

class _MobileAccountMenuState extends State<MobileAccountMenu> {
  Timer? timer;
  int? selectIndex;
  String time = '';
  String periods = '';

  void _resetBlocsOnLogout() {
    context.read<UserLoginBloc>().add(SetLoginToInitial());
    context.read<FetchFavStakeBloc>().add(SetToInitialFetchFavStake());
    context.read<SportsLeftPanelBloc>().add(ResetSportsPanel());

    context.read<FetchBookMakerBloc>().add(SetToInitialBM());
    context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
    context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
    context.read<FetchScoreBoardBloc>().add(SetToInitialFetchScoreBoard());

    context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
    context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
    context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
    context.read<SignalRAccountDataBloc>().add(SetToInitialSignalRAccount());
    context.read<SignalRMessageBloc>().add(SetToInitialSignalRMessage());
    context.read<BmProfitLossBloc>().add(SetToInitialBmProfitLoss());
    context.read<OddsProfitLossBloc>().add(SetToInitialOddsProfitLoss());
    context.read<FancyProfitLossBloc>().add(SetToInitialFancyProfitLoss());
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), updateTime);
  }

  void updateTime(Timer timer) {
    final now = DateTime.now();
    int hour = now.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    }
    setState(() {
      time = '${formatTwoDigits(hour)}:${formatTwoDigits(now.minute)}:${formatTwoDigits(now.second)}';
      periods = period;
    });
  }

  String formatTwoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, uas) {
        return BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
          builder: (context, ucs) {
            UserAccountDetails? currentUser;
            if (ucs is FetchUserAccountDetailsSuccess) {
              currentUser = ucs.userDetails;
            }
            return GoRouter.of(context).state.matchedLocation.contains('/account/settings')
                ? MvSettingScreen()
                : GoRouter.of(context).state.matchedLocation.contains('/account/')
                ? MVNewMyAccountMenu()
                : Container(
                    color: white,
                    child: ucs is FetchUserAccountDetailsProgress || uas is UserAuthChangesProgress
                        ? LoaderContainerWithMessage(message: '')
                        : uas is UserAuthChangesSuccess
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                color: bgColor,
                                height: 46,
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(AppAssetConstants.user, colorFilter: ColorFilter.mode(white, BlendMode.srcIn), height: 28, width: 25),
                                          wb10,
                                          Text(currentUser != null ? currentUser.userName : "", style: const TextStyle(fontSize: 16, color: white)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(vertical: BorderSide(color: grey.withValues(alpha: 0.6), width: 1)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text("$time $periods", style: const TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 320,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(
                                      accountMenus.length,
                                      (index) => Container(
                                        height: 45,
                                        decoration: const BoxDecoration(
                                          color: white,
                                          border: Border(bottom: BorderSide(color: grey, width: 0.2)),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            if (index == 5) {
                                              pushSimple(context, MvSettingScreen());
                                            } else {
                                              final section = accountMenus[index].toLowerCase().replaceAll(' ', '-');
                                              if (section.contains('profit-&-loss')) {
                                                final routeToProfitLoss = "/account/my-bets/profit-loss";
                                                context.go(routeToProfitLoss);
                                              } else if (section.contains('bets-history')) {
                                                final routeToProfitLoss = "/account/my-bets/betting-history";
                                                context.go(routeToProfitLoss);
                                              } else {
                                                context.go(GoToRoute.account(section));
                                              }
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  accountMenus[index],
                                                  style: const TextStyle(color: blueShade, fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(border: Border.all(color: grey, width: 0.1)),
                                                  child: const Icon(Icons.arrow_forward_ios, color: black, size: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: grey),
                              BlocConsumer<UserLogoutBloc, UserLogoutState>(
                                listener: (context, uls) {
                                  if (uls is UserLogoutSuccess) {
                                    _resetBlocsOnLogout();
                                    context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    }
                                    showSnackBar(context, "You have been logged out successfully");
                                  }
                                },
                                builder: (context, uls) {
                                  return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                                    builder: (context, ucs) {
                                      return Visibility(
                                        visible: ucs is UserAuthChangesSuccess && ucs.savedUserAuth != null,
                                        child: Container(
                                          height: 57,
                                          decoration: const BoxDecoration(color: red),
                                          child: InkWell(
                                            onTap: () async {
                                              context.read<UserLogoutBloc>().add(UserLogoutListener());
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "LOGOUT",
                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: white),
                                                    ),
                                                    Icon(Icons.logout, color: white),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              Spacer(),
                              Text("v ${appConfig.version} (${appConfig.buildNumber})", style: TextStyle(color: bgColor)),
                            ],
                          )
                        : Center(
                            child: Text('Please login your account.', style: TextStyle(color: black, fontSize: 20)),
                          ),
                  );
          },
        );
      },
    );
  }
}
