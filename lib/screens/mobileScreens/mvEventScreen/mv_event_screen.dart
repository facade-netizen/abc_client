import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../models/fancy_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../../apis/apiHandlers/api_constants.dart';
import '../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_odds_runners_pl_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../../../blocs/miscBlocs/check_match_stream_live_bloc.dart';
import '../../../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../../../blocs/miscBlocs/get_market_id_in_app_bloc.dart';
import '../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../blocs/signalRBloc/subscribe_scoring_signalr_bloc.dart';
import '../../../models/mm_add_markets_model.dart';
import '../../../models/odd_data_model.dart';
import '../../../reusables/loader.dart';
import '../../../reusables/video_stream.dart';
import '../../deskopView/newSportsView/new_sports_view_screen.dart';
import '../../deskopView/sportsView/fancyBetView/fancy_rule_book.dart';
import '../../deskopView/sportsView/fancyBetView/fancy_bet_header.dart';
import '../../deskopView/sportsView/premiumView/new_premium_tabs.dart';
import '../mvScoreBoard/mv_score_board.dart';
import '../sportScreen/mv_sport_screen.dart';
import 'mvBM/mv_bm_runners.dart';
import 'mvFancy/mv_fancy_markets.dart';
import 'mvOdds/mv_odds_runners.dart';

enum MarketSection { matchOdds, bookmaker, fancy, score }

class EventsBetScreen extends StatefulWidget {
  const EventsBetScreen({
    super.key,
    required this.eventTypeTitle,
    required this.eventId,
    required this.inplay,
    required this.sid,
    required this.premiumMatch,
    required this.fancyMarket,
  });
  final String eventId;
  final String sid;
  final bool inplay;
  final bool premiumMatch;
  final bool fancyMarket;
  final String eventTypeTitle;
  @override
  State<EventsBetScreen> createState() => _EventsBetScreenState();
}

class _EventsBetScreenState extends State<EventsBetScreen> {
  String? marketIds;
  FancyMarketData? fancyMarketData;
  int selectedTabIndex = 0;
  bool isFancyBet = true;

