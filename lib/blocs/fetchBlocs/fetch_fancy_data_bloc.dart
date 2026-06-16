import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/fancy_model.dart';

class FetchFancyDataBloc extends Bloc<FetchFancyDataEvent, FetchFancyDataState> {
  FetchFancyDataBloc() : super(FetchFancyDataInitial()) {
    on<FetchFancyData>((event, emit) async {
      debugPrint("FetchFancyDataBloc Called");
      emit(FetchFancyDataProgress());
      try {
        final sportEventUrl = '${SportsApiConstants.fancy}/${event.eventId}';
        var request = http.Request('GET', Uri.parse(sportEventUrl));
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          final bodyString = await response.stream.bytesToString();
          final decoded = jsonDecode(bodyString);
          Map<String, dynamic> fancyDataMap = decoded;
          // List<FancyMarketData> fanyMap = FancyMarketResponse.fromJson(fancyDataMap).data.toList();
          List<FancyMarketData> fancyList = FancyMarketResponse.fromJson(fancyDataMap).data.where((fancy) {
            final status = fancy.status.toLowerCase();
            const blockedStatuses = {'active', 'suspended', 'online', 'open'};
            return blockedStatuses.contains(status);
          }).toList();
          Map<String, FancyMarketData> fancyMarketData = {for (var fm in fancyList) fm.marketId: fm};
          emit(FetchFancyDataSuccess(fancyMarketData: fancyMarketData));
        } else {
          if (kDebugMode) debugPrint("FetchFancyDataBloc - non 200 response ${response.statusCode}");
          emit(FetchFancyDataFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Error caught in FetchFancyDataBloc,$e");
        emit(FetchFancyDataFailure(e));
      }
    });
    on<SetToInitialFancy>((event, emit) async {
      emit(FetchFancyDataInitial());
    });
  }
}

//states
abstract class FetchFancyDataState {}

//events
abstract class FetchFancyDataEvent {}

//states implementation
class FetchFancyDataInitial extends FetchFancyDataState {}

class FetchFancyDataProgress extends FetchFancyDataState {}

class FetchFancyDataSuccess extends FetchFancyDataState {
  final Map<String, FancyMarketData> fancyMarketData;
  FetchFancyDataSuccess({required this.fancyMarketData});
}

class FetchFancyDataFailure extends FetchFancyDataState {
  final dynamic error;
  FetchFancyDataFailure(this.error);
}

//events implementation
class FetchFancyData extends FetchFancyDataEvent {
  final String eventId;
  FetchFancyData({required this.eventId});
}

class SetToInitialFancy extends FetchFancyDataEvent {}
