import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/competation_with_events_model.dart';

class FetchCompetitionWithEventsBloc extends Bloc<FetchCompetitionWithEventsEvent, FetchCompetitionWithEventsState> {
  FetchCompetitionWithEventsBloc() : super(FetchCompetitionWithEventsInitial()) {
    on<FetchCompetitionWithEventsSetToInit>(
      (event, emit) {
        if (kDebugMode) debugPrint('set to initial competetion bloc');
        emit(FetchCompetitionWithEventsInitial());
      },
    );
    on<FetchCompetitionWithEvents>((event, emit) async {
      emit(FetchCompetitionWithEventsProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.competition}/${event.evenTypeID}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          CompetitionResponse eventResponse = CompetitionResponse.fromJson(decoded);
          final List<Competition> competationData = eventResponse.data.competitions
              .map((competition) => Competition(
                    id: competition.id,
                    name: competition.name,
                    events: competition.events.toList(),
                  ))
              .toList();
          emit(FetchCompetitionWithEventsSuccess(competitionResponse: eventResponse, competationData: competationData, eventId: event.evenTypeID));
        } else {
          if (kDebugMode) debugPrint("FetchCompetitionWithEventsBloc - non 200 response ${response.statusCode}");
          emit(FetchCompetitionWithEventsFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchCompetitionWithEventsBloc,$e");
        emit(FetchCompetitionWithEventsFailure(e));
      }
    });
  }
}

//states
abstract class FetchCompetitionWithEventsState {}

//events
abstract class FetchCompetitionWithEventsEvent {}

//states implementation
class FetchCompetitionWithEventsInitial extends FetchCompetitionWithEventsState {}

class FetchCompetitionWithEventsProgress extends FetchCompetitionWithEventsState {}

class FetchCompetitionWithEventsSuccess extends FetchCompetitionWithEventsState {
  final CompetitionResponse competitionResponse;
  final List<Competition> competationData;
  final String eventId;
  FetchCompetitionWithEventsSuccess({required this.competitionResponse, required this.competationData, required this.eventId});
}

class FetchCompetitionWithEventsFailure extends FetchCompetitionWithEventsState {
  final dynamic error;
  FetchCompetitionWithEventsFailure(this.error);
}

//events implementation
class FetchCompetitionWithEvents extends FetchCompetitionWithEventsEvent {
  final String evenTypeID;
  FetchCompetitionWithEvents({required this.evenTypeID});
}

class FetchCompetitionWithEventsSetToInit extends FetchCompetitionWithEventsEvent {}
