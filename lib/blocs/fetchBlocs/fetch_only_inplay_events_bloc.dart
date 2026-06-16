import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/event_with_type_model.dart';

class FetchOnlyInplayEventsBloc extends Bloc<FetchOnlyInplayEventsEvent, FetchOnlyInplayEventsState> {
  FetchOnlyInplayEventsBloc() : super(FetchOnlyInplayEventsInitial()) {
    on<FetchOnlyInplayEvents>((event, emit) async {
      emit(FetchOnlyInplayEventsProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.inPlayEvents}${0}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          // debugPrint(decoded.toString());
          SportsResponse eventResponse = SportsResponse.fromJson(decoded);
          final List<Event> allEvents = eventResponse.data.expand((sport) => sport.event).where((e) => e.id != '28127348').toList();
          emit(FetchOnlyInplayEventsSuccess(eventResponse: eventResponse, events: allEvents));
        } else {
          if (kDebugMode) debugPrint("FetchOnlyInplayEventsBloc - non 200 response ${response.statusCode}");
          emit(FetchOnlyInplayEventsFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchOnlyInplayEventsBloc,$e");
        emit(FetchOnlyInplayEventsFailure(e));
      }
    });
  }
}

//states
abstract class FetchOnlyInplayEventsState {}

//events
abstract class FetchOnlyInplayEventsEvent {}

//states implementation
class FetchOnlyInplayEventsInitial extends FetchOnlyInplayEventsState {}

class FetchOnlyInplayEventsProgress extends FetchOnlyInplayEventsState {}

class FetchOnlyInplayEventsSuccess extends FetchOnlyInplayEventsState {
  final SportsResponse eventResponse;
  final List<Event> events;
  FetchOnlyInplayEventsSuccess({required this.eventResponse, required this.events});
}

class FetchOnlyInplayEventsFailure extends FetchOnlyInplayEventsState {
  final dynamic error;
  FetchOnlyInplayEventsFailure(this.error);
}

//events implementation
class FetchOnlyInplayEvents extends FetchOnlyInplayEventsEvent {}
