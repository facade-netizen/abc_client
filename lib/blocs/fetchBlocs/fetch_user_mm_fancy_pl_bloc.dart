import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/user_mm_pl_model.dart';

class FetchUserMMFancyPLBloc extends Bloc<FetchUserMMFancyPLEvent, FetchUserMMFancyPLState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchUserMMFancyPLBloc(this._ordersApiRepository) : super(FetchUserMMFancyPLInitial()) {
    on<FetchUserMMFancyPL>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserMMFancyPLBloc');
      emit(FetchUserMMFancyPLProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getUserMatchProfitAndLossLine();
          if (response.status == 200) {
            // if (kDebugMode) debugPrint("Fancy Runner ${response.data.toString()}");
            emit(FetchUserMMFancyPLSuccess(runnerPl: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_user_mm_fancy_pl_bloc.dart [response error]>> ${response.status}");
            emit(FetchUserMMFancyPLFailure('fetch_user_mm_fancy_pl_bloc.dart [response error]>> ${response.status}'));
          }
        } else {
          emit(FetchUserMMFancyPLFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_user_mm_fancy_pl_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchUserMMFancyPLFailure(e));
      }
    });
     on<SetToInitialFetchUserMMFancyPL>((event, emit) async {
      emit(FetchUserMMFancyPLInitial());
    });
  }
}

// states
abstract class FetchUserMMFancyPLState {}

// events
abstract class FetchUserMMFancyPLEvent {}

// states implementation
class FetchUserMMFancyPLInitial extends FetchUserMMFancyPLState {}

class FetchUserMMFancyPLProgress extends FetchUserMMFancyPLState {}

class FetchUserMMFancyPLSuccess extends FetchUserMMFancyPLState {
  FetchUserMMFancyPLSuccess({required this.runnerPl});
  final List<UserMMPLFancyRunner> runnerPl;
}

class FetchUserMMFancyPLFailure extends FetchUserMMFancyPLState {
  FetchUserMMFancyPLFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchUserMMFancyPL extends FetchUserMMFancyPLEvent {}
class SetToInitialFetchUserMMFancyPL extends FetchUserMMFancyPLEvent {}
