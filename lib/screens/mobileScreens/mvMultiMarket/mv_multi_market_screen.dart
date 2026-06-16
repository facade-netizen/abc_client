import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_mm_fancy_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_user_mm_fancy_pl_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_mm_fancy_listener_bloc.dart';
import '../../../blocs/signalRBloc/signalr_mm_odds_bm_listener_bloc.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_bm_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_fancy_signalr_data_streamer.dart';
import '../../../blocs/signalRBloc/singnalRStreamers/mm_odds_signalr_streamer.dart';
import '../../../constants/app_asset_constants.dart';
import '../../../models/favourite_model.dart';
import '../../../models/mm_fancy_model.dart';
import '../../../models/sport_category_model.dart';
import '../../../routing/route_navigation_helper.dart';
import 'mvMmBm/mv_mm_bm_header_widget.dart';
import 'mvMmBm/mv_mm_bm_runners.dart';
import 'mvMmFancy/mm_mv_fancy_markets.dart';
import 'mvMmOdds/mv_mm_header_widget.dart';
import 'mvMmOdds/mv_mm_odds_market_card.dart';

class MVMultiMarketsCard extends StatefulWidget {
  const MVMultiMarketsCard({super.key});

  @override
  State<MVMultiMarketsCard> createState() => _MVMultiMarketsCardState();
}

class _MVMultiMarketsCardState extends State<MVMultiMarketsCard> {
  int? eventId;
  int? sid;
  List<List<MMFancyMarketData>> fancyMarketData = [];
  List<FavouriteEventData> favEvents = [];
  List<FavouriteEventData> odds = [];
  List<FavouriteEventData> bmData = [];
  List<EventType> allCategorySports = [];
  Set<String> _subscribedOddBMEventIds = {};
  Set<String> _subscribedFancyEventIds = {};

  @override
  void initState() {
    super.initState();
    context.read<FetchFavouriteBloc>().add(FetchFavourite());
    context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
    context.read<FetchUserMMFancyPLBloc>().add(FetchUserMMFancyPL());
    context.read<FetchMMFancyBloc>().add(FetchMMFancy());
    context.read<SignalRMMODDSDataBloc>().add(SignalRMMODDSDataListener());
    context.read<SignalRMMBMDataBloc>().add(SignalRMMBMDataListener());
    context.read<SignalRMMFancyDataBloc>().add(SignalRMMFancyDataListener());
  }

  void _subscribeOddBMEvents(List<String> eventIds) {
    final sanitizedIds = eventIds.where((id) => id.isNotEmpty).toSet();
    if (sanitizedIds.isEmpty || sanitizedIds == _subscribedOddBMEventIds) return;
    _subscribedOddBMEventIds = sanitizedIds;
    context.read<SignalRMMOddBMListenerBloc>().add(SignalRMMOddBMListener(eventId: sanitizedIds.toList()));
  }

  void _subscribeFancyEvents(List<String> eventIds) {
    final sanitizedIds = eventIds.where((id) => id.isNotEmpty).toSet();
    if (sanitizedIds.isEmpty || sanitizedIds == _subscribedFancyEventIds) return;
    _subscribedFancyEventIds = sanitizedIds;
    context.read<SignalRMMFancyListenerBloc>().add(SignalRMMFancyListener(eventId: sanitizedIds.toList()));
  }

