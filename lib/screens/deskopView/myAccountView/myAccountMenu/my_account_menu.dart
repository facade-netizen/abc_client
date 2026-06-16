import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../routing/app_routes_constants.dart';
import '../../../../routing/route_navigation_helper.dart';
import '../../../../services/web_new_tab_service.dart';
import '../../sportsReusables/sports_header.dart';
import '../myBetsNew/my_bets_tab.dart';
import 'my_account_menu_tile.dart';

class MyAccountMenu extends StatefulWidget {
  const MyAccountMenu({
    super.key,
    this.initialMenu,
    this.subMenu,
  });

  final String? initialMenu;
  final String? subMenu;

  @override
  State<MyAccountMenu> createState() => _MyAccountMenuState();
}

class _MyAccountMenuState extends State<MyAccountMenu> {
  String selectedMenu = '';

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    /// Extract menu from URL
    String selectedMenu = '';
    String subMenu = '';

    if (location.startsWith('${AppRoutes.account}/')) {
      final parts = location.split('/');
      if (parts.length >= 3) {
        selectedMenu = parts[2];
      }

      if (parts.length >= 4) {
        subMenu = parts[3];
      }
      selectedMenu = selectedMenu.replaceAll('-', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
    }

    return Row(
      children: [
        /// LEFT MENU
        Expanded(
          flex: 2,
          child: SportsEventMenu(
            title: "My Account",
            itemCount: accountMenu.length,
            itemBuilder: (context, index) {
              final menu = accountMenu[index];
              return RightClickWrapper(
                route: GoToRoute.account(menu.toLowerCase().replaceAll(' ', '-')),
                child: MyAccountMenuTile(
                  menu: menu,
                  selectedMenu: selectedMenu,
                  action: () {
                    final route = menu.toLowerCase().replaceAll(' ', '-');
                    context.go(GoToRoute.account(route));
                  },
                ),
              );
            },
          ),
        ),

        /// RIGHT CONTENT
        Expanded(
          flex: 8,
          child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
            builder: (context, fud) {
              final currentUser = fud is FetchUserAccountDetailsSuccess ? fud.userDetails : null;
              return Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 8),
                child: selectedMenu == 'My Bets'
                    ? MyBetsTab(
                        currentUser: currentUser,
                        initialTab: routeToTab(subMenu.isNotEmpty ? subMenu : 'current-bets'),
                      )
                    : accountMenuScreens(currentUser)[selectedMenu] ?? const Center(child: Text("Page not found")),
              );
            },
          ),
        ),
      ],
    );
  }
}
