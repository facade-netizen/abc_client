import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as html;

import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/authBlocs/user_login_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_all_events_for_search_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../constants/app_string_constants.dart';
import '../../../demo/bootstrap/demo_bootstrap.dart';
import '../../../models/event_search_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/formatters.dart';
import '../../../reusables/open_url.dart';
import '../../../reusables/regexes.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../reusables/snack_bar.dart';
import '../../../routing/app_router.dart';
import '../../../routing/app_routes_constants.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/navigators.dart';
import '../authView/desktop_password_reset_screen.dart';
import '../myAccountView/myAccountMenu/main_balance_overlay.dart';
import '../myAccountView/myAccountMenu/my_account_overlay.dart';
import '../newSportsView/new_inplay_today_screen.dart';
import '../sportsReusables/custom_cta_button.dart';
import 'login_text_form_field.dart';

class DesktopAppbarLogin extends StatefulWidget {
  const DesktopAppbarLogin({super.key, this.action});
  final Function()? action;

  @override
  State<DesktopAppbarLogin> createState() => _DesktopAppbarLoginState();
}

class _DesktopAppbarLoginState extends State<DesktopAppbarLogin> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController validationCodeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;

  List<SearchEvent> allEvents = [];
  List<SearchEvent> searchResults = [];
  bool showSearchResults = false;

  Timer? codeTimer;
  String validationCode = "";
  String? formError;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
    generateNewCode();
    codeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      generateNewCode();
    });
  }

  void generateNewCode() {
    final random = Random();
    setState(() {
      validationCode = (1000 + random.nextInt(9000)).toString();
    });
  }

  @override
  void dispose() {
    _removeSearchOverlay();
    codeTimer?.cancel();
    userNameController.dispose();
    passwordController.dispose();
    validationCodeController.dispose();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void handleLogin(BuildContext context) {
    setState(() {
      formError = null;
    });

    if (userNameController.text.trim().isEmpty) {
      setState(() => formError = "Username is required");
      generateNewCode();
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() => formError = "Password is required");
      generateNewCode();
      return;
    }

    if (validationCodeController.text.isEmpty) {
      setState(() => formError = "Validation code is required");
      generateNewCode();
      return;
    }

    if (validationCodeController.text != validationCode) {
      setState(() => formError = "Invalid validation code");
      generateNewCode();
      return;
    }

    context.read<UserLoginBloc>().add(UserLogin(username: userNameController.text.trim(), password: passwordController.text));
  }

  void _showSearchOverlay() {
    if (_searchOverlayEntry != null) {
      _searchOverlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    _searchOverlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    showSearchResults = false;
                  });
                  _removeSearchOverlay();
                },
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _searchLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(4, 40),
              child: Material(color: Colors.transparent, child: _buildSearchResults()),
            ),
          ],
        );
      },
    );
    overlay.insert(_searchOverlayEntry!);
  }

  void _removeSearchOverlay() {
    _searchOverlayEntry?.remove();
    searchController.clear();
    _searchOverlayEntry = null;
  }

  void _updateSearchOverlay() {
    if (showSearchResults) {
      _showSearchOverlay();
    } else {
      _removeSearchOverlay();
    }
  }

  void handleSearch(String query) {
    final searchText = query.trim();
    if (searchText.isEmpty) {
      setState(() {
        showSearchResults = false;
        searchResults = [];
      });
      _removeSearchOverlay();
      return;
    }

    final lowerSearch = searchText.toLowerCase();
    final filtered = allEvents.where((event) {
      return event.name.toLowerCase().contains(lowerSearch) || event.competition.toLowerCase().contains(lowerSearch) || event.venue.toLowerCase().contains(lowerSearch);
    }).toList();

    setState(() {
      searchResults = filtered;
      showSearchResults = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSearchOverlay());
  }

  void _openSportTabForEvent({required String sid, required SearchEvent event}) {
    subscribedSingleTodayEventId = event.id;
    isRefreshed = false;
    context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sid));
    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: event.id));
    context.go(
      GoToRoute.sportEvent(
        sportId: sid,
        name: event.sid == "4"
            ? "Cricket"
            : event.sid == "1"
            ? "Soccer"
            : "Tennis",
        eventId: event.id,
        inPlay: event.inPlay,
        premium: event.premiumMatch,
        fancyMarket: event.fancyMarket,
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      width: 241,
      height: 200,
      decoration: BoxDecoration(
        color: white,
        boxShadow: [BoxShadow(color: black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: searchResults.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No events found', style: TextStyle(fontSize: 13, color: black)),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: searchResults.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.3)),
              itemBuilder: (context, index) {
                final event = searchResults[index];
                return SearchResultItem(
                  event: event,
                  onTap: () {
                    _removeSearchOverlay();
                    _openSportTabForEvent(sid: event.sid, event: event);
                  },
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchAllEventsForSearchBloc, FetchAllEventsForSearchState>(
      listener: (context, state) {
        if (state is FetchAllEventsForSearchSuccess) {
          final query = searchController.text.trim();
          final lowerQuery = query.toLowerCase();
          final filtered = query.isEmpty
              ? <SearchEvent>[]
              : state.events.where((event) {
                  return event.name.toLowerCase().contains(lowerQuery) || event.competition.toLowerCase().contains(lowerQuery) || event.venue.toLowerCase().contains(lowerQuery);
                }).toList();

          setState(() {
            allEvents = state.events;
            searchResults = filtered;
            showSearchResults = query.isNotEmpty;
          });
        }
      },
      child: BlocConsumer<UserLoginBloc, UserLoginState>(
        listener: (context, uls) {
          if (uls is UserLoginFailure) {
            setState(() {
              formError = uls.error;
            });
            generateNewCode();
            showSnackBar(context, uls.error, error: true);
          }

          if (uls is UserLoginSuccess) {
            context.read<FetchFavStakeBloc>().add(FetchFavStake());
            context.go(AppRoutes.home);
            context.read<UserAuthChangesBloc>().add(StartUserChangeListener());
          }
          if (uls is UserLoginResetPasswordRequiredSuccess) {
            pushSimple(context, DesktopPasswordResetScreen(userName: uls.userName));
          }
        },
        builder: (context, uls) {
          return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
            builder: (context, ucs) {
              bool isLoading = uls is UserLoginProgress;
              bool isSuccess = uls is UserLoginSuccess;
              final isLoggedIn = isSuccess || (ucs is UserAuthChangesSuccess && ucs.savedUserAuth != null);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 75,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => html.window.location.reload(),
                                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Image.asset(AppAssetConstants.gamingLogo, height: 65, width: 140)),
                              ),
                              wb20,
                              SizedBox(
                                width: 250,
                                child: CompositedTransformTarget(
                                  link: _searchLayerLink,
                                  child: LoginTextFormField(
                                    autofocus: false,
                                    controller: searchController,
                                    onChanged: handleSearch,
                                    onFieldSubmitted: handleSearch,
                                    hintText: "  Search Events",
                                    prefixIcon: Icon(Icons.search, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isLoggedIn)
                            Row(
                              children: [
                                MainBalanceOverlay(),
                                wb10,
                                MyAccountOverlay(action: widget.action),
                              ],
                            )
                          else
                            SizedBox(
                              height: 75,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        LoginTextFormField(readOnly: isLoading, hintText: "Username", controller: userNameController),
                                        LoginTextFormField(
                                          readOnly: isLoading,
                                          hintText: "Password",
                                          obscureText: obscurePassword,
                                          controller: passwordController,
                                          suffixIcon: IconButton(
                                            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18, color: black),
                                            onPressed: () {
                                              setState(() {
                                                obscurePassword = !obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        LoginTextFormField(
                                          readOnly: isLoading,
                                          hintText: "Validation",
                                          controller: validationCodeController,
                                          inputFormatters: [integers, LengthLimitingTextInputFormatter(4)],
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(top: 4, right: 4),
                                            child: Text(
                                              validationCode,
                                              style: const TextStyle(color: black, fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          onFieldSubmitted: (p0) {
                                            handleLogin(context);
                                          },
                                        ),
                                        CustomCTAButton(
                                          title: "Login",
                                          isProcessing: isLoading,
                                          icon: Icons.logout,
                                          gradientColor: redGradient,
                                          action: () => handleLogin(context),
                                        ),
                                        CustomCTAButton(
                                          title: "Sign up",
                                          action: () async {
                                            await openUrl(AppStringConstants.whatsappLink1);
                                          },
                                        ),
                                        CustomCTAButton(title: "Try Demo", icon: Icons.play_arrow, gradientColor: blackGrdntButton, action: () => DemoBootstrap.start(context)),
                                      ],
                                    ),
                                  ),
                                  if (formError != null)
                                    Positioned(
                                      bottom: 2,
                                      child: Text(
                                        formError!,
                                        style: const TextStyle(color: bgCktbet, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class SearchResultItem extends StatefulWidget {
  const SearchResultItem({super.key, required this.event, required this.onTap});
  final SearchEvent event;
  final VoidCallback onTap;

  @override
  State<SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<SearchResultItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                getTimeFromDateTime(widget.event.openDate),
                style: TextStyle(fontSize: 12, color: black, decoration: _hovered ? TextDecoration.underline : TextDecoration.none),
              ),
              wb5,
              Expanded(
                child: Text(
                  widget.event.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: black, decoration: _hovered ? TextDecoration.underline : TextDecoration.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
