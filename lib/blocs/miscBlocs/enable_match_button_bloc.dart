import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class EnableMatchButtonBloc extends Bloc<EnableMatchButtonEvent, EnableMatchButtonState> {
  EnableMatchButtonBloc() : super(EnableMatchButtonInitial()) {
    on<EnableMatchButton>((event, emit) async {
      emit(EnableMatchButtonProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedTokenData != null) {
        try {
          emit(EnableMatchButtonSuccess(event.isLive, event.eventId));
        } catch (e) {
          if (kDebugMode) log('', name: '', error: e);
          emit(EnableMatchButtonFailure(e));
        }
      } else {
        emit(EnableMatchButtonFailure('User not logged in'));
      }
    });
  }
}

//states
abstract class EnableMatchButtonState {}

//events
abstract class EnableMatchButtonEvent {}

//states implementation
class EnableMatchButtonInitial extends EnableMatchButtonState {}

class EnableMatchButtonProgress extends EnableMatchButtonState {}

class EnableMatchButtonSuccess extends EnableMatchButtonState {
  EnableMatchButtonSuccess(this.isLive, this.eventId);
  final bool isLive;
  final String eventId;
}

class EnableMatchButtonFailure extends EnableMatchButtonState {
  final dynamic error;
  EnableMatchButtonFailure(this.error);
}

//events implementation
class EnableMatchButton extends EnableMatchButtonEvent {
  EnableMatchButton(this.isLive, this.eventId);
  final bool isLive;
  final String eventId;
}
