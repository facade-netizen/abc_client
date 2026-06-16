import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../constants/app_string_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class AddCGMoneyBloc extends Bloc<AddCGMoneyEvent, AddCGMoneyState> {
  final CGApiRepository _cgApiRepository;
  AddCGMoneyBloc(this._cgApiRepository) : super(AddCGMoneyInitial()) {
    on<AddCGMoney>((event, emit) async {
      emit(AddCGMoneyProgress());
      if (kDebugMode) debugPrint('Called AddCGMoneyBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final Map<String, dynamic> finalMap = {
            ...event.addCGMoneyMap,
            "ip": ip.value.isEmpty ? "Blocked" : ip.value,
            "isp": isp.value.isEmpty ? "Blocked" : isp.value,
          };
          final response = await _cgApiRepository.addCGMoney(body: finalMap);
          if (response.statusCode == 200) {
            if (kDebugMode) debugPrint(response.bodyString);
            final decoded = jsonDecode(response.bodyString);
            final message = decoded['message'] ?? '';
            if (decoded['status'] == 200) {
              final data = decoded['data'] ?? '';
              final url = data['url'] ?? '';
              emit(AddCGMoneySuccess(message: message, url: url));
            } else {
              emit(AddCGMoneyFailure(error: message));
            }
          } else {
            if (kDebugMode) debugPrint("add_cg_money_bloc.dart [response error]>> ${response.statusCode}");
          }
        } else {
          emit(AddCGMoneyFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(AddCGMoneyFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class AddCGMoneyState {}

//events instantiation
abstract class AddCGMoneyEvent {}

//states implementation
class AddCGMoneyInitial extends AddCGMoneyState {}

class AddCGMoneyProgress extends AddCGMoneyState {}

class AddCGMoneySuccess extends AddCGMoneyState {
  AddCGMoneySuccess({required this.message, required this.url});
  final String message;
  final String url;
}

class AddCGMoneyFailure extends AddCGMoneyState {
  final dynamic error;
  AddCGMoneyFailure({this.error});
}

//events implementation
class AddCGMoney extends AddCGMoneyEvent {
  AddCGMoney({required this.addCGMoneyMap});
  final Map<String, dynamic> addCGMoneyMap;
}
