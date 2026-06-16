import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;

import '../../../blocs/addBloc/send_order_bloc.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/authBlocs/user_logout_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_all_events_for_search_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_match_result_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../../blocs/miscBlocs/sports_session_connect_bloc.dart';
import '../../../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../../../blocs/signalRBloc/signalr_remove_events_bloc.dart';
import '../../../blocs/signalRBloc/single_user_login_session_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/user_login_session_stream_bloc.dart';
import '../../../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/highlighted_text_widget.dart';
import '../../../reusables/marquee.dart';
import '../../../reusables/search_controller.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../services/reset_bloc_helper.dart';
import '../../../services/web_new_tab_service.dart';

import '../betRadarView/bet_radar_view_for_tab_menu.dart';
import '../myAccountView/settings_overlay.dart';
import '../newSportsView/new_sports_view_screen.dart';
import 'desktop_appbar_login.dart';
import 'desktop_chat.dart';
import 'main_tab_menu_card.dart';
import '../myAccountView/myAccountMenu/my_account_menu.dart';

import 'package:go_router/go_router.dart';

// Keep your old screen imports if you still reference them in menusScreen()
// (you can gradually replace them with the new ones later)

class DesktopMainTab extends StatefulWidget {
  final Widget child; // ← Received from ShellRoute

  const DesktopMainTab({super.key, required this.child});

  @override
  State<DesktopMainTab> createState() => _DesktopMainTabState();
}

class _DesktopMainTabState extends State<DesktopMainTab> {
  @override
  void initState() {
    context.read<FetchOnlyInplayCountsBloc>().add(FetchOnlyInplayCounts());
    context.read<FetchAllEventsForSearchBloc>().add(FetchAllEventsForSearch());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, ucs) {
        final savedUserAuth = ucs is UserAuthChangesSuccess ? ucs.savedUserAuth : null;
        return DesktopMainView(userLoggedinSaveData: savedUserAuth, child: widget.child);
      },
    );
  }
}

class DesktopMainView extends StatefulWidget {
  const DesktopMainView({super.key, this.userLoggedinSaveData, required this.child});

  final SaveLoginTokenModel? userLoggedinSaveData;
  final Widget child;

  @override
  State<DesktopMainView> createState() => _DesktopMainViewState();
}

class _DesktopMainViewState extends State<DesktopMainView> {
  String selectedTab = 'Home';
  String? selectedSportId;
  bool isMyAccount = false;
  bool showSearchBar = false;
  final TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  late html.EventListener _keyListener;

