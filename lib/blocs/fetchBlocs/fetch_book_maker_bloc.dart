import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/book_maker_model.dart';

class FetchBookMakerBloc extends Bloc<FetchBookMakerEvent, FetchBookMakerState> {
  FetchBookMakerBloc() : super(FetchBookMakerInitial()) {
    on<FetchBookMaker>((event, emit) async {
      debugPrint("FetchBookMakerBloc Called");
      emit(FetchBookMakerProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.bookmaker}/${event.eventId}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          // debugPrint(decoded.toString());
          BMResponse eventResponse = BMResponse.fromJson(decoded);
          emit(FetchBookMakerSuccess(eventResponse: eventResponse));
        } else {
          if (kDebugMode) debugPrint("FetchBookMakerBloc - non 200 response ${response.statusCode}");
          emit(FetchBookMakerFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchBookMakerBloc,$e");
        emit(FetchBookMakerFailure(e));
      }
    });
    on<SetToInitialBM>((event, emit) async {
      emit(FetchBookMakerInitial());
    });
  }
}

//states
abstract class FetchBookMakerState {}

//events
abstract class FetchBookMakerEvent {}

//states implementation
class FetchBookMakerInitial extends FetchBookMakerState {}

class FetchBookMakerProgress extends FetchBookMakerState {}

class FetchBookMakerSuccess extends FetchBookMakerState {
  final BMResponse eventResponse;
  FetchBookMakerSuccess({required this.eventResponse});
}

class FetchBookMakerFailure extends FetchBookMakerState {
  final dynamic error;
  FetchBookMakerFailure(this.error);
}

//events implementation
class FetchBookMaker extends FetchBookMakerEvent {
  final String eventId;
  FetchBookMaker({required this.eventId});
}

class SetToInitialBM extends FetchBookMakerEvent {}
