import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../../../blocs/fetchBlocs/fetch_sport_events_bloc.dart';
import '../../../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../../../models/event_with_type_model.dart';
import '../../../reusables/data_not_found.dart';
import '../../../reusables/loader.dart';
import '../../../routing/app_router.dart';
import '../../../routing/route_navigation_helper.dart';
import '../../../services/web_new_tab_service.dart';
import '../inplayView/inplay_event_tile.dart';
import '../inplayView/inplay_filter_card.dart';
import '../sportsReusables/sports_header.dart';

String? subscribedSingleTodayEventId;

class NewTodayStreamer extends StatefulWidget {
  const NewTodayStreamer({super.key});

  @override
  State<NewTodayStreamer> createState() => _NewTodayStreamerState();
}

class _NewTodayStreamerState extends State<NewTodayStreamer> {
  @override
  void initState() {
    context.read<FetchSportEventsBloc>().add(FetchSportEvents(evenTypeID: 0, tomorrow: false, today: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchSportEventsBloc, FetchSportEventsState>(
      builder: (context, fes) {
        List<Sport> eventData = [];
        if (fes is FetchSportEventsSuccess) {
          eventData = fes.eventResponse.data;
          eventData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        }

        return fes is FetchSportEventsProgress
            ? LoaderContainerWithMessage()
            : fes is FetchSportEventsSuccess && eventData.isNotEmpty
            ? NewTodayScreen(eventData: eventData)
            : const DataNotFound(message: 'Event not available');
      },
    );
  }
}

class NewTodayScreen extends StatefulWidget {
  const NewTodayScreen({super.key, required this.eventData});
  final List<Sport> eventData;

  @override
  State<NewTodayScreen> createState() => _NewTodayScreenState();
}

class _NewTodayScreenState extends State<NewTodayScreen> {
  List<String> sportsList = [];

  void _openSportTabForEvent({required Sport sport, required Event event}) {
    subscribedSingleTodayEventId = event.id;
    isRefreshed = false;
    context.read<FetchCompetitionWithEventsBloc>().add(FetchCompetitionWithEvents(evenTypeID: sport.id));
    context.read<SignalREventListenerBloc>().add(SignalREventListener(eventId: event.id));
    context.go(GoToRoute.sportEvent(sportId: sport.id, name: sport.name, eventId: event.id, inPlay: event.inPlay, premium: event.premiumMatch));
  }

  @override
  Widget build(BuildContext context) {
    final filteredSports = sportsList.isEmpty || sportsList.contains('All') ? widget.eventData : widget.eventData.where((sport) => sportsList.contains(sport.name)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final middleWidth = screenWidth * 0.70 - 20;
        final rightWidth = screenWidth * 0.30;

        return SizedBox(
          width: screenWidth,
          child: Row(
            children: [
              SizedBox(
                width: middleWidth,
                child: Column(
                  children: [
                    InplayFilterCard(
                      sportsList: sportsList,
                      onFilterSelected: (selectedList) {
                        setState(() {
                          sportsList = selectedList;
                        });
                      },
                    ),
                    Expanded(
                      child: filteredSports.isEmpty
                          ? const DataNotFound(message: 'There are no events to be displayed.')
                          : ListView.builder(
                              itemCount: filteredSports.length,
                              itemBuilder: (context, index) {
                                final sport = filteredSports[index];
                                return Column(
                                  children: sport.event.map((eve) {
                                    return RightClickWrapper(
                                      route: GoToRoute.sportEvent(
                                        sportId: sport.id,
                                        name: sport.name,
                                        eventId: eve.id,
                                        inPlay: eve.inPlay,
                                        premium: eve.premiumMatch,
                                        fancyMarket: eve.fancyMarket,
                                      ),
                                      child: InplayEventTile(
                                        sport: sport,
                                        eve: eve,
                                        action: () {
                                          _openSportTabForEvent(sport: sport, event: eve);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(width: rightWidth, child: const SportsBetSlip()),
            ],
          ),
        );
      },
    );
  }
}