  // Add this to listen to route changes
  late final GoRouter _goRouter;
  List<TabItem> tabMenus = [];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GlobalSearchController>()) {
      Get.put(GlobalSearchController());
    }
    _keyListener = (event) {
      if (event is html.KeyboardEvent) {
        final isCtrlF = (event.ctrlKey || event.metaKey) && event.key?.toLowerCase() == 'f';

        if (isCtrlF) {
          event.preventDefault();
          if (!mounted) return;
          setState(() {
            if (showSearchBar) {
              Get.find<GlobalSearchController>().clear();
            }
            showSearchBar = !showSearchBar;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchFocusNode.requestFocus();
          });
        }

        if (event.key == 'Escape' && showSearchBar) {
          setState(() {
            showSearchBar = false;
            searchController.clear();
          });
          Get.find<GlobalSearchController>().clear();
        }
      }
    };

    html.window.addEventListener('keydown', _keyListener);

    initializeBlocs();
    context.read<RemoveEventsListenerBloc>().add(RemoveEventsListener());
    context.read<RemoveEventSignalRStreamerBloc>().add(RemoveEventSignalRStreamerListener());
    _goRouter = GoRouter.of(context);

    _goRouter.routerDelegate.addListener(_onRouteChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRouteChanged();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
    });
  }

  bool _initialized = false;
  void initializeBlocs() {
    if (_initialized) return;
    if (widget.userLoggedinSaveData != null && widget.userLoggedinSaveData!.role != null) {
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
      context.read<FetchMatchResultBloc>().add(FetchMatchResult());
      context.read<FetchOneClickDataBloc>().add(FetchOneClickData());
    }
  }

  @override
  void didUpdateWidget(covariant DesktopMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasNull = oldWidget.userLoggedinSaveData == null;
    final isNowNotNull = widget.userLoggedinSaveData != null;
    final wasLoggedIn = oldWidget.userLoggedinSaveData != null;
    final isNowLoggedOut = widget.userLoggedinSaveData == null;

    if (wasNull && isNowNotNull) {
      initializeBlocs();
    }

    if (wasLoggedIn && isNowLoggedOut) {
      _initialized = false;
      _disconnectAllEvents();
      if (mounted) {
        setState(() {
          isMyAccount = false;
          selectedTab = 'Home';
          selectedSportId = null;
        });
      }
    }
  }

  void _disconnectAllEvents() {
    final multiBloc = context.read<SubscribeMultiEventsSignalRBloc>();
    final singleEventIds = [];
    for (final id in singleEventIds) {
      if (id != null) {
        sportsSessionConnect(ctxt: context, type: SessionType.disconnect, eventId: id);
      }
    }

    final multiEventLists = [];
    for (final ids in multiEventLists) {
      if (ids.isNotEmpty) {
        multiBloc.add(DisconnectMultiEventsSignalR(eventIds: ids));
      }
    }
  }

  @override
  void dispose() {
    _goRouter.routerDelegate.removeListener(_onRouteChanged);
    html.window.removeEventListener('keydown', _keyListener);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    final String location = _goRouter.state.matchedLocation;
    setState(() {
      if (location == '/' || location == '/home') {
        selectedTab = 'Home';
        selectedSportId = null;
        return;
      }

      if (location.startsWith('/result')) {
        selectedTab = 'Result';
        selectedSportId = null;
        return;
      }

      if (location.contains('/event/')) {
        final parts = location.split('/');
        String? sportId;
        if (location.startsWith('/inplay') && parts.length >= 3) {
          sportId = parts[2];
        } else if (location.startsWith('/multimarkets') && parts.length >= 3) {
          sportId = parts[2];
        }

        if (sportId != null) {
          selectedSportId = sportId;
          final sportTab = tabMenus.firstWhereOrNull((tab) => tab.eventTypeId == sportId);
          selectedTab = sportTab?.title ?? 'Cricket';
          return;
        }
      }

      if (location.startsWith('/inplay')) {
        selectedTab = 'In-Play';
        selectedSportId = null;
      } else if (location == '/multimarkets') {
        selectedTab = 'Multi Markets';
        selectedSportId = null;
      } else if (location.contains('/result')) {
        selectedTab = 'Result';
        selectedSportId = null;
      } else if (location.startsWith('/sport')) {
        final parts = location.split('/');
        if (parts.length >= 3) {
          final sportIdStr = parts[2];
          selectedSportId = sportIdStr;
          final sportName = parts[3].toString();
          TabItem? sportTab;
          if (sportName.toLowerCase().contains('fifa')) {
            sportTab = tabMenus.firstWhereOrNull((tab) => tab.eventTypeId == selectedSportId && tab.title.toLowerCase().contains('fifa'));
          } else {
            sportTab = tabMenus.firstWhereOrNull((tab) => tab.eventTypeId == selectedSportId);
          }
          if (sportTab != null) {
            selectedTab = sportTab.title;
          } else {
            selectedTab = 'Cricket';
          }
        }
      }
    });
  }

  // Keep your initializeBlocs and _disconnectAllEvents unchanged
  bool isRouteChanged = false;

  String getRouteForTab(TabItem tab) {
    if (tab.title == 'Home') {
      return '/home';
    } else if (tab.title == 'In-Play') {
      return '/inplay';
    } else if (tab.title == 'Multi Markets') {
      return '/multimarkets';
    } else if (tab.title == 'Result') {
      return '/result';
    } else if (tab.eventTypeId != null) {
      return '/sport/${tab.eventTypeId}/${tab.title}';
    }

    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = Get.find<GlobalSearchController>();

    _onRouteChanged();
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
            child: BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
              builder: (context, scs) {
                tabMenus = [...staticTabs];
                if (scs is FetchSportsCategorySuccess) {
                  tabMenus.addAll(scs.categoryResponse.data.map((item) => TabItem(title: item.name, count: item.count, eventTypeId: item.id)));
                  tabMenus.add(TabItem(title: winnerScreenType, eventTypeId: "1"));
                  if (widget.userLoggedinSaveData != null) {
                    tabMenus.add(const TabItem(title: 'Casino'));
                    tabMenus.add(const TabItem(title: 'Result'));
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (isRouteChanged == false) {
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
                      flexibleSpace: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(gradient: bottomBarGradient),
                            child: Column(
                              children: [
                                DesktopAppbarLogin(action: () => setState(() => isMyAccount = true)),
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
                                                    if (tab.title.toLowerCase() == 'casino') {
                                                      betRadarViewTabMenu(context);
                                                      return;
                                                    }
                                                    setState(() {
                                                      selectedTab = tab.title;
                                                      selectedSportId = tab.eventTypeId;
                                                      isMyAccount = false;
                                                    });
                                                    _disconnectAllEvents();
                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                      context.go(getRouteForTab(tab));
                                                    });
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
                          if (showSearchBar)
                            Positioned(
                              top: 10,
                              right: 30,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 320,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: searchController,
                                          focusNode: searchFocusNode,
                                          style: const TextStyle(color: black),
                                          decoration: const InputDecoration(
                                            hintText: 'Find...',
                                            hintStyle: TextStyle(color: black),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: searchCtrl.updateQuery,
                                          onSubmitted: (_) {
                                            searchCtrl.nextMatch();
                                            searchFocusNode.requestFocus();
                                          },
                                        ),
                                      ),
                                      Obx(() {
                                        final total = searchCtrl.matchCount.value;
                                        final current = searchCtrl.currentIndex.value;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: HighlightText(total == 0 ? '0/0' : '${current + 1}/$total', style: const TextStyle(fontSize: 12, color: black)),
                                        );
                                      }),
                                      Obx(() {
                                        final hasMatches = searchCtrl.matchCount.value > 0;
                                        return InkWell(
                                          onTap: hasMatches ? searchCtrl.previousMatch : null,
                                          child: Icon(Icons.keyboard_arrow_up, color: hasMatches ? black : grey),
                                        );
                                      }),
                                      Obx(() {
                                        final hasMatches = searchCtrl.matchCount.value > 0;
                                        return InkWell(
                                          onTap: hasMatches ? searchCtrl.nextMatch : null,
                                          child: Icon(Icons.keyboard_arrow_down, color: hasMatches ? black : grey),
                                        );
                                      }),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            showSearchBar = false;
                                            searchController.clear();
                                          });
                                          searchCtrl.clear();
                                        },
                                        child: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  body: SafeArea(
                    child: SelectionArea(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const MarqueeNews(),
                                Expanded(child: isMyAccount && widget.userLoggedinSaveData != null ? const MyAccountMenu() : widget.child),
                              ],
                            ),
                          ),
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
      ),
    );
  }
}
