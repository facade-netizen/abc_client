import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/runners_pl_model.dart';

class FetchOddsRunnerPLBloc extends Bloc<FetchOddsRunnerPLEvent, FetchOddsRunnerPLState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchOddsRunnerPLBloc(this._ordersApiRepository) : super(FetchOddsRunnerPLInitial()) {
    on<FetchOddsRunnerPL>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOddsRunnerPLBloc');
      emit(FetchOddsRunnerPLProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final Map<String, dynamic> data = {"marketIds": event.marketId, "eventIds": event.eventId, "bettingType": 0};

          final response = await _ordersApiRepository.getOddsRunnerPl(body: data);
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("Fancy ODDs Pl ${response.data.toString()}");
            emit(FetchOddsRunnerPLSuccess(runnerPl: response.data, eventId: event.eventId, marketId: event.marketId));
          } else {
            if (kDebugMode) debugPrint("fetch_odds_runners_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchOddsRunnerPLFailure('fetch_odds_runners_pl_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchOddsRunnerPLFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_odds_runners_pl_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchOddsRunnerPLFailure(e));
      }
    });
  }
}

// states
abstract class FetchOddsRunnerPLState {}

// events
abstract class FetchOddsRunnerPLEvent {}

// states implementation
class FetchOddsRunnerPLInitial extends FetchOddsRunnerPLState {}

class FetchOddsRunnerPLProgress extends FetchOddsRunnerPLState {}

class FetchOddsRunnerPLSuccess extends FetchOddsRunnerPLState {
  FetchOddsRunnerPLSuccess({required this.runnerPl, required this.eventId, required this.marketId});
  final List<OddsRunnerPLData> runnerPl;
  final String eventId;
  final String marketId;
}

class FetchOddsRunnerPLFailure extends FetchOddsRunnerPLState {
  FetchOddsRunnerPLFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchOddsRunnerPL extends FetchOddsRunnerPLEvent {
  FetchOddsRunnerPL({required this.eventId, required this.marketId});
  final String eventId;
  final String marketId;
}
