import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../signalRBloc/single_user_login_session_streamer.dart';

class UserLogoutBloc extends Bloc<UserLogoutEvent, UserLogoutState> {
  UserLogoutBloc() : super(UserLogoutInitial()) {
    on<UserLogoutListener>((event, emit) async {
      if (kDebugMode) debugPrint('Called UserLogoutBloc');
      emit(UserLogoutProgress());
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData != null && savedData.token != null && savedData.validTill != null) {
        userLogoutSessionStreamController.close();
        await SaveTokenBox.loginTokenBox.clearLoginToken();
        emit(UserLogoutSuccess());
      } else {
        emit(UserLogoutFailure());
      }
    });
  }
}

//states
abstract class UserLogoutState {}

//events
abstract class UserLogoutEvent {}

//states implementation
class UserLogoutInitial extends UserLogoutState {}

class UserLogoutProgress extends UserLogoutState {}

class UserLogoutSuccess extends UserLogoutState {
  UserLogoutSuccess();
}

class UserLogoutFailure extends UserLogoutState {}

//events implementation
class UserLogoutListener extends UserLogoutEvent {}
