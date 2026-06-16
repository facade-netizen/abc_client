import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../models/user_details_model.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../deskopView/myAccountView/myAccountMenu/my_account_menu_tile.dart';
import '../../deskopView/myAccountView/myBetsNew/my_bets_tab.dart';
import '../../deskopView/sportsReusables/sports_header.dart';

class MVNewMyAccountMenu extends StatefulWidget {
  const MVNewMyAccountMenu({super.key, this.initialMenu, this.subMenu});

  final String? initialMenu;
  final String? subMenu;

  @override
  State<MVNewMyAccountMenu> createState() => _MVNewMyAccountMenuState();
}

class _MVNewMyAccountMenuState extends State<MVNewMyAccountMenu> {
  String selectedMenu = '';

  String getActiveMenu(BuildContext context) {
    final params = GoRouter.of(context).state.pathParameters;
    final section = params['section'];

    if (section == null) {
      if (widget.initialMenu != null) {
        return widget.initialMenu!;
      }
      return accountMenu.first;
    }

    return accountMenu.firstWhere((menu) => menu.toLowerCase().replaceAll(' ', '-') == section, orElse: () => accountMenu.first);
  }

  @override
  Widget build(BuildContext context) {
    final activeMenu = getActiveMenu(context);

    Widget buildMenuPanel() {
      return SportsEventMenu(
        title: "My Account",
        itemCount: accountMenu.length,
        itemBuilder: (context, index) {
          final menu = accountMenu[index];
          return MyAccountMenuTile(
            menu: menu,
            selectedMenu: activeMenu,
            action: () {
              if (activeMenu != menu) {
                final section = menu.toLowerCase().replaceAll(' ', '-');
                context.go(GoToRoute.account(section));
              }
            },
          );
        },
      );
    }

    Widget buildContentPanel(UserAccountDetails? currentUser) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 0, bottom: 8),
        child: activeMenu.toLowerCase().contains('bets')
            ? MyBetsTab(currentUser: currentUser, initialTab: routeToTab(widget.subMenu != null && widget.subMenu!.isNotEmpty ? widget.subMenu! : 'current-bets'))
            : accountMenuScreens(currentUser)[activeMenu] ?? const SizedBox(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = (constraints.maxWidth / 1400).clamp(0.28, 1.0);

        return InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.28,
          maxScale: 2.2,
          panEnabled: true,
          scaleEnabled: true,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: 1200,
                maxWidth: 1200,
                minHeight: constraints.maxHeight / scale,
                maxHeight: constraints.maxHeight / scale,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 1200,
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: buildMenuPanel()),
                        Expanded(
                          flex: 8,
                          child: BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
                            builder: (context, fud) {
                              final currentUser = fud is FetchUserAccountDetailsSuccess ? fud.userDetails : null;
                              return buildContentPanel(currentUser);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
