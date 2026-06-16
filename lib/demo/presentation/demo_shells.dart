import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../blocs/authBlocs/user_logout_bloc.dart';
import '../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../../blocs/miscBlocs/sports_session_connect_bloc.dart';
import '../../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../../blocs/signalRBloc/single_user_login_session_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../blocs/signalRBloc/singnalRStreamers/user_login_session_stream_bloc.dart';
import '../../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../../constants/lists/landing_screen_lists.dart';
import '../../localDb/token/login_token_model.dart';
import '../../reusables/colors.dart';
import '../../reusables/buttons.dart';
import '../../reusables/custom_app_bar.dart';
import '../../reusables/marquee.dart';
import '../../reusables/search_controller.dart';
import '../../reusables/sized_box_hw.dart';
import '../../reusables/snack_bar.dart';
import '../../screens/chatBot/chat_bot.dart';
import '../../screens/deskopView/mainTabView/desktop_appbar_login.dart';
import '../../screens/deskopView/mainTabView/desktop_chat.dart';
import '../../screens/deskopView/mainTabView/main_tab_menu_card.dart';
import '../../screens/deskopView/myAccountView/settings_overlay.dart';
import '../../screens/mobileScreens/home_screen_mobile_appbar.dart';
import '../../services/navigators.dart';
import '../../services/reset_bloc_helper.dart';
import '../../services/web_new_tab_service.dart';
import '../routing/demo_route_mapper.dart';

class DemoMVMainView extends StatefulWidget {
  const DemoMVMainView({super.key, required this.child});

  final Widget child;

  @override
  State<DemoMVMainView> createState() => _DemoMVMainViewState();
}

class _DemoMVMainViewState extends State<DemoMVMainView> {
  @override
  void initState() {
    if (!Get.isRegistered<GlobalSearchController>()) {
      Get.put(GlobalSearchController());
    }
    context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) => _DemoMobileMainView(userLoggedinSaveData: ucs is UserAuthChangesSuccess ? ucs.savedUserAuth : null, child: widget.child),
    );
  }
}

class _DemoMobileMainView extends StatefulWidget {
  const _DemoMobileMainView({required this.child, this.userLoggedinSaveData});

  final Widget child;
  final SaveLoginTokenModel? userLoggedinSaveData;

  @override
  State<_DemoMobileMainView> createState() => _DemoMobileMainViewState();
}

class _DemoMobileMainViewState extends State<_DemoMobileMainView> {
  bool _blocsInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeBlocs();
  }

  @override
  void didUpdateWidget(covariant _DemoMobileMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLoggedinSaveData == null && widget.userLoggedinSaveData != null) initializeBlocs();
  }

  int getIndexFromRoute(String location) {
    final route = DemoRouteMapper.stripDemoPrefix(location);
    if (route.startsWith('/sport')) return 0;
    if (route.startsWith('/inplay') || route.startsWith('/result')) return 1;
    if (route.startsWith('/home')) return 2;
    if (route.startsWith('/multimarkets')) return 3;
    if (route.startsWith('/account')) return 4;
    return 2;
  }

  String getRouteFromIndex(int index) {
    final route = switch (index) {
      0 => '/sport/4/Cricket',
      1 => '/inplay',
      2 => '/home',
      3 => '/multimarkets',
      4 => '/account',
      _ => '/home',
    };
    return DemoRouteMapper.redirectToDemoIfNeeded(route) ?? route;
  }

  void initializeBlocs() {
    if (_blocsInitialized || widget.userLoggedinSaveData?.role == null) return;
    _blocsInitialized = true;
    context.read<SingleUserLoginSessionStreamerRBloc>().add(SingleUserLoginSessionStreamerR());
    context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
    context.read<FetchFavStakeBloc>().add(FetchFavStake());
    context.read<FetchCGBalanceBloc>().add(FetchCGBalance(provider: 'RG'));
    context.read<SignalRHubListenerBloc>().add(SignalRHubListener());
    context.read<SignalRAccountDataBloc>().add(SignalRAccountDataListener());
    context.read<SignalRMessageBloc>().add(SignalRMessageListener());
    context.read<BmProfitLossBloc>().add(BmProfitLossListener());
    context.read<FancyProfitLossBloc>().add(FancyProfitLossListener());
    context.read<OddsProfitLossBloc>().add(OddsProfitLossListener());
    context.read<UserSessionStreamBloc>().add(UserSessionStreamListener());
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
          context.go('/home');
        }
      },
      child: BlocListener<UserSessionStreamBloc, UserSessionStreamState>(
        listener: (context, state) {
          if (state is UserSessionStreamSuccess &&
              (state.message.contains('logout') || state.message.contains('passwordlocked') || state.message.contains('systemlocked') || state.message.contains('suspended'))) {
            context.read<UserLogoutBloc>().add(UserLogoutListener());
            showSnackBar(context, 'You were logged out because your account was used in another session.', error: true);
          }
        },
        child: BlocListener<SignalRMessageBloc, SignalRMessageState>(
          listener: (context, state) {
            if (state is SignalRMessageSuccess) showSnackBar(context, state.message, error: state.status != 200);
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
                          pushSimple(context, const SizedBox.shrink());
                        } else {
                          context.go(getRouteFromIndex(index));
                          context.read<EnableMatchButtonBloc>().add(EnableMatchButton(false, "0"));
                        }
                      },
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: index == currentIndex
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color.fromARGB(255, 49, 70, 83), Color.fromARGB(230, 67, 105, 129)],
                                )
                              : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF243A48), Color(0xFF172732)]),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(sportsBottomNavBarItems[index]['icon'], colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), height: 25, width: 25),
                            hb4,
                            Padding(
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
            floatingActionButton: CustomFAB(onPressed: () => showChat(context)),
          ),
        ),
      ),
    );
  }
}

