import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';

class FetchLMTMatchIdBloc extends Bloc<FetchLMTMatchIdEvent, FetchLMTMatchIdState> {
  FetchLMTMatchIdBloc() : super(FetchLMTMatchIdInitial()) {
    on<FetchLMTMatchId>((event, emit) async {
      emit(FetchLMTMatchIdProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.baseUrl}getSRId/${event.eventID}/${event.sportName}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          final matchId = (decoded['data'] as String?)?.replaceFirst(RegExp(r'^sr:match:'), '') ?? '';
          emit(FetchLMTMatchIdSuccess(matchId: matchId));
        } else {
          if (kDebugMode) debugPrint("FetchLMTMatchIdBloc - non 200 response ${response.statusCode}");
          emit(FetchLMTMatchIdFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchLMTMatchIdBloc,$e");
        emit(FetchLMTMatchIdFailure(e));
      }
    });
  }
}

//states
abstract class FetchLMTMatchIdState {}

//events
abstract class FetchLMTMatchIdEvent {}

//states implementation
class FetchLMTMatchIdInitial extends FetchLMTMatchIdState {}

class FetchLMTMatchIdProgress extends FetchLMTMatchIdState {}

class FetchLMTMatchIdSuccess extends FetchLMTMatchIdState {
  final String matchId;
  FetchLMTMatchIdSuccess({required this.matchId});
}

class FetchLMTMatchIdFailure extends FetchLMTMatchIdState {
  final dynamic error;
  FetchLMTMatchIdFailure(this.error);
}

//events implementation
class FetchLMTMatchId extends FetchLMTMatchIdEvent {
  final String eventID;
  final String sportName;

  FetchLMTMatchId({required this.eventID, required this.sportName});
}
