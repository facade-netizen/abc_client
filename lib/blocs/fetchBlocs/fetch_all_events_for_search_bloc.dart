import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/event_search_model.dart';

class FetchAllEventsForSearchBloc extends Bloc<FetchAllEventsForSearchEvent, FetchAllEventsForSearchState> {
  FetchAllEventsForSearchBloc() : super(FetchAllEventsForSearchInitial()) {
    on<FetchAllEventsForSearchSetToInit>(
      (event, emit) {
        if (kDebugMode) debugPrint('set to initial competetion bloc');
        emit(FetchAllEventsForSearchInitial());
      },
    );
    on<FetchAllEventsForSearch>((event, emit) async {
      emit(FetchAllEventsForSearchProgress());
      try {
        final responses = await Future.wait(["4", "1", "2"].map((evenTypeID) async {
          final sportEventUrl = '${SportsApiConstants.competition}/$evenTypeID';
          var request = http.Request('GET', Uri.parse(sportEventUrl));
          http.StreamedResponse response = await request.send();
          final bodyString = await response.stream.bytesToString();
          return {'id': evenTypeID, 'status': response.statusCode, 'body': bodyString};
        }));

        final successResponses = responses.where((item) => item['status'] == 200).toList();
        if (successResponses.isEmpty) {
          final first = responses.first;
          emit(FetchAllEventsForSearchFailure('Fetch failed (${first['status']})'));
          return;
        }

        final allEvents = <SearchEvent>[];
        for (final resp in successResponses) {
          final decoded = jsonDecode(resp['body'] as String);
          final response = SearchCompetitionResponse.fromJson(decoded);
          for (final competition in response.data.competitions) {
            allEvents.addAll(competition.events);
          }
        }

        emit(FetchAllEventsForSearchSuccess(events: allEvents));
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchAllEventsForSearchBloc,$e");
        emit(FetchAllEventsForSearchFailure(e));
      }
    });
  }
}

//states
abstract class FetchAllEventsForSearchState {}

//events
abstract class FetchAllEventsForSearchEvent {}

//states implementation
class FetchAllEventsForSearchInitial extends FetchAllEventsForSearchState {}

class FetchAllEventsForSearchProgress extends FetchAllEventsForSearchState {}

class FetchAllEventsForSearchSuccess extends FetchAllEventsForSearchState {
  final List<SearchEvent> events;
  FetchAllEventsForSearchSuccess({required this.events});
}

class FetchAllEventsForSearchFailure extends FetchAllEventsForSearchState {
  final dynamic error;
  FetchAllEventsForSearchFailure(this.error);
}

//events implementation
class FetchAllEventsForSearch extends FetchAllEventsForSearchEvent {}

class FetchAllEventsForSearchSetToInit extends FetchAllEventsForSearchEvent {}
