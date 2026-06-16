import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_only_inplay_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sport_events_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../../../localDb/token/login_token_model.dart';
import '../../../models/event_with_type_model.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/loader.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/navigators.dart';
import '../mobileAuthView/mobileAuthView/mv_login_screen.dart';
import '../mvReusables/mobile_string_list.dart';
import '../sportScreen/custom_event_details_card.dart';
import '../sportScreen/mv_sport_screen.dart';
import 'inplay_custom_tabs.dart';

class MVInPlayScreenPage extends StatefulWidget {
  const MVInPlayScreenPage({super.key});
  @override
  State<MVInPlayScreenPage> createState() => _MVInPlayScreenPageState();
}

class _MVInPlayScreenPageState extends State<MVInPlayScreenPage> {
  Set<String> removedEventIds = {};

  @override
  void initState() {
    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouter.of(context).state.matchedLocation;
    final index = getTabIndexFromRoute(location);
    if (subscribedEventId != null) {
      context.read<SignalREventListenerBloc>().add(SignalREventDisconnect(eventId: subscribedEventId!));
      context.read<FetchBookMakerBloc>().add(SetToInitialBM());
      context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
      context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
      context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
      context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
      context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
    }
    if (index == 0) {
      context.read<FetchOnlyInplayEventsBloc>().add(FetchOnlyInplayEvents());
    } else if (index == 1) {
      context.read<FetchSportEventsBloc>().add(FetchSportEvents(evenTypeID: 0, tomorrow: false, today: true));
    } else if (index == 2) {
      context.read<FetchSportEventsBloc>().add(FetchSportEvents(evenTypeID: 0, tomorrow: true, today: false));
    }
  }

  void _removeEventFromList(List<String> eventIds) {
    final validIds = eventIds.where((eventId) => eventId.isNotEmpty && !removedEventIds.contains(eventId)).toList();
    if (validIds.isEmpty) return;

    setState(() {
      removedEventIds.addAll(validIds);
    });
  }

  int getTabIndexFromRoute(String location) {
    if (location == '/inplay') return 0;
    if (location.contains('/today')) return 1;
    if (location.contains('/tomorrow')) return 2;
    if (location.contains('/result')) return 3;
    return 0;
  }

  Map<String, String> getParams() {
    return GoRouter.of(context).state.pathParameters;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.matchedLocation;
    final activeTabIndex = getTabIndexFromRoute(location);
    return BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
      builder: (context, uas) {
        SaveLoginTokenModel? savedUserAuth;
        if (uas is UserAuthChangesSuccess) {
          savedUserAuth = uas.savedUserAuth;
        }
        return BlocListener<RemoveEventSignalRStreamerBloc, RemoveEventSignalRStreamerState>(listener: (context, state) {
          if (state is RemoveEventSignalRStreamerSuccess && state.forInplayIds.isNotEmpty) {
            _removeEventFromList(state.forInplayIds);
          }
        }, child: BlocBuilder<FetchOnlyInplayEventsBloc, FetchOnlyInplayEventsState>(
          builder: (context, state) {
            List<Sport> inPlayEventData = [];
            if (state is FetchOnlyInplayEventsSuccess) {
              inPlayEventData = state.eventResponse.data
                  .map((sport) => Sport(
                        id: sport.id,
                        name: sport.name,
                        event: sport.event.where((e) => e.id != '28127348' && !removedEventIds.contains(e.id)).toList(),
                      ))
                  .toList();
              inPlayEventData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            }
            return BlocBuilder<FetchSportEventsBloc, FetchSportEventsState>(
              builder: (context, fes) {
                List<Sport> eventData = [];
                if (fes is FetchSportEventsSuccess) {
                  eventData = fes.eventResponse.data
                      .map((sport) => Sport(
                            id: sport.id,
                            name: sport.name,
                            event: sport.event.where((e) => !removedEventIds.contains(e.id)).toList(),
                          ))
                      .toList();
                  eventData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                }
                return fes is FetchSportEventsProgress
                    ? LoaderContainerWithMessage()
                    : ListView(
                        children: [
                          Container(
                            height: 55,
                            decoration: BoxDecoration(color: btmBarBottomColor),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: white),
                                        borderRadius: BorderRadius.circular(5),
                                        color: btmBarBottomColor,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final tabs = inPlayTabs(savedUserAuth != null && savedUserAuth.userId != null);
                                          final tabWidth = constraints.maxWidth / tabs.length;
                                          return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: tabs.length,
                                            itemBuilder: (context, index) {
                                              final item = tabs[index];
                                              return SizedBox(
                                                width: tabWidth,
                                                child: InplayCustomTabBtn(
                                                  isActive: activeTabIndex == index,
                                                  label: item,
                                                  onTap: () {
                                                    if (index == 0) {
                                                      context.go(GoToRoute.inplay());
                                                    } else if (index == 1) {
                                                      context.go(GoToRoute.inplay(type: 'today'));
                                                    } else if (index == 2) {
                                                      context.go(GoToRoute.inplay(type: 'tomorrow'));
                                                    } else {
                                                      context.go(GoToRoute.result());
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: grey)),
                                    gradient: LinearGradient(
                                      colors: [primaryGradient, btmBarBottomColor, btmBarBottomColor],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: Icon(Icons.search, color: white, size: 30),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activeTabIndex == 0 ? inPlayEventData.length : eventData.length,
                            itemBuilder: (context, sportIndex) {
                              final sport = activeTabIndex == 0 ? inPlayEventData[sportIndex] : eventData[sportIndex];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sport.event.isEmpty
                                      ? SizedBox.shrink()
                                      : Container(
                                          width: double.infinity,
                                          height: 33,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [btmTopColor, btmBarBottomColor], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                          ),
                                          child: Center(
                                            child: Text(
                                              sport.name,
                                              style: TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                            ),
                                          ),
                                        ),
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
                                        itemCount: activeTabIndex == 0 ? sport.event.where((e) => e.inPlay == true).length : sport.event.length,
                                        itemBuilder: (context, index) {
                                          final event = activeTabIndex == 0 ? sport.event.where((e) => e.inPlay == true).toList()[index] : sport.event[index];
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
                                                      sportId: sport.id,
                                                      name: sport.name,
                                                      eventId: event.id,
                                                      inPlay: event.inPlay,
                                                      premium: event.premiumMatch,
                                                      fancyMarket: event.fancyMarket,
                                                    ),
                                                  );
                                                },
                                                addFavTap: () {
                                                  if (savedUserAuth != null && savedUserAuth.userId != null) {
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
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
              },
            );
          },
        ));
      },
    );
  }
}
