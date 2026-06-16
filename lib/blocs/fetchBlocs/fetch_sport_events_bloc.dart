import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/event_with_type_model.dart';

class FetchSportEventsBloc extends Bloc<FetchSportEventsEvent, FetchSportEventsState> {
  FetchSportEventsBloc() : super(FetchSportEventsInitial()) {
    on<FetchSportEvents>((event, emit) async {
      emit(FetchSportEventsProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.sportsEvents}?evenTypeID=${event.evenTypeID}&tommorow=${event.tomorrow}&today=${event.today}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          // debugPrint(decoded.toString());
          SportsResponse eventResponse = SportsResponse.fromJson(decoded);
          final List<Event> allEvents = eventResponse.data.expand((sport) => sport.event).toList();
          emit(FetchSportEventsSuccess(eventResponse: eventResponse, events: allEvents));
        } else {
          if (kDebugMode) debugPrint("FetchSportEventsBloc - non 200 response ${response.statusCode}");
          emit(FetchSportEventsFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchSportEventsBloc,$e");
        emit(FetchSportEventsFailure(e));
      }
    });
  }
}

//states
abstract class FetchSportEventsState {}

//events
abstract class FetchSportEventsEvent {}

//states implementation
class FetchSportEventsInitial extends FetchSportEventsState {}

class FetchSportEventsProgress extends FetchSportEventsState {}

class FetchSportEventsSuccess extends FetchSportEventsState {
  final SportsResponse eventResponse;
  final List<Event> events;
  FetchSportEventsSuccess({required this.eventResponse, required this.events});
}

class FetchSportEventsFailure extends FetchSportEventsState {
  final dynamic error;
  FetchSportEventsFailure(this.error);
}

//events implementation
class FetchSportEvents extends FetchSportEventsEvent {
  final int evenTypeID;
  final bool tomorrow;
  final bool today;
  FetchSportEvents({required this.evenTypeID, required this.tomorrow, required this.today});
}
