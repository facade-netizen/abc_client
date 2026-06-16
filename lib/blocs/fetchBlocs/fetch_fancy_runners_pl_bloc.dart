import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/runners_pl_model.dart';

class FetchFancyRunnerPLBloc extends Bloc<FetchFancyRunnerPLEvent, FetchFancyRunnerPLState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchFancyRunnerPLBloc(this._ordersApiRepository) : super(FetchFancyRunnerPLInitial()) {
    on<FetchFancyRunnerPL>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchFancyRunnerPLBloc');
      emit(FetchFancyRunnerPLProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final Map<String, dynamic> data = {"marketIds": event.marketId, "eventIds": event.eventId, "bettingType": 1};

          final response = await _ordersApiRepository.getFancyRunnerPl(body: data);
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("Fancy Runner ${response.data.toString()}");
            emit(FetchFancyRunnerPLSuccess(runnerPl: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_fancy_runners_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchFancyRunnerPLFailure('fetch_fancy_runners_pl_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          if (kDebugMode) debugPrint('User not logged in');
          emit(FetchFancyRunnerPLFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_fancy_runners_pl_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchFancyRunnerPLFailure(e));
      }
    });
  }
}

// states
abstract class FetchFancyRunnerPLState {}

// events
abstract class FetchFancyRunnerPLEvent {}

// states implementation
class FetchFancyRunnerPLInitial extends FetchFancyRunnerPLState {}

class FetchFancyRunnerPLProgress extends FetchFancyRunnerPLState {}

class FetchFancyRunnerPLSuccess extends FetchFancyRunnerPLState {
  FetchFancyRunnerPLSuccess({required this.runnerPl});
  final List<FancyRunnerPLData> runnerPl;
}

class FetchFancyRunnerPLFailure extends FetchFancyRunnerPLState {
  FetchFancyRunnerPLFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchFancyRunnerPL extends FetchFancyRunnerPLEvent {
  FetchFancyRunnerPL({required this.eventId, required this.marketId});
  final String eventId;
  final String marketId;
}
