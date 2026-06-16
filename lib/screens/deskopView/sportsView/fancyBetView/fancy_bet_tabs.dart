import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../../../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../../../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../../../../constants/app_asset_constants.dart';
import '../../../../constants/lists/screen_string_list.dart';
import '../../../../localDb/token/login_token_model.dart';
import '../../../../models/event_with_type_model.dart';
import '../../../../models/fancy_model.dart';
import '../../../../models/fav_stake_model.dart';
import '../../../../models/mm_add_markets_model.dart';
import '../../../../reusables/colors.dart';
import '../../../../reusables/loader.dart';
import '../../../../reusables/sized_box_hw.dart';
import '../../authView/desktop_login_view.dart';
import 'fancy_bet_header.dart';
import 'fancy_bet_tile.dart';

class FancyBetStreamer extends StatelessWidget {
  const FancyBetStreamer({super.key, required this.event, this.favStakeData});
  final Event event;
  final FavStakeData? favStakeData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFancyDataBloc, FetchFancyDataState>(
      builder: (context, fds) {
        Map<String, FancyMarketData> fancyMarkets = {};
        if (fds is FetchFancyDataSuccess && fds.fancyMarketData.isNotEmpty) {
          fancyMarkets = fds.fancyMarketData;
        }
        return fds is FetchFancyDataProgress
            ? LoaderContainerWithMessage()
            : FancyBetTabs(
                event: event,
                favStakeData: favStakeData,
                fancyMarkets: fancyMarkets,
              );
      },
    );
  }
}

class FancyBetTabs extends StatefulWidget {
  const FancyBetTabs({
    super.key,
    required this.event,
    required this.fancyMarkets,
    this.favStakeData,
  });
  final FavStakeData? favStakeData;

  final Event event;
  final Map<String, FancyMarketData> fancyMarkets;

  @override
  State<FancyBetTabs> createState() => _FancyBetTabsState();
}

class _FancyBetTabsState extends State<FancyBetTabs> {
  int activeIndex = -1;
  int selectedTabIndex = 0;

