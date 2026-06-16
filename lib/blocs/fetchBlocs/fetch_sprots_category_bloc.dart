import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/sport_category_model.dart';

class FetchSportsCategoryBloc extends Bloc<FetchSportsCategoryEvent, FetchSportsCategoryState> {
  FetchSportsCategoryBloc() : super(FetchSportsCategoryInitial()) {
    on<FetchSportsCategory>((event, emit) async {
      emit(FetchSportsCategoryProgress());
      try {
        var request = http.Request('GET', Uri.parse(SportsApiConstants.eventTypes));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          EventTypeResponse eventResponse = EventTypeResponse.fromJson(decoded);
          final filteredEventResponse = EventTypeResponse(
            status: eventResponse.status,
            message: eventResponse.message,
            data: eventResponse.data.where((item) => item.id != "7" && item.id != "4339").toList(),
          );
          emit(FetchSportsCategorySuccess(categoryResponse: filteredEventResponse));
        } else {
          if (kDebugMode) debugPrint("FetchSportEventsBloc - non 200 response ${response.statusCode}");
          emit(FetchSportsCategoryFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchSportsCategoryBloc,$e");
        emit(FetchSportsCategoryFailure(e));
      }
    });
  }
}

//states
abstract class FetchSportsCategoryState {}

//events
abstract class FetchSportsCategoryEvent {}

//states implementation
class FetchSportsCategoryInitial extends FetchSportsCategoryState {}

class FetchSportsCategoryProgress extends FetchSportsCategoryState {}

class FetchSportsCategorySuccess extends FetchSportsCategoryState {
  final EventTypeResponse categoryResponse;
  FetchSportsCategorySuccess({required this.categoryResponse});
}

class FetchSportsCategoryFailure extends FetchSportsCategoryState {
  final dynamic error;
  FetchSportsCategoryFailure(this.error);
}

//events implementation
class FetchSportsCategory extends FetchSportsCategoryEvent {}