  Set<MarketSection> expandedSections = {MarketSection.matchOdds, MarketSection.bookmaker, MarketSection.fancy};
  @override
  void initState() {
    expandedSections = {
      MarketSection.matchOdds,
      MarketSection.score,
      if (widget.sid == "4") MarketSection.bookmaker,
      if (widget.sid == "4" || widget.sid == "1" || widget.sid == "2" || widget.sid == politicsSID) MarketSection.fancy,
    };
    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
    context.read<FetchScoreBoardBloc>().add(FetchScoreBoard(eventId: int.tryParse(widget.eventId) ?? 0));
    context.read<JoinMatchSignalRBloc>().add(JoinMatchSignalR(eventId: int.tryParse(widget.eventId) ?? 0));
    context.read<FetchFavStakeBloc>().add(FetchFavStake());
    context.read<FetchODDSDataBloc>().add(FetchODDSData(eventId: widget.eventId));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<FetchBookMakerBloc>().add(FetchBookMaker(eventId: widget.eventId));
    });
    context.read<FetchFancyDataBloc>().add(FetchFancyData(eventId: widget.eventId));
    context.read<EnableMatchButtonBloc>().add(EnableMatchButton(widget.inplay, widget.eventId));
    context.read<SignalRBMDataBloc>().add(SignalRBMDataListener());
    context.read<SignalRODDSDataBloc>().add(SignalRODDSDataListener());
    context.read<SignalRFancyDataBloc>().add(SignalRFancyDataListener());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subscribedEventId = widget.eventId;
    });
    super.initState();
  }

  void toggleSection(MarketSection section) {
    setState(() {
      if (expandedSections.contains(section)) {
        expandedSections.remove(section);
      } else {
        expandedSections.add(section);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
      builder: (context, fss) {
        final bool isPremiumMatch = widget.premiumMatch;
        final bool isFancyMarket = widget.fancyMarket;
        final bool isPolitics = widget.sid == politicsSID;
        final bool showFancyPremiumSection = isFancyMarket || isPremiumMatch;
        final bool showBothFancyAndPremiumTabs = isFancyMarket && isPremiumMatch;
        final bool showPremiumOnlyTab = isPremiumMatch && !isFancyMarket;
        final bool showFancyOnlyTab = isFancyMarket && !isPremiumMatch;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<CheckMatchStreamLiveBloc, CheckMatchStreamLiveState>(
                builder: (context, state) {
                  return state is CheckMatchStreamLiveSuccess && state.isLive == true
                      ? IframeVideoContainer(height: 180, width: double.infinity, videoUrl: "$streamUrl1${widget.eventId}")
                      : SizedBox.shrink();
                },
              ),
              Container(
                height: 32,
                width: double.infinity,
                decoration: BoxDecoration(gradient: mvEventHeader),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.eventTypeTitle,
                        style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: widget.inplay,
                            child: Row(
                              children: [
                                Container(
                                  width: 25,
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: green),
                                  child: Center(child: SvgPicture.asset(AppAssetConstants.clock, height: 13, width: 13, colorFilter: ColorFilter.mode(white, BlendMode.srcIn))),
                                ),
                                wb5,
                                Text(
                                  'In-Play',
                                  style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          wb2,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              child: InkWell(
                                onTap: () => toggleSection(MarketSection.score),
                                child: Icon(
                                  expandedSections.contains(MarketSection.score) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                                  size: 18,
                                  color: white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: grey, thickness: 0.2),
              Container(
                color: Color(0xffe0e6e6),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (expandedSections.contains(MarketSection.score)) MVScoreDashboardNew2(eventId: widget.eventId),
                    InkWell(
                      onTap: () {
                        context.read<FetchODDSDataBloc>().add(FetchODDSData(eventId: widget.eventId));
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) context.read<FetchBookMakerBloc>().add(FetchBookMaker(eventId: widget.eventId));
                        });
                        context.read<FetchFancyDataBloc>().add(FetchFancyData(eventId: widget.eventId));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 117,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF474747), Color(0xFF070707)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: const Text(
                              "Match Odds",
                              style: TextStyle(fontWeight: FontWeight.bold, color: appYellow),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocListener<FetchODDSDataBloc, FetchODDSDataState>(
                listenWhen: (prev, curr) => curr is FetchODDSDataSuccess,
                listener: (context, state) {
                  if (state is FetchODDSDataSuccess) {
                    final data = state.oddsResponse.data;
                    if (data.runners.isNotEmpty) {
                      context.read<FetchOddsRunnerPLBloc>().add(FetchOddsRunnerPL(eventId: data.eventId, marketId: data.marketId));
                    }
                  }
                },
                child: BlocBuilder<FetchODDSDataBloc, FetchODDSDataState>(
                  buildWhen: (prev, curr) => curr is FetchODDSDataSuccess,
                  builder: (context, state) {
                    if (state is FetchODDSDataSuccess && state.oddsResponse.data.runners.isNotEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Row(
                                  children: [
                                    PopupMenuButton<void>(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      itemBuilder: (_) => [
                                        PopupMenuItem<void>(
                                          enabled: false,
                                          padding: EdgeInsets.zero,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () => Navigator.pop(context),
                                                  child: const Icon(Icons.close, size: 16, color: Colors.black54),
                                                ),
                                                const SizedBox(width: 10),
                                                const Text('Min/Max', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                                const SizedBox(width: 4),
                                                StatefulBuilder(
                                                  builder: (ctx, setSt) => Text(
                                                    '${state.oddsResponse.data.marketCondition.minBet} / ${state.oddsResponse.data.marketCondition.maxBet}',
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      child: SvgPicture.asset(AppAssetConstants.oddminmax),
                                    ),
                                    wb10,
                                    SvgPicture.asset(AppAssetConstants.circleBar),
                                  ],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Back",
                                    style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  wb50,
                                  Text(
                                    "Lay",
                                    style: TextStyle(color: black, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: InkWell(
                                      onTap: () => toggleSection(MarketSection.matchOdds),
                                      child: Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(2)),
                                        child: Icon(expandedSections.contains(MarketSection.matchOdds) ? Icons.remove : Icons.add, color: white, size: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (expandedSections.contains(MarketSection.matchOdds))
                            MvOddsRunners(oddsData: state.oddsResponse.data, favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              if (widget.sid == "4" && widget.eventId != winnerEventId)
                BlocListener<FetchBookMakerBloc, FetchBookMakerState>(
                  listenWhen: (prev, curr) => curr is FetchBookMakerSuccess,
                  listener: (context, state) {
                    if (state is FetchBookMakerSuccess) {
                      context.read<GetMarketIDBloc>().add(GetMarketID(state.eventResponse.data.marketId, ''));
                      context.read<FetchBMRunnerPLBloc>().add(FetchBMRunnerPL(eventId: state.eventResponse.data.eventId, marketId: state.eventResponse.data.marketId));
                    }
                  },
                  child: BlocBuilder<FetchBookMakerBloc, FetchBookMakerState>(
                    buildWhen: (prev, curr) => curr is FetchBookMakerSuccess,
                    builder: (context, state) {
                      if (state is FetchBookMakerSuccess) {
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 36,
                              decoration: BoxDecoration(color: Colors.blueGrey[800]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      wb10,
                                      BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                                        builder: (context, fes) {
                                          List<AddedMMEventItem> favEvents = [];
                                          if (fes is FetchAddedMMEventsSuccess) {
                                            favEvents = fes.favEvents;
                                          }
                                          final isFav = favEvents.any((fav) => fav.eventId == widget.eventId && fav.favType == FavType.bookmaker);
                                          return MultiBlocListener(
                                            listeners: [
                                              BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                                listenWhen: (prev, curr) => curr is AddFavouriteEventsSuccess && prev is! AddFavouriteEventsSuccess,
                                                listener: (context, state) {
                                                  if (state is AddFavouriteEventsSuccess && state.eventId == widget.eventId) {
                                                    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                                  }
                                                },
                                              ),
                                              BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                                listenWhen: (prev, curr) => curr is RemoveFavouriteEventsSuccess && prev is! RemoveFavouriteEventsSuccess,
                                                listener: (context, state) {
                                                  if (state is RemoveFavouriteEventsSuccess && state.eventId == widget.eventId) {
                                                    context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                                  }
                                                },
                                              ),
                                            ],
                                            child: BlocBuilder<GetMarketIDBloc, GetMarketIDState>(
                                              builder: (context, getIdState) {
                                                return InkWell(
                                                  onTap: () {
                                                    if (getIdState is GetMarketIDSuccess) {
                                                      if (isFav) {
                                                        context.read<RemoveFavouriteEventsBloc>().add(
                                                          RemoveFavouriteEvents(eventId: widget.eventId, marketId: getIdState.bmMarketId, favType: FavType.bookmaker),
                                                        );
                                                      } else {
                                                        context.read<AddFavouriteEventsBloc>().add(
                                                          AddFavouriteEvents(eventId: widget.eventId, marketId: getIdState.bmMarketId, favType: FavType.bookmaker),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: SvgPicture.asset(isFav ? AppAssetConstants.removemarket : AppAssetConstants.pinblue),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      wb10,
                                      const Text(
                                        "Bookmaker Market",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      wb5,
                                      const Text(
                                        " | ",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      wb5,
                                      const Text(
                                        "Zero Commission",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      child: InkWell(
                                        onTap: () => toggleSection(MarketSection.bookmaker),
                                        child: Icon(
                                          expandedSections.contains(MarketSection.bookmaker) ? Icons.indeterminate_check_box_outlined : Icons.add_box_outlined,
                                          size: 18,
                                          color: white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (expandedSections.contains(MarketSection.bookmaker))
                              MvBmRunners(
                                bmData: state.eventResponse.data,
                                favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null,
                                matchOddsRunners: context.read<FetchODDSDataBloc>().state is FetchODDSDataSuccess
                                    ? (context.read<FetchODDSDataBloc>().state as FetchODDSDataSuccess).oddsResponse.data.runners
                                    : const <ODDSRunner>[],
                              ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              hb20,
              BlocListener<FetchFancyDataBloc, FetchFancyDataState>(
                listenWhen: (prev, curr) => curr is FetchFancyDataSuccess,
                listener: (context, state) {
                  if (state is FetchFancyDataSuccess) {
                    final marketIds = state.fancyMarketData.values.map((e) => e.marketId).join(',');
                    if (marketIds.isNotEmpty) {
                      context.read<FetchFancyRunnerPLBloc>().add(FetchFancyRunnerPL(eventId: widget.eventId, marketId: marketIds));
                    }
                  }
                },
                child: BlocBuilder<FetchFancyDataBloc, FetchFancyDataState>(
                  builder: (context, state) {
                    if (state is FetchFancyDataProgress) {
                      return LoaderContainerWithMessage();
                    }
                    if (state is FetchFancyDataSuccess) {
                      return Column(
                        children: [
                          if (showFancyPremiumSection)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    wb10,
                                    BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
                                      builder: (context, fes) {
                                        List<AddedMMEventItem> favEvents = [];
                                        if (fes is FetchAddedMMEventsSuccess) {
                                          favEvents = fes.favEvents;
                                        }
                                        final isFav = favEvents.any((fav) => fav.eventId == widget.eventId && fav.favType == FavType.lines);
                                        return MultiBlocListener(
                                          listeners: [
                                            BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                                              listenWhen: (prev, curr) => curr is AddFavouriteEventsSuccess && prev is! AddFavouriteEventsSuccess,
                                              listener: (context, state) {
                                                if (state is AddFavouriteEventsSuccess && state.eventId == widget.eventId) {
                                                  context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                                }
                                              },
                                            ),
                                            BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                                              listenWhen: (prev, curr) => curr is RemoveFavouriteEventsSuccess && prev is! RemoveFavouriteEventsSuccess,
                                              listener: (context, state) {
                                                if (state is RemoveFavouriteEventsSuccess && state.eventId == widget.eventId) {
                                                  context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                                                }
                                              },
                                            ),
                                          ],
                                          child: InkWell(
                                            onTap: () {
                                              if (isFav) {
                                                context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: widget.eventId, favType: FavType.lines));
                                              } else {
                                                context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: widget.eventId, favType: FavType.lines));
                                              }
                                            },
                                            child: SvgPicture.asset(isFav ? AppAssetConstants.removemarket : AppAssetConstants.pinblue),
                                          ),
                                        );
                                      },
                                    ),
                                    wb10,
                                    if (showBothFancyAndPremiumTabs)
                                      FancyPremiumBetHeader(
                                        isFancyBet: isFancyBet,
                                        onTapInfo: () {
                                          showFancyRulesDialog(context);
                                        },
                                      )
                                    else if (showPremiumOnlyTab)
                                      Container(
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        decoration: BoxDecoration(
                                          gradient: premiumGradient,
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                'Premium Fancy Bet',
                                                style: TextStyle(color: white, fontWeight: FontWeight.bold),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    showFancyRulesDialog(context);
                                                  },
                                                  child: Icon(Icons.info, color: whiteOpac, size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else if (showFancyOnlyTab)
                                      Container(
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: darkGreen,
                                          borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                isPolitics ? 'Election Fancy' : 'Fancy Bet',
                                                style: const TextStyle(color: white, fontWeight: FontWeight.bold),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: InkWell(
                                                  onTap: () {
                                                    showFancyRulesDialog(context);
                                                  },
                                                  child: Icon(Icons.info, color: whiteOpac, size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (showBothFancyAndPremiumTabs)
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            isFancyBet = !isFancyBet;
                                          });
                                        },
                                        child: Container(
                                          height: 30,
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: darkGreen,
                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              isFancyBet ? 'Premium Fancy Bet' : 'Fancy Bet',
                                              style: const TextStyle(color: white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () => toggleSection(MarketSection.fancy),
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(2)),
                                      child: Icon(expandedSections.contains(MarketSection.fancy) ? Icons.remove : Icons.add, color: white, size: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (expandedSections.contains(MarketSection.fancy))
                            if (showBothFancyAndPremiumTabs)
                              if (isFancyBet)
                                MvFancyMarkets(
                                  key: Key(state.fancyMarketData.values.map((e) => e.marketId).join(',')),
                                  eventId: widget.eventId,
                                  sid: widget.sid,
                                  fancyMarkets: state.fancyMarketData,
                                  favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null,
                                )
                              else
                                NewPremiumStreamer(eventId: widget.eventId, sid: widget.sid)
                            else if (showPremiumOnlyTab)
                              NewPremiumStreamer(eventId: widget.eventId, sid: widget.sid)
                            else if (showFancyOnlyTab)
                              MvFancyMarkets(
                                key: Key(state.fancyMarketData.values.map((e) => e.marketId).join(',')),
                                eventId: widget.eventId,
                                sid: widget.sid,
                                fancyMarkets: state.fancyMarketData,
                                favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null,
                              ),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
