import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../../../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../../blocs/signalRBloc/subscribe_scoring_signalr_bloc.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../localDb/token/login_token_box.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../models/competation_with_events_model.dart';
import '../../../models/event_with_type_model.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../models/sport_category_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/loader.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/navigators.dart';
import '../../deskopView/homeView/custom_carousel.dart';
import '../../deskopView/newSportsView/new_sports_view_screen.dart';
import '../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../mvAccounts/cgaming/mv_show_cg_add_money_dialog_for_casino_menu.dart';
import 'custom_event_details_card.dart';
import 'mv_live_count_widget.dart';
import 'search_screen.dart';
import 'sport_screen_widget.dart';
import 'sports_type_tab_button.dart';
import 'top_filter_widget.dart';

String? subscribedEventId;

class MVSportScreen extends StatefulWidget {
  const MVSportScreen({super.key, this.sportId, this.name});
  final String? name;
  final String? sportId;
  @override
  State<MVSportScreen> createState() => _MVSportScreenState();
}

class _MVSportScreenState extends State<MVSportScreen> {
  late final ScrollController _categoryScrollController;
  SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
  bool isUserLoggedIn = false;
  int filterIndex = 0;
  List<Event> eventData = [];
  Set<String> removedEventIds = {};
  int cricket = 0, soccer = 0, tennis = 0, gHond = 0, hourse = 0, ele = 0;

