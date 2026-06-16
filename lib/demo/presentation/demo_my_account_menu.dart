import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../screens/deskopView/myAccountView/myAccountMenu/my_account_menu_tile.dart';
import '../../screens/deskopView/myAccountView/myBetsNew/my_bets_tab.dart';
import '../../screens/deskopView/sportsReusables/sports_header.dart';
import '../../services/web_new_tab_service.dart';
import '../routing/demo_route_navigation_helper.dart';
import '../routing/demo_routes.dart';

class DemoMyAccountMenu extends StatelessWidget {
  const DemoMyAccountMenu({super.key, this.initialMenu, this.subMenu});

  final String? initialMenu;
  final String? subMenu;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    var selectedMenu = initialMenu ?? 'My Profile';
    var selectedSubMenu = subMenu ?? '';

    if (location.startsWith('${DemoRoutes.account}/')) {
      final parts = location.split('/');
      if (parts.length >= 4) selectedMenu = _title(parts[3]);
      if (parts.length >= 5) selectedSubMenu = parts[4];
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SportsEventMenu(
            title: 'My Account',
            itemCount: accountMenu.length,
            itemBuilder: (context, index) {
              final menu = accountMenu[index];
              final route = menu.toLowerCase().replaceAll(' ', '-');
              return RightClickWrapper(
                route: DemoGoToRoute.account(route),
                child: MyAccountMenuTile(menu: menu, selectedMenu: selectedMenu, action: () => context.go(DemoGoToRoute.account(route))),
              );
            },
          ),
        ),
        Expanded(
          flex: 8,
          child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
            builder: (context, state) {
              final currentUser = state is FetchUserAccountDetailsSuccess ? state.userDetails : null;
              return Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 8),
                child: selectedMenu == 'My Bets'
                    ? MyBetsTab(currentUser: currentUser, initialTab: routeToTab(selectedSubMenu.isNotEmpty ? selectedSubMenu : 'current-bets'))
                    : accountMenuScreens(currentUser)[selectedMenu] ?? const Center(child: Text('Page not found')),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _title(String slug) => slug.replaceAll('-', ' ').split(' ').where((word) => word.isNotEmpty).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}