class DemoDesktopMainTab extends StatefulWidget {
  const DemoDesktopMainTab({super.key, required this.child});

  final Widget child;

  @override
  State<DemoDesktopMainTab> createState() => _DemoDesktopMainTabState();
}

class _DemoDesktopMainTabState extends State<DemoDesktopMainTab> {
  @override
  void initState() {
    context.read<FetchOnlyInplayCountsBloc>().add(FetchOnlyInplayCounts());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<UserAuthChangesBloc>().add(StartUserChangeListener()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, state) => _DemoDesktopMainView(userLoggedinSaveData: state is UserAuthChangesSuccess ? state.savedUserAuth : null, child: widget.child),
    );
  }
}

class _DemoDesktopMainView extends StatefulWidget {
  const _DemoDesktopMainView({required this.child, this.userLoggedinSaveData});

  final SaveLoginTokenModel? userLoggedinSaveData;
  final Widget child;

  @override
  State<_DemoDesktopMainView> createState() => _DemoDesktopMainViewState();
}

class _DemoDesktopMainViewState extends State<_DemoDesktopMainView> {
  late final GoRouter _goRouter;
  List<TabItem> tabMenus = [];
  String selectedTab = 'Home';
  String? selectedSportId;
  bool _initialized = false;
  bool isRouteChanged = false;

