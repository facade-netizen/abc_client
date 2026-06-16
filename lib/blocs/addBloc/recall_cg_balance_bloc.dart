import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class RecallCGBalanceBloc extends Bloc<RecallCGBalanceEvent, RecallCGBalanceState> {
  final CGApiRepository _cgApiRepository;
  RecallCGBalanceBloc(this._cgApiRepository) : super(RecallCGBalanceInitial()) {
    on<RecallCGBalance>((event, emit) async {
      emit(RecallCGBalanceProgress());
      if (kDebugMode) debugPrint('Called RecallCGBalanceBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _cgApiRepository.withCGDrawMoney(body: event.recallCGBalanceMap);
          if (response.statusCode == 200) {
            if (kDebugMode) debugPrint(response.bodyString);
            final decoded = jsonDecode(response.bodyString);
            final message = decoded['message'] ?? '';
            if (decoded["status"] == 200) {
              emit(RecallCGBalanceSuccess());
            } else {
              emit(RecallCGBalanceFailure(error: '$message'));
            }
          } else {
            if (kDebugMode) debugPrint("recall_cg_balance_bloc.dart [response error]>> ${response.statusCode}");
            emit(RecallCGBalanceFailure(error: 'recall_cg_balance_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(RecallCGBalanceFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(RecallCGBalanceFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class RecallCGBalanceState {}

//events instantiation
abstract class RecallCGBalanceEvent {}

//states implementation
class RecallCGBalanceInitial extends RecallCGBalanceState {}

class RecallCGBalanceProgress extends RecallCGBalanceState {}

class RecallCGBalanceSuccess extends RecallCGBalanceState {}

class RecallCGBalanceFailure extends RecallCGBalanceState {
  final dynamic error;
  RecallCGBalanceFailure({this.error});
}

//events implementation
class RecallCGBalance extends RecallCGBalanceEvent {
  RecallCGBalance({required this.recallCGBalanceMap});
  final Map<String, dynamic> recallCGBalanceMap;
}
