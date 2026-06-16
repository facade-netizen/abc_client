import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/fetchBlocs/fetch_all_events_for_search_bloc.dart';
import '../../../models/event_search_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/formatters.dart';
import '../../../reusables/sized_box_hw.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/navigators.dart';

void showSearchScreen(BuildContext context) {
  final searchController = TextEditingController();
  final allEvents = <SearchEvent>[];
  final results = <SearchEvent>[];
  var hasLoadedEvents = false;

  final bloc = context.read<FetchAllEventsForSearchBloc>();
  if (bloc.state is FetchAllEventsForSearchInitial) {
    bloc.add(FetchAllEventsForSearch());
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Search Events',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return StatefulBuilder(builder: (context, setState) {
        List<SearchEvent> filterEvents(String query) {
          final lowerQuery = query.toLowerCase();
          return allEvents.where((event) {
            return event.name.toLowerCase().contains(lowerQuery) || event.competition.toLowerCase().contains(lowerQuery) || event.venue.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                child: Container(
                  width: double.infinity,
                  color: searchController.text.isNotEmpty ? white : transparent,
                  child: Column(
                    children: [
                      Container(
                        color: white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              InkWell(
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: headerTextColor,
                                ),
                                onTap: () {
                                  removeScreen(context);
                                },
                              ),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: TextField(
                                    controller: searchController,
                                    autofocus: true,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(fontSize: 14, color: headerTextColor),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Search events',
                                      hintStyle: TextStyle(color: grey, fontSize: 14),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.trim().isEmpty) {
                                          results.clear();
                                        } else {
                                          results
                                            ..clear()
                                            ..addAll(filterEvents(value.trim()));
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              InkWell(
                                child: const Icon(Icons.close, color: headerTextColor, size: 30),
                                onTap: () {
                                  setState(() {
                                    searchController.clear();
                                    results.clear();
                                  });
                                },
                              ),
                              wb10,
                              InkWell(
                                child: const Icon(Icons.search, color: headerTextColor, size: 30),
                                onTap: () {
                                  setState(() {
                                    final query = searchController.text.trim();
                                    if (query.isEmpty) {
                                      results.clear();
                                    } else {
                                      results
                                        ..clear()
                                        ..addAll(filterEvents(query));
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: grey),
                      Expanded(
                        child: BlocBuilder<FetchAllEventsForSearchBloc, FetchAllEventsForSearchState>(
                          builder: (context, state) {
                            if (state is FetchAllEventsForSearchProgress) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is FetchAllEventsForSearchSuccess && !hasLoadedEvents) {
                              hasLoadedEvents = true;
                              allEvents
                                ..clear()
                                ..addAll(state.events);
                              final query = searchController.text.trim();
                              if (query.isNotEmpty) {
                                results
                                  ..clear()
                                  ..addAll(filterEvents(query));
                              }
                            }
                            if (results.isEmpty && searchController.text.trim().isNotEmpty) {
                              return Column(
                                children: [
                                  Icon(Icons.help, color: grey, size: 25),
                                  Text(
                                    'No events found matching...',
                                    style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: results.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final event = results[index];
                                return InkWell(
                                  onTap: () {
                                    final route = GoToRoute.sportEvent(
                                      sportId: event.sid,
                                      name: event.sid == '4'
                                          ? 'Cricket'
                                          : event.sid == '1'
                                              ? 'Soccer'
                                              : event.sid == '2'
                                                  ? 'Tennis'
                                                  : 'Sports',
                                      eventId: event.id,
                                      inPlay: event.inPlay,
                                      premium: event.premiumMatch,
                                      fancyMarket: event.fancyMarket,
                                    );
                                    final goRouter = GoRouter.of(context);
                                    Navigator.pop(context);
                                    Future.microtask(() {
                                      goRouter.go(route);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          getTimeFromDateTime(event.openDate),
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                        wb10,
                                        Expanded(
                                          child: Text(
                                            event.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    },
  );
}
