import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/authBlocs/user_auth_change_bloc.dart';
import '../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_wl_details_bloc.dart';
import '../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../blocs/signalRBloc/subscribe_scoring_signalr_bloc.dart';
import '../demo/presentation/demo_bloc_scope.dart';
import '../demo/presentation/demo_my_account_menu.dart';
import '../demo/presentation/demo_shells.dart';
import '../demo/routing/demo_route_mapper.dart';
import '../demo/routing/demo_route_navigation_helper.dart';
import '../demo/routing/demo_routes.dart';
import '../reusables/loader.dart';
import '../reusables/responsive.dart';
import '../reusables/snack_bar.dart';
import '../screens/deskopView/multiMarketView/multi_market_streamer.dart';
import '../services/under_maintenance_screen.dart';
import '../screens/deskopView/homeView/app_download_popup.dart';
import '../screens/deskopView/homeView/home_screen.dart';
import '../screens/deskopView/mainTabView/desktop_main_view.dart';
import '../screens/deskopView/myAccountView/myAccountMenu/my_account_menu.dart';
import '../screens/deskopView/newSportsView/new_inplay_screen.dart';
import '../screens/deskopView/newSportsView/new_inplay_tab_view.dart';
import '../screens/deskopView/newSportsView/new_inplay_today_screen.dart';
import '../screens/deskopView/newSportsView/new_inplay_tomorrow_screen.dart';
import '../screens/deskopView/newSportsView/new_sports_view_screen.dart';
import '../screens/deskopView/resultsView/resuls_tab.dart';
import '../screens/mobileScreens/inPlayScreen/mv_in_play_screen.dart';
import '../screens/mobileScreens/inPlayScreen/results/result_screen.dart';
import '../screens/mobileScreens/mobile_main_view.dart';
import '../screens/mobileScreens/mvAccounts/mv_mobile_account_menu.dart';
import '../screens/mobileScreens/mvAccounts/mv_new_account_menu.dart';
import '../screens/mobileScreens/mvEventScreen/mv_event_screen.dart';
import '../screens/mobileScreens/mvHome/mv_home_screen.dart';
import '../screens/mobileScreens/mvMultiMarket/mv_multi_market_screen.dart';
import '../screens/mobileScreens/sportScreen/mv_sport_screen.dart';
import 'app_routes_constants.dart';
import 'route_navigation_helper.dart';

bool isRefreshed = true;
String prevRoute = "";

GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  navigatorKey: navigatorKey,
  errorBuilder: (context, state) {
    Future.microtask(() {
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    });

    return LoaderWithScaffold(message: 'Redirecting to dashboard.');
  },
  redirect: (context, state) {
    final location = state.uri.path;
    final wlState = context.read<FetchWlDetailsBloc>().state;
    final isMaintenance = wlState is FetchWlDetailsSuccess && wlState.appData.inMaintenance && kReleaseMode;
    final isMaintenanceRoute = location == AppRoutes.maintenance;
    if (isMaintenance && !isMaintenanceRoute) {
      return AppRoutes.maintenance;
    }
    if (!isMaintenance && isMaintenanceRoute) {
      return AppRoutes.home;
    }
    final demoRedirect = DemoRouteMapper.redirectToDemoIfNeeded(location);
    if (demoRedirect != null) return demoRedirect;
    if (location.startsWith(DemoRoutes.base)) return null;

    final authState = context.read<UserAuthChangesBloc>().state;

    return GoToRoute().defaultRedirectOnUnauthorized(location, authState);
  },
  routes: [
    GoRoute(path: AppRoutes.maintenance, builder: (context, state) => const UnderMaintenanceScreen()),
    GoRoute(path: '/download-app', builder: (context, state) => const AppDownloadPage()),
    ShellRoute(
      builder: (context, state, child) {
        return DemoBlocScope(
          child: responsiveBuilder(
            context: context,
            mobile: DemoMVMainView(child: child),
            desktop: DemoDesktopMainTab(child: child),
          ),
        );
      },
      routes: [
        GoRoute(
          path: DemoRoutes.home,
          builder: (context, state) => responsiveBuilder(context: context, mobile: MvHomeScreen(), desktop: const HomeScreen()),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return responsiveBuilder(
              context: context,
              mobile: MVInPlayScreenPage(key: Key('DemoKey_${DateTime.now().millisecond}')),
              desktop: NewInplayTabView(child: child),
            );
          },
          routes: [
            GoRoute(
              path: DemoRoutes.inplay,
              builder: (context, state) => responsiveBuilder(
                context: context,
                mobile: MVInPlayScreenPage(key: Key('DemoKey_${DateTime.now().millisecond}')),
                desktop: const NewInplayScreen(),
              ),
            ),
            GoRoute(
              path: DemoRoutes.inplayToday,
              builder: (context, state) => responsiveBuilder(
                context: context,
                mobile: MVInPlayScreenPage(key: Key('DemoKey_${DateTime.now().millisecond}')),
                desktop: const NewTodayStreamer(),
              ),
            ),
            GoRoute(
              path: DemoRoutes.inplayTomorrow,
              builder: (context, state) => responsiveBuilder(
                context: context,
                mobile: MVInPlayScreenPage(key: Key('DemoKey_${DateTime.now().millisecond}')),
                desktop: const NewTomorrowStreamer(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: DemoRoutes.multimarkets,
          builder: (context, state) => responsiveBuilder(context: context, mobile: MVMultiMarketsCard(), desktop: const MultiMarketViewStreamer()),
        ),
        GoRoute(
          path: DemoRoutes.sport,
          builder: (context, state) {
            final sportId = state.pathParameters['sportId']!;
            final screenType = state.pathParameters['screenType']!;
            if (Responsive.isMobile(context)) {
              disconnectPrevSignalRConnection(null, context);
              if (screenType.toLowerCase().contains('fifa') && screenType.toLowerCase().contains('winner')) {
                context.replace(DemoGoToRoute.sportEvent(sportId: sportId, name: screenType, eventId: winnerEventId, inPlay: false, premium: false));
              }
              return MVSportScreen(name: screenType, sportId: sportId, key: Key('demo_sport_$screenType$sportId'));
            }
            context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEventsSetToInit());
            context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sportId));
            prevRoute = state.matchedLocation;
            return NewSportsStreamer(sid: sportId, screenType: screenType, initialEventId: state.matchedLocation.toLowerCase().contains('fifa') ? winnerEventId : null);
          },
        ),
        GoRoute(
          path: DemoRoutes.sportEvent,
          builder: (context, state) {
            final sportId = state.pathParameters['sportId']!;
            final eventId = state.pathParameters['eventId']!;
            final inPlay = state.pathParameters['inplay']!;
            final premium = state.pathParameters['premium']!;
            final fancyMarket = state.pathParameters['fancyMarket']!;
            final screenType = state.pathParameters['screenType']!;
            if (Responsive.isMobile(context)) {
              disconnectPrevSignalRConnection(eventId, context);
              if (screenType.toLowerCase().contains('fifa') && screenType.toLowerCase().contains('winner')) {
                context.replace(GoToRoute.sportEvent(sportId: sportId, name: screenType, eventId: winnerEventId, inPlay: false, premium: false));
              }
              context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: eventId));
              return EventsBetScreen(
                eventId: eventId,
                eventTypeTitle: screenType,
                inplay: inPlay == 'true',
                sid: sportId,
                premiumMatch: premium == 'true',
                fancyMarket: fancyMarket == 'true',
              );
            }
            if (screenType.toLowerCase().contains('fifa') && screenType.toLowerCase().contains('winner')) {
              context.replace(DemoGoToRoute.sport(sportId: sportId, name: screenType));
            }
            if (isRefreshed) {
              context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sportId));
            }
            prevRoute = state.matchedLocation;
            return NewSportsStreamer(sid: sportId, screenType: screenType, initialEventId: state.matchedLocation.toLowerCase().contains('fifa') ? winnerEventId : null);
          },
        ),
        GoRoute(
          path: DemoRoutes.result,
          builder: (context, state) => responsiveBuilder(context: context, mobile: ResultScreen(), desktop: ResultsTabView()),
        ),
        GoRoute(
          path: DemoRoutes.resultTab,
          builder: (context, state) {
            final tab = state.pathParameters['tab']!;
            return responsiveBuilder(
              context: context,
              mobile: ResultScreen(),
              desktop: ResultsTabView(initialTab: tab),
            );
          },
        ),
        GoRoute(
          path: DemoRoutes.account,
          redirect: (context, __) => Responsive.isMobile(context) ? null : DemoGoToRoute.account('my-profile'),
          builder: (context, state) => MobileAccountMenu(),
        ),
        GoRoute(
          path: DemoRoutes.accountSection,
          builder: (context, state) => responsiveBuilder(context: context, mobile: MVNewMyAccountMenu(), desktop: const DemoMyAccountMenu()),
        ),
        GoRoute(
          path: DemoRoutes.accountMyBets,
          builder: (context, state) {
            final tab = state.pathParameters['tab']!;
            return responsiveBuilder(
              context: context,
              mobile: MVNewMyAccountMenu(initialMenu: 'My Bets', subMenu: tab),
              desktop: DemoMyAccountMenu(initialMenu: 'My Bets', subMenu: tab),
            );
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        return responsiveBuilder(
          context: context,
          mobile: MVMainView(child: child),
          desktop: DesktopMainTab(child: child),
        );
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => AppRoutes.home),

        // Home
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => responsiveBuilder(context: context, mobile: MvHomeScreen(), desktop: const HomeScreen()),
        ),

        //Routing for Inplay
        ShellRoute(
          builder: (context, state, child) {
            return responsiveBuilder(
              context: context,
              mobile: MVInPlayScreenPage(key: Key("Key_${DateTime.now().millisecond}")),
              desktop: NewInplayTabView(child: child),
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.inplay,
              builder: (context, state) {
                return responsiveBuilder(
                  context: context,
                  mobile: MVInPlayScreenPage(key: Key("Key_${DateTime.now().millisecond}")),
                  desktop: const NewInplayScreen(),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.inplayToday,
              builder: (context, state) {
                return responsiveBuilder(
                  context: context,
                  mobile: MVInPlayScreenPage(key: Key("Key_${DateTime.now().millisecond}")),
                  desktop: const NewTodayStreamer(),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.inplayTomorrow,
              builder: (context, state) {
                return responsiveBuilder(
                  context: context,
                  mobile: MVInPlayScreenPage(key: Key("Key_${DateTime.now().millisecond}")),
                  desktop: const NewTomorrowStreamer(),
                );
              },
            ),
          ],
        ),

        //Routing for multimarkets
        GoRoute(
          path: AppRoutes.multimarkets,
          builder: (context, state) {
            return responsiveBuilder(context: context, mobile: MVMultiMarketsCard(), desktop: const MultiMarketViewStreamer());
          },
        ),

        //Routing for Sports
        GoRoute(
          path: AppRoutes.sport,
          builder: (context, state) {
            final sportId = state.pathParameters['sportId']!;
            final screenType = state.pathParameters['screenType']!;
            if (Responsive.isMobile(context)) {
              disconnectPrevSignalRConnection(null, context);
              if (screenType.toLowerCase().contains('fifa') && screenType.toLowerCase().contains('winner')) {
                context.replace(GoToRoute.sportEvent(sportId: sportId, name: screenType, eventId: winnerEventId, inPlay: false, premium: false));
              }
              return MVSportScreen(name: screenType, sportId: sportId, key: Key('sport_$screenType$sportId'));
            } else {
              if (!prevRoute.contains('event') && !prevRoute.toLowerCase().contains(sportId.toString()) && !prevRoute.toLowerCase().contains(screenType.toString())) {
                context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEventsSetToInit());
                context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sportId));
              } else {
                context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEventsSetToInit());
                context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sportId));
              }
              prevRoute = state.matchedLocation;
              return NewSportsStreamer(sid: sportId, screenType: screenType, initialEventId: state.matchedLocation.toLowerCase().contains('fifa') ? winnerEventId : null);
            }
          },
        ),

        GoRoute(
          path: AppRoutes.sportEvent,
          builder: (context, state) {
            final sportId = state.pathParameters['sportId']!;
            final eventId = state.pathParameters['eventId']!;
            final inPlay = state.pathParameters['inplay']!;
            final premium = state.pathParameters['premium']!;
            final fancyMarket = state.pathParameters['fancyMarket']!;
            final screenType = state.pathParameters['screenType']!;
            if (Responsive.isMobile(context)) {
              disconnectPrevSignalRConnection(eventId, context);
              context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: eventId));
              return EventsBetScreen(
                eventId: eventId,
                eventTypeTitle: screenType,
                inplay: inPlay == 'true',
                sid: sportId,
                premiumMatch: premium == 'true',
                fancyMarket: fancyMarket == 'true',
              );
            } else {
              if (screenType.toLowerCase().contains('fifa') && screenType.toLowerCase().contains('winner')) {
                context.replace(GoToRoute.sport(sportId: sportId, name: screenType));
              }
              final prevRouteSplit = prevRoute.split('/');
              final currentRouteSplit = state.matchedLocation.split('/');
              String prevEvent = '';
              if (prevRouteSplit.length > 4) {
                prevEvent = prevRouteSplit[5];
              }
              String currentEvent = '';
              if (currentRouteSplit.length > 4) {
                currentEvent = currentRouteSplit[5];
              }
              if (isRefreshed || (prevEvent != '' && prevEvent.isNotEmpty && prevEvent != currentEvent)) {
                context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sportId));
              }
              prevRoute = state.matchedLocation;
              return NewSportsStreamer(screenType: screenType, sid: sportId, initialEventId: eventId);
            }
          },
        ),

        // Result routing
        GoRoute(
          path: AppRoutes.result,
          builder: (context, state) => responsiveBuilder(context: context, mobile: ResultScreen(), desktop: ResultsTabView()),
        ),
        GoRoute(
          path: AppRoutes.resultTab,
          builder: (context, state) {
            final tab = state.pathParameters['tab']!;
            return responsiveBuilder(
              context: context,
              mobile: ResultScreen(),
              desktop: ResultsTabView(initialTab: tab),
            );
          },
        ),

        //account routing
        GoRoute(
          path: AppRoutes.account,
          redirect: (context, __) => Responsive.isMobile(context) ? AppRoutes.account : '${AppRoutes.account}/my-profile',
          builder: (context, state) {
            return MobileAccountMenu();
          },
        ),
        GoRoute(
          path: AppRoutes.accountSection,
          builder: (context, state) {
            return responsiveBuilder(context: context, mobile: MVNewMyAccountMenu(), desktop: MyAccountMenu());
          },
        ),
        GoRoute(
          path: AppRoutes.accountMyBets,
          builder: (context, state) {
            final tab = state.pathParameters['tab']!;
            return responsiveBuilder(
              context: context,
              mobile: MVNewMyAccountMenu(initialMenu: 'My Bets', subMenu: tab),
              desktop: MyAccountMenu(initialMenu: 'My Bets', subMenu: tab),
            );
          },
        ),
      ],
    ),
  ],
);

void disconnectPrevSignalRConnection(String? eventId, BuildContext context) {
  if (subscribedEventId != null && subscribedEventId != eventId) {
    context.read<SignalREventListenerBloc>().add(SignalREventDisconnect(eventId: subscribedEventId ?? '0'));
    context.read<JoinMatchSignalRBloc>().add(DisconnectScoringSignalR(eventId: int.tryParse(subscribedEventId ?? '0') ?? 0));
    context.read<FetchBookMakerBloc>().add(SetToInitialBM());
    context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
    context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
    context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
    context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
    context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
    subscribedEventId = null;
  }
}
