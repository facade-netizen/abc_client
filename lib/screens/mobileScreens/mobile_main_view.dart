import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/lists/landing_screen_lists.dart';
import '../../../reusables/custom_app_bar.dart';
import '../../blocs/addBloc/send_order_bloc.dart';
import '../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../blocs/authBlocs/user_logout_bloc.dart';
import '../../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../../blocs/signalRBloc/signalr_remove_events_bloc.dart';
import '../../blocs/signalRBloc/single_user_login_session_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/user_login_session_stream_bloc.dart';
import '../../localDb/token/login_token_model.dart';
import '../../reusables/buttons.dart';
import '../../reusables/colors.dart';
import '../../reusables/marquee.dart';
import '../../reusables/search_controller.dart';
import '../../reusables/sized_box_hw.dart';
import '../../reusables/snack_bar.dart';
import '../../services/navigators.dart';
import '../../services/reset_bloc_helper.dart';
import '../chatBot/chat_bot.dart';
import 'home_screen_mobile_appbar.dart';
import 'mobileAuthView/mobileAuthView/mv_login_screen.dart';

class MVMainView extends StatefulWidget {
  final Widget child;
  const MVMainView({super.key, required this.child});

  @override
  State<MVMainView> createState() => _MVMainViewState();
}

class _MVMainViewState extends State<MVMainView> {
  @override
  void initState() {
    context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        SaveLoginTokenModel? savedUserAuth;
        if (ucs is UserAuthChangesSuccess) {
          savedUserAuth = ucs.savedUserAuth;
        }
        return MobileMainView(key: UniqueKey(), userLoggedinSaveData: savedUserAuth, child: widget.child);
      },
    );
  }
}

class MobileMainView extends StatefulWidget {
  final Widget child;
  final SaveLoginTokenModel? userLoggedinSaveData;
  const MobileMainView({super.key, required this.child, this.userLoggedinSaveData});

  @override
  State<MobileMainView> createState() => _MobileMainViewState();
}

class _MobileMainViewState extends State<MobileMainView> {
  int getIndexFromRoute(String location) {
    if (location.startsWith('/sport')) return 0;
    if (location.startsWith('/inplay') || location.startsWith('/result')) return 1;
    if (location.startsWith('/home')) return 2;
    if (location.startsWith('/multimarkets')) return 3;
    if (location.startsWith('/account')) return 4;
    return 2;
  }

  String getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/sport/4/Cricket';
      case 1:
        return '/inplay';
      case 2:
        return '/home';
      case 3:
        return '/multimarkets';
      case 4:
        return '/account';
      default:
        return '/home';
    }
  }

  @override
  void initState() {
    if (!Get.isRegistered<GlobalSearchController>()) {
      Get.put(GlobalSearchController());
    }
    super.initState();
    initializeBlocs();
    context.read<RemoveEventsListenerBloc>().add(RemoveEventsListener());
    context.read<RemoveEventSignalRStreamerBloc>().add(RemoveEventSignalRStreamerListener());
  }

  @override
  void didUpdateWidget(covariant MobileMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasNull = oldWidget.userLoggedinSaveData == null;
    final isNowLoggedIn = widget.userLoggedinSaveData != null;
    if (wasNull && isNowLoggedIn) {
      initializeBlocs();
    }
  }

  bool _blocsInitialized = false;
  void initializeBlocs() {
    if (_blocsInitialized) return;
    if (widget.userLoggedinSaveData != null && widget.userLoggedinSaveData!.role != null) {
      _blocsInitialized = true;
      context.read<SingleUserLoginSessionStreamerRBloc>().add(SingleUserLoginSessionStreamerR());
      context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
      context.read<FetchFavStakeBloc>().add(FetchFavStake());
      context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: "RG"));
      context.read<SignalRHubListenerBloc>().add(SignalRHubListener());
      context.read<SignalRAccountDataBloc>().add(SignalRAccountDataListener());
      context.read<SignalRMessageBloc>().add(SignalRMessageListener());
      context.read<BmProfitLossBloc>().add(BmProfitLossListener());
      context.read<FancyProfitLossBloc>().add(FancyProfitLossListener());
      context.read<OddsProfitLossBloc>().add(OddsProfitLossListener());
      context.read<UserSessionStreamBloc>().add(UserSessionStreamListener());
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.matchedLocation;
    final currentIndex = getIndexFromRoute(location);
    return BlocListener<UserLogoutBloc, UserLogoutState>(
      listener: (context, state) {
        if (state is UserLogoutSuccess) {
          LogoutHelper.resetAll(context);
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
        }
      },
      child: BlocListener<UserSessionStreamBloc, UserSessionStreamState>(
        listener: (context, state) {
          if (state is UserSessionStreamSuccess) {
            if (state.message.contains("logout") || state.message.contains("passwordlocked") || state.message.contains("systemlocked") || state.message.contains("multilock")) {
              context.read<UserLogoutBloc>().add(UserLogoutListener());
              if (state.message.contains("systemlocked")) {
                showSnackBar(context, "Account is locked! Please contact your upline", error: true);
              } else {
                showSnackBar(context, "You were logged out because your account was used in another session.", error: true);
              }
            }
          }
        },
        child: BlocListener<SignalRMessageBloc, SignalRMessageState>(
          listener: (context, ols) {
            if (ols is SignalRMessageSuccess) {
              showSnackBar(context, ols.message, error: ols.status == 200 ? false : true);
            }
          },
          child: BlocListener<SendOrderBloc, SendOrderState>(
            listener: (context, state) {
              if (state is SendOrderFailure) {
                showSnackBar(context, state.error, error: true);
              }
            },
            child: Scaffold(
              backgroundColor: white,
              appBar: PreferredSize(
                preferredSize: widget.userLoggedinSaveData != null ? const Size.fromHeight(96) : const Size.fromHeight(65),
                child: AppBar(
                  backgroundColor: whiteOpac,
                  flexibleSpace: Column(children: widget.userLoggedinSaveData != null ? [const CustomSportAppBar(), const MarqueeNews()] : [const MobileLogInMobileAppBar()]),
                ),
              ),
              body: SafeArea(
                child: KeyedSubtree(key: sportsBottomNavBarItems[currentIndex]['key'] ?? UniqueKey(), child: widget.child),
              ),
              bottomNavigationBar: Container(
                height: 57,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF243A48), Color(0xFF172732)])),
                child: Row(
                  children: List.generate(
                    sportsBottomNavBarItems.length,
                    (index) => Expanded(
                      child: InkWell(
                        onTap: () {
                          if (widget.userLoggedinSaveData == null && index == 4) {
                            pushSimple(context, MVLogin());
                          } else {
                            context.go(getRouteFromIndex(index));
                            context.read<EnableMatchButtonBloc>().add(EnableMatchButton(false, "0"));
                          }
                        },
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: index == currentIndex
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color.fromARGB(255, 49, 70, 83), Color.fromARGB(230, 67, 105, 129)],
                                  )
                                : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF243A48), Color(0xFF172732)]),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(sportsBottomNavBarItems[index]['icon'], colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), height: 25, width: 25),
                              hb4,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  sportsBottomNavBarItems[index]['text'].toString(),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              floatingActionButton: CustomFAB(
                onPressed: () {
                  showChat(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