  @override
  void initState() {
    if (!Get.isRegistered<GlobalSearchController>()) {
      Get.put(GlobalSearchController());
    }
    super.initState();
    initializeBlocs();
    _goRouter = GoRouter.of(context);
    _goRouter.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRouteChanged();
      context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    });
  }

  @override
  void dispose() {
    _goRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DemoDesktopMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLoggedinSaveData == null && widget.userLoggedinSaveData != null) initializeBlocs();
    if (oldWidget.userLoggedinSaveData != null && widget.userLoggedinSaveData == null) _initialized = false;
  }

  void initializeBlocs() {
    if (_initialized || widget.userLoggedinSaveData?.role == null) return;
    _initialized = true;
    context.read<SingleUserLoginSessionStreamerRBloc>().add(SingleUserLoginSessionStreamerR());
    context.read<FetchFavouriteBloc>().add(FetchFavourite());
    context.read<FetchOpenOrdersBloc>().add(FetchOpenOrders());
    context.read<FetchUserAccountDetailsBloc>().add(FetchUserAccountDetails());
    context.read<SignalRHubListenerBloc>().add(SignalRHubListener());
    context.read<SignalRAccountDataBloc>().add(SignalRAccountDataListener());
    context.read<SignalRMessageBloc>().add(SignalRMessageListener());
    context.read<BmProfitLossBloc>().add(BmProfitLossListener());
    context.read<FancyProfitLossBloc>().add(FancyProfitLossListener());
    context.read<OddsProfitLossBloc>().add(OddsProfitLossListener());
    context.read<UserSessionStreamBloc>().add(UserSessionStreamListener());
  }

  void _disconnectAllEvents() {
    context.read<SubscribeMultiEventsSignalRBloc>().add(DisconnectMultiEventsSignalR(eventIds: const []));
    sportsSessionConnect(ctxt: context, type: SessionType.disconnect, eventId: "0");
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final location = DemoRouteMapper.stripDemoPrefix(_goRouter.state.matchedLocation);
    setState(() {
      if (location == '/' || location == '/home') {
        selectedTab = 'Home';
        selectedSportId = null;
      } else if (location.startsWith('/inplay')) {
        selectedTab = 'In-Play';
        selectedSportId = null;
      } else if (location == '/multimarkets') {
        selectedTab = 'Multi Markets';
        selectedSportId = null;
      } else if (location.startsWith('/result')) {
        selectedTab = 'Result';
        selectedSportId = null;
      } else if (location.startsWith('/sport')) {
        final parts = location.split('/');
        selectedSportId = parts.length >= 3 ? parts[2] : null;
        final sportName = parts.length >= 4 ? parts[3] : '';
        final sportTab = sportName.toLowerCase().contains('fifa')
            ? tabMenus.firstWhereOrNull((tab) => tab.eventTypeId == selectedSportId && tab.title.toLowerCase().contains('fifa'))
            : tabMenus.firstWhereOrNull((tab) => tab.eventTypeId == selectedSportId);
        selectedTab = sportTab?.title ?? 'Cricket';
      }
    });
  }

  String getRouteForTab(TabItem tab) {
    final route = tab.title == 'Home'
        ? '/home'
        : tab.title == 'In-Play'
        ? '/inplay'
        : tab.title == 'Multi Markets'
        ? '/multimarkets'
        : tab.title == 'Result'
        ? '/result'
        : tab.eventTypeId != null
        ? '/sport/${tab.eventTypeId}/${tab.title}'
        : '/home';
    return DemoRouteMapper.redirectToDemoIfNeeded(route) ?? route;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserLogoutBloc, UserLogoutState>(
      listener: (context, state) {
        if (state is UserLogoutSuccess) {
          LogoutHelper.resetAll(context);
          context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          context.go('/home');
        }
      },
      child: BlocListener<UserSessionStreamBloc, UserSessionStreamState>(
        listener: (context, state) {
          if (state is UserSessionStreamSuccess &&
              (state.message.contains('logout') || state.message.contains('passwordlocked') || state.message.contains('systemlocked') || state.message.contains('suspended'))) {
            context.read<UserLogoutBloc>().add(UserLogoutListener());
            showSnackBar(context, 'You were logged out because your account was used in another session.', error: true);
          }
        },
        child: BlocListener<SignalRMessageBloc, SignalRMessageState>(
          listener: (context, state) {
            if (state is SignalRMessageSuccess) showSnackBar(context, state.message, error: state.status != 200);
          },
          child: BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
            builder: (context, state) {
              tabMenus = [...staticTabs];
              if (state is FetchSportsCategorySuccess) {
                tabMenus.addAll(state.categoryResponse.data.map((item) => TabItem(title: item.name, count: item.count, eventTypeId: item.id)));
                tabMenus.add(const TabItem(title: 'Result'));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!isRouteChanged) {
                    isRouteChanged = true;
                    _onRouteChanged();
                  }
                });
              }
              return Scaffold(
                backgroundColor: whiteOpac,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(120),
                  child: AppBar(
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(gradient: bottomBarGradient),
                      child: Column(
                        children: [
                          DesktopAppbarLogin(action: () {}),
                          hb10,
                          Container(
                            height: 35,
                            decoration: const BoxDecoration(gradient: loginbg),
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: tabMenus.map((tab) {
                                        return RightClickWrapper(
                                          route: getRouteForTab(tab),
                                          child: MainMenuTabCard(
                                            title: tab.title,
                                            selectedTab: selectedTab,
                                            liveCount: tab.count,
                                            eventTypeId: tab.eventTypeId,
                                            action: () {
                                              setState(() {
                                                selectedTab = tab.title;
                                                selectedSportId = tab.eventTypeId;
                                              });
                                              _disconnectAllEvents();
                                              WidgetsBinding.instance.addPostFrameCallback((_) => context.go(getRouteForTab(tab)));
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const SettingsOverlay(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const MarqueeNews(),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ),
                floatingActionButton: const ChatOverlay(),
              );
            },
          ),
        ),
      ),
    );
  }
}
