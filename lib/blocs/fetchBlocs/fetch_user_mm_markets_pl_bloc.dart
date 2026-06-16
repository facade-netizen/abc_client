import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/user_mm_pl_model.dart';

class FetchUserMMPLOddBMBloc extends Bloc<FetchUserMMPLOddBMEvent, FetchUserMMPLOddBMState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchUserMMPLOddBMBloc(this._ordersApiRepository) : super(FetchUserMMPLOddBMInitial()) {
    on<FetchUserMMPLOddBM>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserMMPLOddBMBloc');
      emit(FetchUserMMPLOddBMProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getUserMatchProfitAndLossOddAndBm();
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("Fancy Runner ${response.data.toString()}");
            emit(FetchUserMMPLOddBMSuccess(runnerPl: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_user_mm_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchUserMMPLOddBMFailure('fetch_user_mm_pl_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchUserMMPLOddBMFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_user_mm_pl_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchUserMMPLOddBMFailure(e));
      }
    });
    on<SetToInitialFetchUserMMPLOddBM>((event, emit) async {
      emit(FetchUserMMPLOddBMInitial());
    });
  }
}

// states
abstract class FetchUserMMPLOddBMState {}

// events
abstract class FetchUserMMPLOddBMEvent {}

// states implementation
class FetchUserMMPLOddBMInitial extends FetchUserMMPLOddBMState {}

class FetchUserMMPLOddBMProgress extends FetchUserMMPLOddBMState {}

class FetchUserMMPLOddBMSuccess extends FetchUserMMPLOddBMState {
  FetchUserMMPLOddBMSuccess({required this.runnerPl});
  final List<UserMMOddBMPlMarket> runnerPl;
}

class FetchUserMMPLOddBMFailure extends FetchUserMMPLOddBMState {
  FetchUserMMPLOddBMFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchUserMMPLOddBM extends FetchUserMMPLOddBMEvent {}

class SetToInitialFetchUserMMPLOddBM extends FetchUserMMPLOddBMEvent {}