  void _updateFavouriteLists(List<FavouriteEventData> favouriteEvents) {
    favEvents = favouriteEvents;
    odds = favEvents.where((event) => event.favType == FavType.odds).toList();
    bmData = favEvents.where((event) => event.favType == FavType.bookmaker).toList();

    /// Match odds runner order map
    final Map<String, int> oddsRunnerOrder = {};
    for (int i = 0; i < odds.length; i++) {
      for (int j = 0; j < odds[i].runners.length; j++) {
        oddsRunnerOrder[odds[i].runners[j].name.toLowerCase()] = j;
      }
    }

    /// Sort bookmaker runners according to match odds
    for (final event in bmData) {
      event.runners.sort((a, b) {
        final aIndex = oddsRunnerOrder[a.name.toLowerCase()] ?? 999;
        final bIndex = oddsRunnerOrder[b.name.toLowerCase()] ?? 999;
        return aIndex.compareTo(bIndex);
      });
    }

    _subscribeOddBMEvents([...odds.map((e) => e.id), ...bmData.map((e) => e.id)]);
    _subscribeFancyEvents(fancyMarketData.expand((entry) => entry).map((item) => item.eventId).toList());
  }

  void _updateFancyMarketData(List<List<MMFancyMarketData>> data) {
    fancyMarketData = data;
    _subscribeFancyEvents(fancyMarketData.expand((entry) => entry).map((item) => item.eventId).toList());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
      listener: (context, afe) {
        if (afe is AddFavouriteEventsSuccess) {
          context.read<FetchFavouriteBloc>().add(FetchFavourite());
        }
      },
      child: BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
        listener: (context, rfe) {
          if (rfe is RemoveFavouriteEventsSuccess) {
            context.read<FetchFavouriteBloc>().add(FetchFavourite());
            context.read<FetchMMFancyBloc>().add(FetchMMFancy());
          }
        },
        child: BlocListener<FetchFavouriteBloc, FetchFavouriteState>(
          listener: (context, fel) {
            if (fel is FetchFavouriteSuccess) {
              setState(() {
                _updateFavouriteLists(fel.favEvents);
              });
            }
          },
          child: BlocListener<FetchMMFancyBloc, FetchMMFancyState>(
            listener: (context, mmf) {
              if (mmf is FetchMMFancySuccess) {
                setState(() {
                  _updateFancyMarketData(mmf.fancyMarketData);
                });
              }
            },
            child: BlocBuilder<FetchMMFancyBloc, FetchMMFancyState>(
              builder: (context, mmf) {
                return BlocBuilder<FetchFavouriteBloc, FetchFavouriteState>(
                  builder: (context, fel) {
                    if (fel is FetchFavouriteSuccess) {
                      favEvents = fel.favEvents;
                      odds = favEvents.where((event) => event.favType == FavType.odds).toList();
                      bmData = favEvents.where((event) => event.favType == FavType.bookmaker).toList();
                    }
                    if (mmf is FetchMMFancySuccess) {
                      fancyMarketData = mmf.fancyMarketData;
                    }
                    final fancyEventsById = <String, Map<String, MMFancyMarketData>>{};
                    for (final eventMeta in fancyMarketData.expand((entry) => entry)) {
                      fancyEventsById.putIfAbsent(eventMeta.eventId, () => {})[eventMeta.marketId] = eventMeta;
                    }

                    return odds.isNotEmpty || bmData.isNotEmpty || fancyMarketData.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                if (odds.isNotEmpty)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: odds.length,
                                        itemBuilder: (context, index) {
                                          final oddsMarkets = odds[index];
                                          return Column(
                                            children: [
                                              MvMMHeaderOdds(
                                                eventName: oddsMarkets.name,
                                                removeMarket: () {
                                                  context.read<RemoveFavouriteEventsBloc>().add(
                                                        RemoveFavouriteEvents(
                                                          eventId: oddsMarkets.id,
                                                          favType: FavType.odds,
                                                        ),
                                                      );
                                                },
                                                refreshMarket: () {
                                                  context.read<FetchFavouriteBloc>().add(FetchFavourite());
                                                  context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
                                                },
                                                gotoMarket: () {
                                                  context.go(GoToRoute.sportEvent(
                                                    sportId: oddsMarkets.sid,
                                                    name: oddsMarkets.sid == "4"
                                                        ? 'Cricket'
                                                        : oddsMarkets.sid == "1"
                                                            ? 'Soccer'
                                                            : oddsMarkets.sid == "0"
                                                                ? 'Tennis'
                                                                : "",
                                                    eventId: oddsMarkets.id,
                                                    inPlay: oddsMarkets.inPlay,
                                                    premium: oddsMarkets.premiumMatch,
                                                    fancyMarket: oddsMarkets.fancyMarket,
                                                  ));
                                                },
                                              ),
                                              MvMMOddsRunners(oddsData: oddsMarkets),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                if (bmData.isNotEmpty)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: bmData.length,
                                        itemBuilder: (context, index) {
                                          final bmMarkets = bmData[index];
                                          return Column(
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  MvMMHeaderBM(
                                                    eventName: bmMarkets.name,
                                                    removeMarket: () {
                                                      context.read<RemoveFavouriteEventsBloc>().add(
                                                            RemoveFavouriteEvents(
                                                              eventId: bmMarkets.id,
                                                              marketId: bmMarkets.marketId,
                                                              favType: FavType.bookmaker,
                                                            ),
                                                          );
                                                    },
                                                    refreshMarket: () {
                                                      context.read<FetchFavouriteBloc>().add(FetchFavourite());
                                                      context.read<FetchUserMMPLOddBMBloc>().add(FetchUserMMPLOddBM());
                                                    },
                                                    gotoMarket: () {
                                                      context.go(
                                                        GoToRoute.sportEvent(
                                                          sportId: bmMarkets.sid,
                                                          name: bmMarkets.sid == "4"
                                                              ? 'Cricket'
                                                              : bmMarkets.sid == "1"
                                                                  ? 'Soccer'
                                                                  : bmMarkets.sid == "0"
                                                                      ? 'Tennis'
                                                                      : "",
                                                          eventId: bmMarkets.id,
                                                          inPlay: bmMarkets.inPlay,
                                                          premium: bmMarkets.premiumMatch,
                                                          fancyMarket: bmMarkets.fancyMarket,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  MvMMBMRunners(
                                                    bmData: bmMarkets,
                                                    matchOddsRunners: bmMarkets.runners,
                                                  )
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ...fancyEventsById.entries.map((entry) {
                                  final eventId = entry.key;
                                  final eventMarkets = entry.value;
                                  final eventMeta = eventMarkets.values.first;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MvMMHeaderBM(
                                        eventName: eventMeta.eventName ?? '',
                                        svgIcon: AppAssetConstants.f,
                                        removeMarket: () {
                                          context.read<RemoveFavouriteEventsBloc>().add(
                                                RemoveFavouriteEvents(
                                                  eventId: eventId,
                                                  favType: FavType.lines,
                                                ),
                                              );
                                        },
                                        refreshMarket: () {
                                          context.read<FetchMMFancyBloc>().add(FetchMMFancy());
                                          context.read<FetchUserMMFancyPLBloc>().add(FetchUserMMFancyPL());
                                        },
                                        gotoMarket: () {
                                          context.go(GoToRoute.sportEvent(
                                            sportId: eventMeta.sid ?? "",
                                            name: eventMeta.sid == "4"
                                                ? 'Cricket'
                                                : eventMeta.sid == "1"
                                                    ? 'Soccer'
                                                    : eventMeta.sid == "0"
                                                        ? 'Tennis'
                                                        : "",
                                            eventId: eventId,
                                            inPlay: eventMeta.inPlay,
                                            premium: eventMeta.premium ?? false,
                                            fancyMarket: eventMeta.fancyMarket ?? false,
                                          ));
                                        },
                                      ),
                                      MMMvFancyMarkets(
                                        fancyMarkets: eventMarkets,
                                        eventId: eventId,
                                        sid: eventMeta.sid ?? '',
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color(0xff7E97A7)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "There are currently no followed\nmulti markets.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xff7E97A7),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(color: Color(0xff7E97A7), thickness: 1),
                                const SizedBox(height: 12),
                                const Text(
                                  "Please add some markets from events.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xff7E97A7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
