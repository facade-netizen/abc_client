import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class GetMarketIDBloc extends Bloc<GetMarketIDEvent, GetMarketIDState> {
  GetMarketIDBloc() : super(GetMarketIDInitial()) {
    on<GetMarketID>((event, emit) async {
      emit(GetMarketIDProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedTokenData != null) {
        try {
          emit(GetMarketIDSuccess(event.bmMarketId ?? '', event.fancyMarketId ?? ''));
        } catch (e) {
          if (kDebugMode) log('', name: '', error: e);
          emit(GetMarketIDFailure(e));
        }
      } else {
        emit(GetMarketIDFailure('User not logged in'));
      }
    });
  }
}

//states
abstract class GetMarketIDState {}

//events
abstract class GetMarketIDEvent {}

//states implementation
class GetMarketIDInitial extends GetMarketIDState {}

class GetMarketIDProgress extends GetMarketIDState {}

class GetMarketIDSuccess extends GetMarketIDState {
  GetMarketIDSuccess(this.bmMarketId, this.fancyMarketId);
  final String bmMarketId;
  final String fancyMarketId;
}

class GetMarketIDFailure extends GetMarketIDState {
  final dynamic error;
  GetMarketIDFailure(this.error);
}

//events implementation
class GetMarketID extends GetMarketIDEvent {
  GetMarketID(this.bmMarketId, this.fancyMarketId);

  final String? bmMarketId;
  final String? fancyMarketId;
}
