import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../blocs/addBloc/update_onclick_bet_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../../blocs/authBlocs/user_logout_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../../../../blocs/miscBlocs/change_main_menu_index.dart';
import '../../../../blocs/miscBlocs/change_page_index.dart' as page_index;
import '../../../../blocs/miscBlocs/sports_left_panel_bloc.dart';
import '../../../../blocs/miscBlocs/sports_session_connect_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../../reusables/snack_bar.dart';
import '../../../../reusables/style.dart';
import '../../../../routing/app_routes_constants.dart';
import '../../../../services/web_new_tab_service.dart';
import '../../sportsReusables/custom_cta_button.dart';
import 'main_balance_overlay.dart';

class MyAccountOverlay extends StatefulWidget {
  const MyAccountOverlay({super.key, required this.action});
  final Function()? action;

  @override
  State<MyAccountOverlay> createState() => _MyAccountOverlayState();
}

class _MyAccountOverlayState extends State<MyAccountOverlay> {
  ///
  String selectedMenu = '';

  ///
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  int isHovered = -1;
  final GlobalKey filterKey = GlobalKey();

  void _resetBlocsOnLogout() {
    context.read<FetchFavStakeBloc>().add(SetToInitialFetchFavStake());
    context.read<UserLoginBloc>().add(SetLoginToInitial());

    // Reset navigation and local UI selections.
    context.read<ChangeMainTabViewBloc>().add(ChangePageSetToInit());
    context.read<page_index.ChangePageViewBloc>().add(page_index.ChangePageSetToInit());
    context.read<SportsLeftPanelBloc>().add(ResetSportsPanel());

    // Reset market/data blocs.
    context.read<FetchBookMakerBloc>().add(SetToInitialBM());
    context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
    context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
    context.read<FetchScoreBoardBloc>().add(SetToInitialFetchScoreBoard());

    // Reset realtime stream blocs.
    context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
    context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
    context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
    context.read<SignalRAccountDataBloc>().add(SetToInitialSignalRAccount());
    context.read<SignalRMessageBloc>().add(SetToInitialSignalRMessage());
    context.read<BmProfitLossBloc>().add(SetToInitialBmProfitLoss());
    context.read<OddsProfitLossBloc>().add(SetToInitialOddsProfitLoss());
    context.read<FancyProfitLossBloc>().add(SetToInitialFancyProfitLoss());
  }

  ///
  void toggleAccountMenu() {
    RightClickService.hide();
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);
    RenderBox renderBox = filterKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            toggleAccountMenu();
          },
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height,
                width: obw + 50,
                child: CompositedTransformFollower(
                  link: layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(-42, size.height + 5),
                  child: Material(
                    elevation: 5,
                    color: white,
                    borderRadius: BorderRadius.circular(10),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BlocBuilder<FetchUserAccountDetailsBloc, FetchUserAccountDetailsState>(
                              builder: (context, fud) {
                                String userName = "Demo Client";
                                String timezone = '';

                                if (fud is FetchUserAccountDetailsSuccess) {
                                  userName = fud.userDetails.userName;

                                  final fullTimezone = fud.userDetails.users.first.timezone;
                                  final match = RegExp(r'\((GMT[^\)]+)\)$').firstMatch(fullTimezone);

                                  timezone = match != null ? match.group(1)! : '';
                                }

                                return Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: darkGreen)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(
                                            userName,
                                            style: b13ts(color: darkGreen).copyWith(overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(width: 0.5, color: darkGreen),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 3),
                                        child: Text(timezone, style: n12ts),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: accountOverlayMenu.length * 32,
                              child: ListView.builder(
                                itemCount: accountOverlayMenu.length,
                                itemBuilder: (context, index) {
                                  final menu = accountOverlayMenu[index];
                                  return RightClickWrapper(
                                    route: '${AppRoutes.account}/${menu.toLowerCase().replaceAll(' ', '-')}',
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => isHovered = index),
                                      onExit: (_) => setState(() => isHovered = -1),
                                      child: InkWell(
                                        onTap: () {
                                          if (selectedMenu != menu) {
                                            setState(() {
                                              selectedMenu = menu;
                                            });
                                            final route = selectedMenu.toLowerCase().replaceAll(' ', '-');
                                            context.go('${AppRoutes.account}/$route');
                                          }
                                          widget.action!();
                                          toggleAccountMenu();
                                        },
                                        child: Container(
                                          width: obw,
                                          decoration: BoxDecoration(
                                            color: isHovered == index ? Colors.grey.shade100 : white,
                                            border: Border(bottom: BorderSide(color: grey, width: 0.5)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(menu, style: n12ts),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            BlocConsumer<UserLogoutBloc, UserLogoutState>(
                              listener: (context, uls) {
                                if (uls is UserLogoutSuccess) {
                                  _resetBlocsOnLogout();
                                  context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
                                  sportsSessionConnect(ctxt: context, type: SessionType.disconnect, eventId: "0");
                                  context.read<ChangeMainTabViewBloc>().add(ChangeMainTabView(menu: {"menu": 'Home'}));
                                  showSnackBar(context, "You have been logged out successfully");
                                }
                              },
                              builder: (context, uls) {
                                return CustomCTAButton(
                                  width: obw + 50,
                                  gradientColor: mvEventHeader,
                                  icon: Icons.logout,
                                  color: white,
                                  title: "LOGOUT",
                                  action: () {
                                    context.go(AppRoutes.home);
                                    context.read<UpdateOnclickBetBloc>().add(UpdateOnclickBet(type: 1, isClicked: false));
                                    context.read<UserLoginBloc>().add(SetLoginToInitial());
                                    context.read<UserLogoutBloc>().add(UserLogoutListener());
                                  },
                                );
                              },
                            ),
                            hb10,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    overlay.insert(overlayEntry!);
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: AppBarCTAButton(
        key: filterKey,
        width: obw,
        leading: Icon(Icons.person, size: 20, color: appBarText),
        color: appBarText,
        traling: Icon(Icons.arrow_drop_down, size: 20, color: appBarText),
        title: "My Account",
        action: () {
          toggleAccountMenu();
        },
      ),
    );
  }
}

double obw = 170;
List<String> accountOverlayMenu = ["My Profile", "Balance Overview", "Account Statement", "My Bets", "Bets History", "Profit & Loss", "Activity Log"];