  @override
  void initState() {
    final marketIds = widget.fancyMarkets.values.map((e) => e.marketId).join(',');
    if (marketIds.isNotEmpty) {
      context.read<FetchFancyRunnerPLBloc>().add(FetchFancyRunnerPL(eventId: widget.event.id.toString(), marketId: marketIds));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tabs
        if (widget.event.sid == "4")
          Container(
            height: 30,
            width: size.width,
            decoration: BoxDecoration(gradient: fancyGradient),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...marketTypes.asMap().entries.where((e) => e.key < 4).map((entry) {
                  final i = entry.key;
                  final tab = entry.value.replaceAll('_', ' ').toUpperCase();
                  return BetTabTile(
                    title: tab,
                    selectedTab: marketTypes[selectedTabIndex],
                    action: () {
                      if (selectedTabIndex == i) return;
                      setState(() {
                        selectedTabIndex = i;
                        activeIndex = -1;
                        final marketIds = widget.fancyMarkets.values
                            .where((m) => m.marketType == marketTypes[selectedTabIndex] || marketTypes[selectedTabIndex] == "All")
                            .map((e) => e.marketId)
                            .join(',');
                        context.read<FetchFancyRunnerPLBloc>().add(FetchFancyRunnerPL(eventId: widget.event.id.toString(), marketId: marketIds));
                      });
                    },
                  );
                }),

                /// More Dropdown
                if (marketTypes.length > 4)
                  PopupMenuButton<int>(
                    offset: const Offset(0, 25),
                    color: white,
                    tooltip: '',
                    onSelected: (i) {
                      setState(() {
                        selectedTabIndex = i;
                        activeIndex = -1;
                        final marketIds = widget.fancyMarkets.values
                            .where((m) => m.marketType == marketTypes[selectedTabIndex] || marketTypes[selectedTabIndex] == "All")
                            .map((e) => e.marketId)
                            .join(',');
                        context.read<FetchFancyRunnerPLBloc>().add(FetchFancyRunnerPL(eventId: widget.event.id.toString(), marketId: marketIds));
                      });
                    },
                    itemBuilder: (context) {
                      return marketTypes
                          .asMap()
                          .entries
                          .where((e) => e.key >= 4)
                          .map(
                            (e) => PopupMenuItem<int>(
                              height: 25,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              value: e.key,
                              child: Text(
                                e.value.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selectedTabIndex == e.key ? FontWeight.bold : FontWeight.normal,
                                  color: selectedTabIndex == e.key ? fancy : black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                          .toList();
                    },
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selectedTabIndex >= 4 ? white : none,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          "MORE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedTabIndex >= 4 ? fancy : white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        BlocBuilder<FetchAddedMMEventsBloc, FetchAddedMMEventsState>(
          builder: (context, fes) {
            List<AddedMMEventItem> favEvents = [];
            if (fes is FetchAddedMMEventsSuccess) {
              favEvents = fes.favEvents;
            }
            final isFav = favEvents.any((fav) => fav.eventId == widget.event.id && fav.favType == FavType.lines);
            return MultiBlocListener(
              listeners: [
                BlocListener<AddFavouriteEventsBloc, AddFavouriteEventsState>(
                  listenWhen: (prev, curr) => curr is AddFavouriteEventsSuccess && prev is! AddFavouriteEventsSuccess,
                  listener: (context, state) {
                    if (state is AddFavouriteEventsSuccess && state.eventId == widget.event.id) {
                      context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                    }
                  },
                ),
                BlocListener<RemoveFavouriteEventsBloc, RemoveFavouriteEventsState>(
                  listenWhen: (prev, curr) => curr is RemoveFavouriteEventsSuccess && prev is! RemoveFavouriteEventsSuccess,
                  listener: (context, state) {
                    if (state is RemoveFavouriteEventsSuccess && state.eventId == widget.event.id) {
                      context.read<FetchAddedMMEventsBloc>().add(FetchAddedMMEvents());
                    }
                  },
                ),
              ],
              child: BlocBuilder<UserAuthChangesBloc, UserAuthChangesState>(
                builder: (context, ucs) {
                  SaveLoginTokenModel? userLogedinSaveData;
                  if (ucs is UserAuthChangesSuccess) {
                    userLogedinSaveData = ucs.savedUserAuth;
                  }
                  return SportsBetHeader(
                    title: 'Fancy Bet',
                    leading: SvgPicture.asset(
                      isFav ? AppAssetConstants.removemarket : AppAssetConstants.pinblue,
                    ),
                    action: () {
                      if (userLogedinSaveData != null && userLogedinSaveData.userId != null) {
                        if (isFav) {
                          context.read<RemoveFavouriteEventsBloc>().add(RemoveFavouriteEvents(eventId: widget.event.id, favType: FavType.lines));
                        } else {
                          context.read<AddFavouriteEventsBloc>().add(AddFavouriteEvents(eventId: widget.event.id, favType: FavType.lines));
                        }
                      } else {
                        desktopLoginView(context);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),

        const YesNoTileHeader(),

        /// Market List (Merge → Remove → Filter)
        BlocBuilder<SignalRFancyDataBloc, SignalRFancyDataState>(
          builder: (context, state) {
            Map<String, FancyMarketData> mergedList = Map.from(widget.fancyMarkets);
            if (state is SignalRFancyDataSuccess) {
              state.fancy.forEach((key, value) {
                final cleanKey = value.marketId.trim();
                mergedList[cleanKey] = value;
              });
            }
            const blockedStatuses = {
              'closed',
              'removed',
              'removed_vacant',
              'inactive',
              'settled',
              'void',
              'voided',
              'offline',
              'settle_processing',
              'void_processing',
            };
            final selectedMarketType = marketTypes[selectedTabIndex];
            Map<String, FancyMarketData> filteredList = Map.fromEntries(
              (selectedMarketType == "All"
                      ? mergedList.entries
                      : mergedList.entries.where(
                          (entry) => entry.value.marketType == selectedMarketType,
                        ))
                  .where((entry) {
                final status = entry.value.status.toLowerCase();
                return !blockedStatuses.contains(status);
              }).toList()
                ..sort((a, b) {
                  // Primary: sort by marketType order defined in marketTypes list
                  final aTypeIdx = marketTypes.indexOf(a.value.marketType);
                  final bTypeIdx = marketTypes.indexOf(b.value.marketType);
                  final aTypeOrder = aTypeIdx == -1 ? marketTypes.length : aTypeIdx;
                  final bTypeOrder = bTypeIdx == -1 ? marketTypes.length : bTypeIdx;
                  if (aTypeOrder != bTypeOrder) return aTypeOrder.compareTo(bTypeOrder);
                  // Secondary: existing sorting field logic
                  final aSort = int.tryParse(a.value.sorting?.toString() ?? '0') ?? 0;
                  final bSort = int.tryParse(b.value.sorting?.toString() ?? '0') ?? 0;
                  final aIsWholePositive = aSort > 0;
                  final bIsWholePositive = bSort > 0;
                  if (aIsWholePositive && !bIsWholePositive) return -1;
                  if (!aIsWholePositive && bIsWholePositive) return 1;
                  if (aIsWholePositive && bIsWholePositive) {
                    return aSort.compareTo(bSort);
                  }
                  final aHasUnderscore = a.value.marketId.contains('_');
                  final bHasUnderscore = b.value.marketId.contains('_');
                  if (aHasUnderscore == bHasUnderscore) return 0;
                  return aHasUnderscore ? -1 : 1;
                }),
            );
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final market = filteredList.values.elementAt(index);
                return FancyBetTile(
                  favStakeData: widget.favStakeData,
                  fancyBet: market,
                  idx: index,
                  activeIndex: activeIndex,
                  eventId: widget.event.id,
                  action: (idx) => setState(() => activeIndex = idx),
                  marketType: market.marketType,
                  marketName: market.marketName,
                  eventName: widget.event.name,
                );
              },
            );
          },
        ),
        hb50,
      ],
    );
  }
}