  @override
  void initState() {
    isUserLoggedIn = savedTokenData != null && savedTokenData?.token != null;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
    context.read<FetchOnlyInplayCountsBloc>().add(FetchOnlyInplayCounts());
    _categoryScrollController = ScrollController();
    if (subscribedEventId != null) {
      context.read<SignalREventListenerBloc>().add(SignalREventDisconnect(eventId: subscribedEventId ?? "0"));
      context.read<JoinMatchSignalRBloc>().add(DisconnectScoringSignalR(eventId: int.tryParse(subscribedEventId ?? "0") ?? 0));
      context.read<FetchBookMakerBloc>().add(SetToInitialBM());
      context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
      context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
      context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
      context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
      context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
      context.read<EnableMatchButtonBloc>().add(EnableMatchButton(false, "0"));
    }
    final params = GoRouter.of(context).state.pathParameters;
    final newSportId = params['sportId'] ?? '';
    context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: newSportId));
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  int getActiveIndex(List<EventType> category) {
    final params = GoRouter.of(context).state.pathParameters;
    final routeSportId = params['sportId'] ?? '';
    if (routeSportId.isEmpty) return 0;
    final index = category.indexWhere((c) => c.id == routeSportId);
    if (index == -1) return 0;
    if (isUserLoggedIn) {
      return index == 0 ? 1 : index + 2;
    }
    return index == 0 ? 0 : index + 1;
  }

  void scrollToActiveIndex(List<EventType> category) {
    final params = GoRouter.of(context).state.pathParameters;
    final routeSportId = params['sportId'] ?? '';

    if (routeSportId.isEmpty) return;

    final index = category.indexWhere((c) => c.id == routeSportId);
    if (index == -1 || index == 0) return;
    final adjustedIndex = isUserLoggedIn ? index + 2 : index + 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoryScrollController.hasClients) {
        _categoryScrollController.animateTo(adjustedIndex * 120.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  void _removeEventFromList(List<String> eventIds) {
    final validIds = eventIds.where((eventId) => eventId.isNotEmpty && !removedEventIds.contains(eventId)).toList();
    if (validIds.isEmpty) return;

    setState(() {
      removedEventIds.addAll(validIds);
      eventData.removeWhere((event) => validIds.contains(event.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = GoRouter.of(context).state.pathParameters;
    final sportName = params['screenType'] ?? 'Cricket';
    return BlocBuilder<FetchSportsCategoryBloc, FetchSportsCategoryState>(
      builder: (context, scs) {
        List<EventType> category = [];
        if (scs is FetchSportsCategorySuccess) {
          category = scs.categoryResponse.data;
          scrollToActiveIndex(category);
        }
        return scs is FetchSportsCategoryProgress
            ? LoaderContainerWithMessage()
            : BlocListener<RemoveEventSignalRStreamerBloc, RemoveEventSignalRStreamerState>(
                listener: (context, state) {
                  if (state is RemoveEventSignalRStreamerSuccess && state.ids.isNotEmpty) {
                    _removeEventFromList(state.ids);
                  }
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 80, child: CustomCarousel(isMobile: true, imagesList: homeBanner)),
                      Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: appYellow,
                              border: Border(bottom: BorderSide(color: black, width: 3)),
                            ),
                            child: ListView.builder(
                              controller: _categoryScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: category.isEmpty ? 0 : category.length + (isUserLoggedIn ? 2 : 1),
                              itemBuilder: (context, index) {
                                if (index == 0 && isUserLoggedIn) {
                                  return Stack(
                                    fit: StackFit.passthrough,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14, right: 5, left: 8),
                                        child: InkWell(
                                          onTap: () {
                                            showMvCgAddMoneyForCasinoMenuDialog(context);
                                          },
                                          child: Container(
                                            height: 43,
                                            width: 96,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Color(0xFF806575), Color(0xFF4B2C3E)],
                                                stops: [0.15, 1.0],
                                              ),
                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(8)),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(AppAssetConstants.menuCasino, height: 25),
                                                wb2,
                                                Text(
                                                  'Casino',
                                                  style: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, color: white, height: 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 5,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: red,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [BoxShadow(color: black.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 3, offset: Offset(0, 2))],
                                          ),
                                          child: Text(
                                            "New",
                                            style: TextStyle(color: white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                if ((isUserLoggedIn && index == 2) || (!isUserLoggedIn && index == 1)) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 14, right: 5, left: 8),
                                    child: InkWell(
                                      onTap: () {
                                        context.go(
                                          GoToRoute.sportEvent(sportId: "4", name: winnerScreenType, eventId: winnerEventId, inPlay: false, premium: false, fancyMarket: false),
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 200,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: appYellowGrdnt,
                                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(8)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(AppAssetConstants.ball, height: 25, colorFilter: ColorFilter.mode(black, BlendMode.srcIn)),
                                            wb5,
                                            Text(
                                              'FIFA World Cup - Winner',
                                              style: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold, color: black, height: 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final actualIndex = isUserLoggedIn ? (index < 2 ? index - 1 : index - 2) : (index < 1 ? index : index - 1);
                                final item = category[actualIndex];
                                int activeTabIndex = getActiveIndex(category);
                                return Stack(
                                  fit: StackFit.passthrough,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 14, right: item.name.toLowerCase().contains('politics') ? 100 : 5, left: 8),
                                      child: SportTypeCustomTabBtn(
                                        item.name,
                                        icon: item.icon,
                                        isActive: activeTabIndex == index,
                                        onTap: () {
                                          context.go(GoToRoute.sport(sportId: item.id, name: item.name));
                                        },
                                      ),
                                    ),
                                    BlocBuilder<FetchOnlyInplayCountsBloc, FetchOnlyInplayCountsState>(
                                      builder: (context, state) {
                                        if (state is FetchOnlyInplayCountsSuccess) {
                                          cricket = state.cricketCount;
                                          tennis = state.tennisCount;
                                          soccer = state.soccerCount;
                                          gHond = state.gHondCount;
                                          hourse = state.hourseCount;
                                          ele = state.eleCount;
                                        }
                                        return Positioned(
                                          right: item.name.toLowerCase().contains('politics') ? 100 : 8,
                                          top: 6,
                                          child: MVLiveBadge(
                                            count: item.id == "4"
                                                ? cricket
                                                : item.id == "1"
                                                ? soccer
                                                : item.id == "2"
                                                ? tennis
                                                : item.id == "4339"
                                                ? gHond
                                                : item.id == "7"
                                                ? hourse
                                                : item.id == "5"
                                                ? ele
                                                : item.count,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Positioned(
                            right: 1,
                            child: SeacrhButton(
                              onTap: () {
                                showSearchScreen(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<FetchCompetitionWithEventsBloc, FetchCompetitionWithEventsState>(
                        builder: (context, fcs) {
                          List<Competition> competationData = [];
                          if (fcs is FetchCompetitionWithEventsSuccess) {
                            competationData = fcs.competationData.map((competition) {
                              final events = competition.events.where((event) => !removedEventIds.contains(event.id)).toList()
                                ..sort((a, b) {
                                  final aDate = DateTime.tryParse(a.openDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
                                  final bDate = DateTime.tryParse(b.openDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
                                  return aDate.compareTo(bDate);
                                });
                              return Competition(id: competition.id, name: competition.name, events: events);
                            }).toList()..sort((a, b) => a.name.compareTo(b.name));
                            eventData = competationData.expand((c) => c.events).where((event) => !removedEventIds.contains(event.id)).toList()
                              ..sort((a, b) {
                                final aDate = DateTime.tryParse(a.openDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
                                final bDate = DateTime.tryParse(b.openDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
                                return aDate.compareTo(bDate);
                              });
                          }
                          return fcs is FetchCompetitionWithEventsProgress
                              ? LoaderContainerWithMessage()
                              : Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [btmTopColor, btmBarBottomColor], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                      ),
                                      height: 36,
                                      child: const Center(
                                        child: Text(
                                          "Highlights",
                                          style: TextStyle(color: white, letterSpacing: 0.5, fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    hb5,
                                    TopFilterWidget(
                                      selectedIndex: filterIndex,
                                      onTabSelected: (i) {
                                        setState(() {
                                          filterIndex = i;
                                        });
                                      },
                                    ),
                                    hb5,
                                    if (filterIndex == 0)
                                      BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                        listener: (context, afe) {
                                          if (afe is AddFavouriteEventsSuccess) {
                                            context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                          }
                                        },
                                        child: BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                          listener: (context, rfe) {
                                            if (rfe is RemoveFavouriteEventsSuccess) {
                                              context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                            }
                                          },
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: eventData.length,
                                            itemBuilder: (context, index) {
                                              final event = eventData[index];
                                              return BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                                                builder: (context, fes) {
                                                  List<AddedMMEventItem> favEvents = [];
                                                  if (fes is FetchAddedMMEventsSuccess) {
                                                    favEvents = fes.favEvents;
                                                  }
                                                  final isFav = favEvents.any((fav) => fav.eventId == event.id && fav.favType == FavType.odds);
                                                  return CustomEventDetailsCard(
                                                    event: event,
                                                    pinColor: isFav ? green : grey,
                                                    onTap: () {
                                                      context.go(
                                                        GoToRoute.sportEvent(
                                                          sportId: event.sid,
                                                          name: sportName,
                                                          eventId: event.id,
                                                          inPlay: event.inPlay,
                                                          premium: event.premiumMatch,
                                                          fancyMarket: event.fancyMarket,
                                                        ),
                                                      );
                                                    },
                                                    addFavTap: () {
                                                      if (isUserLoggedIn) {
                                                        if (isFav) {
                                                          context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: event.id, favType: FavType.odds));
                                                        } else {
                                                          context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: event.id, favType: FavType.odds));
                                                        }
                                                      } else {
                                                        pushSimple(context, MVLogin());
                                                      }
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    else
                                      BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                        listener: (context, afe) {
                                          if (afe is AddFavouriteEventsSuccess) {
                                            context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                          }
                                        },
                                        child: BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                          listener: (context, rfe) {
                                            if (rfe is RemoveFavouriteEventsSuccess) {
                                              context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                            }
                                          },
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: competationData.length,
                                            itemBuilder: (context, index) {
                                              final competation = competationData[index];
                                              return Column(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        top: BorderSide(color: grey, width: 0.5),
                                                        bottom: BorderSide(color: grey, width: 0.5),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10, top: 10),
                                                      child: Text(
                                                        competation.name,
                                                        style: TextStyle(color: Color(0xff000000), fontSize: 15, letterSpacing: 0.5, fontWeight: FontWeight.w700),
                                                      ),
                                                    ),
                                                  ),

                                                  /// EVENTS LIST
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: competation.events.length,
                                                    itemBuilder: (context, index) {
                                                      final event = competation.events[index];
                                                      return BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                                                        builder: (context, fes) {
                                                          List<AddedMMEventItem> favEvents = [];
                                                          if (fes is FetchAddedMMEventsSuccess) {
                                                            favEvents = fes.favEvents;
                                                          }
                                                          final isFav = favEvents.any((fav) => fav.eventId == event.id && fav.favType == FavType.odds);
                                                          return CustomEventDetailsCard(
                                                            event: event,
                                                            pinColor: isFav ? green : grey,
                                                            addFavTap: () {
                                                              if (isUserLoggedIn) {
                                                                if (isFav) {
                                                                  context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: event.id, favType: FavType.odds));
                                                                } else {
                                                                  context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: event.id, favType: FavType.odds));
                                                                }
                                                              } else {
                                                                pushSimple(context, MVLogin());
                                                              }
                                                            },
                                                            onTap: () {
                                                              context.go(
                                                                GoToRoute.sportEvent(
                                                                  sportId: event.sid,
                                                                  name: sportName,
                                                                  eventId: event.id,
                                                                  inPlay: event.inPlay,
                                                                  premium: event.premiumMatch,
                                                                  fancyMarket: event.fancyMarket,
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
