import 'dart:developer';

import '../blocs/authBlocs/user_auth_change_bloc.dart';
import 'app_routes_constants.dart';

class GoToRoute {
  //SPORT
  static String sport({required String sportId, required String name}) => '/sport/$sportId/$name';
  static String sportEvent({required String sportId, required String name, required String eventId, required bool inPlay, required bool premium, bool? fancyMarket}) =>
      '/sport/$sportId/$name/event/$eventId/$inPlay/$premium/${fancyMarket ?? false}';

  //RESULT
  static String result([String? tab]) => tab == null ? '/result' : '/result/$tab';
  //INPLAY
  static String inplay({String? type}) {
    if (type == 'today') return '/inplay/today';
    if (type == 'tomorrow') return '/inplay/tomorrow';
    return '/inplay';
  }

  //ACCOUNT
  static String account([String? section]) => section == null ? '/account' : '/account/$section';
  static String accountMyBets(String tab) => '/account/my-bets/$tab';

  //MULTI MARKETS
  static String multimarkets() => '/multimarkets';

  String? defaultRedirectOnUnauthorized(String location, UserAuthChangesState authState) {
    if (['/', AppRoutes.home].contains(location) || location.startsWith(AppRoutes.inplay) || location.startsWith(AppRoutes.sport) || location.startsWith(AppRoutes.multimarkets)) {
      return null;
    }

    if (authState is UserAuthChangesInitial || authState is UserAuthChangesProgress) {
      return null;
    }

    final isLoggedIn = authState is UserAuthChangesSuccess && authState.savedUserAuth != null;

    final isProtectedRoute = location.startsWith(AppRoutes.account) || location.startsWith(AppRoutes.result);

    if (!isLoggedIn && isProtectedRoute) {
      log('User not logged in. Redirecting from $location to /home');
      return AppRoutes.home;
    }

    return null;
  }
}
