import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/sports/sports_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/result_model.dart';

class FetchLineResultBloc extends Bloc<FetchLineResultEvent, FetchLineResultState> {
  final SportApiRepository _sportsApiRepository;
  FetchLineResultBloc(this._sportsApiRepository) : super(FetchLineResultInitial()) {
    on<FetchLineResult>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchLineResultBloc');
      emit(FetchLineResultProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _sportsApiRepository.getResultLineMatch(isYesterDay: event.isYesterDay);
          if (response.status == 200) {
            emit(FetchLineResultSuccess(data: response.data));
          } else {
            if (kDebugMode) debugPrint("fetch_line_result_bloc.dart [response error]>> ${response.status}");
            emit(FetchLineResultFailure(response.message));
          }
        } else {
          emit(FetchLineResultFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_line_result_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchLineResultFailure(e));
      }
    });
  }
}

// states
abstract class FetchLineResultState {}

// events
abstract class FetchLineResultEvent {}

// states implementation
class FetchLineResultInitial extends FetchLineResultState {}

class FetchLineResultProgress extends FetchLineResultState {}

class FetchLineResultSuccess extends FetchLineResultState {
  FetchLineResultSuccess({required this.data});
  final List<ResultLineData> data;
}

class FetchLineResultFailure extends FetchLineResultState {
  FetchLineResultFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchLineResult extends FetchLineResultEvent {
  final bool isYesterDay;
  FetchLineResult({required this.isYesterDay});
}
