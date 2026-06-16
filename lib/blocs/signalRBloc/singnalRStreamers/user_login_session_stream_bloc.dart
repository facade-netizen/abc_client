import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../single_user_login_session_streamer.dart';

class UserSessionStreamBloc extends Bloc<UserSessionStreamEvent, UserSessionStreamState> {
  UserSessionStreamBloc() : super(UserSessionStreamInitial()) {
    on<UserSessionStreamListener>((event, emit) async {
      if (kDebugMode) debugPrint("UserSessionStreamListener started");
      emit(UserSessionStreamProgress());
      try {
        await emit.forEach<String>(
          userLogoutSessionStream,
          onData: (msg) {
            return UserSessionStreamSuccess(msg.toLowerCase());
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("UserSessionStreamBloc SignalR Error: $error");
            return UserSessionStreamFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in UserSessionStreamBloc: $e');
        emit(UserSessionStreamFailure(e));
      }
    });

    on<SetToInitialUserSessionStream>((event, emit) async {
      emit(UserSessionStreamInitial());
    });
  }
}

//states
abstract class UserSessionStreamState {}

//events
abstract class UserSessionStreamEvent {}

//states implementation
class UserSessionStreamInitial extends UserSessionStreamState {}

class UserSessionStreamProgress extends UserSessionStreamState {}

class UserSessionStreamSuccess extends UserSessionStreamState {
  UserSessionStreamSuccess(this.message);
  String message;
}

class UserSessionStreamFailure extends UserSessionStreamState {
  final dynamic error;
  UserSessionStreamFailure(this.error);
}

//events implementation
class UserSessionStreamListener extends UserSessionStreamEvent {}

class SetToInitialUserSessionStream extends UserSessionStreamEvent {}
