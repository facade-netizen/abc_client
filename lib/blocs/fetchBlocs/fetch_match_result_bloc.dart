import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/sports/sports_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/result_model.dart';

class FetchMatchResultBloc extends Bloc<FetchMatchResultEvent, FetchMatchResultState> {
  final SportApiRepository _sportsApiRepository;
  FetchMatchResultBloc(this._sportsApiRepository) : super(FetchMatchResultInitial()) {
    on<FetchMatchResult>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchMatchResultBloc');
      emit(FetchMatchResultProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _sportsApiRepository.getResultMatch();
          if (response.body!.status == 200) {
            emit(FetchMatchResultSuccess(resultResponse: response.body!));
          } else {
            if (kDebugMode) debugPrint("fetch_result_match_bloc.dart [response error]>> ${response.body!.status}");
            emit(FetchMatchResultFailure('fetch_result_match_bloc.dart [response error]>> ${response.body!.status}'));
          }
        } else {
          emit(FetchMatchResultFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_result_match_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchMatchResultFailure(e));
      }
    });
  }
}

// states
abstract class FetchMatchResultState {}

// events
abstract class FetchMatchResultEvent {}

// states implementation
class FetchMatchResultInitial extends FetchMatchResultState {}

class FetchMatchResultProgress extends FetchMatchResultState {}

class FetchMatchResultSuccess extends FetchMatchResultState {
  FetchMatchResultSuccess({required this.resultResponse});
  final ResultResponse resultResponse;
}

class FetchMatchResultFailure extends FetchMatchResultState {
  FetchMatchResultFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchMatchResult extends FetchMatchResultEvent {}
