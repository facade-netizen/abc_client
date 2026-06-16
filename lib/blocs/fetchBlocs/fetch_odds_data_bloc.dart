import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/odd_data_model.dart';

class FetchODDSDataBloc extends Bloc<FetchODDSDataEvent, FetchODDSDataState> {
  FetchODDSDataBloc() : super(FetchODDSDataInitial()) {
    on<FetchODDSData>((event, emit) async {
      debugPrint("FetchODDSDataBloc Called");
      emit(FetchODDSDataProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.odds}/${event.eventId}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          // debugPrint(decoded.toString());
          OddsResponse oddsResponse = OddsResponse.fromJson(decoded);
          emit(FetchODDSDataSuccess(oddsResponse: oddsResponse));
        } else {
          if (kDebugMode) debugPrint("FetchODDSDataBloc - non 200 response ${response.statusCode}");
          emit(FetchODDSDataFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchODDSDataBloc,$e");
        emit(FetchODDSDataFailure(e));
      }
    });
    on<SetToInitialODDS>((event, emit) async {
      emit(FetchODDSDataInitial());
    });
  }
}

//states
abstract class FetchODDSDataState {}

//events
abstract class FetchODDSDataEvent {}

//states implementation
class FetchODDSDataInitial extends FetchODDSDataState {}

class FetchODDSDataProgress extends FetchODDSDataState {}

class FetchODDSDataSuccess extends FetchODDSDataState {
  final OddsResponse oddsResponse;
  FetchODDSDataSuccess({required this.oddsResponse});
}

class FetchODDSDataFailure extends FetchODDSDataState {
  final dynamic error;
  FetchODDSDataFailure(this.error);
}

//events implementation
class FetchODDSData extends FetchODDSDataEvent {
  final String eventId;
  FetchODDSData({required this.eventId});
}

class SetToInitialODDS extends FetchODDSDataEvent {}
