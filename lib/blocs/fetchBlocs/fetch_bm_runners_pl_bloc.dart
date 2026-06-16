import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/runners_pl_model.dart';

class FetchBMRunnerPLBloc extends Bloc<FetchBMRunnerPLEvent, FetchBMRunnerPLState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchBMRunnerPLBloc(this._ordersApiRepository) : super(FetchBMRunnerPLInitial()) {
    on<FetchBMRunnerPL>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchBMRunnerPLBloc');
      emit(FetchBMRunnerPLProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final Map<String, dynamic> data = {"marketIds": event.marketId, "eventIds": event.eventId, "bettingType": 2};

          final response = await _ordersApiRepository.getBMRunnerPl(body: data);
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("BM Runner Pl${response.data.toString()}");
            emit(FetchBMRunnerPLSuccess(runnerPl: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_bm_runners_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchBMRunnerPLFailure('fetch_bm_runners_pl_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchBMRunnerPLFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_bm_runners_pl_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchBMRunnerPLFailure(e));
      }
    });
  }
}

// states
abstract class FetchBMRunnerPLState {}

// events
abstract class FetchBMRunnerPLEvent {}

// states implementation
class FetchBMRunnerPLInitial extends FetchBMRunnerPLState {}

class FetchBMRunnerPLProgress extends FetchBMRunnerPLState {}

class FetchBMRunnerPLSuccess extends FetchBMRunnerPLState {
  FetchBMRunnerPLSuccess({required this.runnerPl});
  final List<BMRunnerPLData> runnerPl;
}

class FetchBMRunnerPLFailure extends FetchBMRunnerPLState {
  FetchBMRunnerPLFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchBMRunnerPL extends FetchBMRunnerPLEvent {
  FetchBMRunnerPL({required this.eventId, required this.marketId});
  final String eventId;
  final String marketId;
}
