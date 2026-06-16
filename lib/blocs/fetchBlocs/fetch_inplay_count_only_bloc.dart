import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/inplay_count_model.dart';

class FetchOnlyInplayCountsBloc extends Bloc<FetchOnlyInplayCountsEvent, FetchOnlyInplayCountsState> {
  FetchOnlyInplayCountsBloc() : super(FetchOnlyInplayCountsInitial()) {
    on<FetchOnlyInplayCounts>((event, emit) async {
      emit(FetchOnlyInplayCountsProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.inPlayEvents}${0}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          // debugPrint(decoded.toString());
          InplayCountsResponse eventResponse = InplayCountsResponse.fromJson(decoded);
          final cricketCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "4").length);
          final tennisCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "2").length);
          final soccerCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "1").length);
          final gHondCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "4339").length);
          final hourseCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "7").length);
          final eleCount = eventResponse.data.fold(0, (count, sport) => count + sport.event.where((e) => e.id != '28127348' && e.inPlay == true && e.sid == "2378961").length);

          emit(
            FetchOnlyInplayCountsSuccess(
              cricketCount: cricketCount,
              tennisCount: tennisCount,
              soccerCount: soccerCount,
              gHondCount: gHondCount,
              hourseCount: hourseCount,
              eleCount: eleCount,
            ),
          );
        } else {
          if (kDebugMode) debugPrint("FetchOnlyInplayCountsBloc - non 200 response ${response.statusCode}");
          emit(FetchOnlyInplayCountsFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchOnlyInplayCountsBloc,$e");
        emit(FetchOnlyInplayCountsFailure(e));
      }
    });
  }
}

//states
abstract class FetchOnlyInplayCountsState {}

//events
abstract class FetchOnlyInplayCountsEvent {}

//states implementation
class FetchOnlyInplayCountsInitial extends FetchOnlyInplayCountsState {}

class FetchOnlyInplayCountsProgress extends FetchOnlyInplayCountsState {}

class FetchOnlyInplayCountsSuccess extends FetchOnlyInplayCountsState {
  final int cricketCount;
  final int tennisCount;
  final int soccerCount;
  final int gHondCount;
  final int hourseCount;
  final int eleCount;

  FetchOnlyInplayCountsSuccess({
    required this.cricketCount,
    required this.tennisCount,
    required this.soccerCount,
    required this.gHondCount,
    required this.hourseCount,
    required this.eleCount,
  });
}

class FetchOnlyInplayCountsFailure extends FetchOnlyInplayCountsState {
  final dynamic error;
  FetchOnlyInplayCountsFailure(this.error);
}

//events implementation
class FetchOnlyInplayCounts extends FetchOnlyInplayCountsEvent {}
