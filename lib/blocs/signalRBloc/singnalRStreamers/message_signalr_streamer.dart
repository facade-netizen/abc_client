import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../signalr_hub_listener_bloc.dart';

class SignalRMessageBloc extends Bloc<SignalRMessageEvent, SignalRMessageState> {
  SignalRMessageBloc() : super(SignalRMessageInitial()) {
    on<SignalRMessageListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRMessageListener started");
      emit(SignalRMessageProgress());

      try {
        await emit.forEach<String>(
          msgStream,
          onData: (msg) {
            final data = jsonDecode(msg) as Map<String, dynamic>;
            final status = data['status'] ?? 0;
            final message = data['message'] ?? '';
            return SignalRMessageSuccess(message, status);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("Account SignalR Error: $error");
            return SignalRMessageFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in SignalRMessageBloc: $e');
        emit(SignalRMessageFailure(e));
      }
    });

    on<SetToInitialSignalRMessage>((event, emit) async {
      emit(SignalRMessageInitial());
    });
  }
}

//states
abstract class SignalRMessageState {}

//events
abstract class SignalRMessageEvent {}

//states implementation
class SignalRMessageInitial extends SignalRMessageState {}

class SignalRMessageProgress extends SignalRMessageState {}

class SignalRMessageSuccess extends SignalRMessageState {
  SignalRMessageSuccess(this.message, this.status);
  int status;
  String message;
}

class SignalRMessageFailure extends SignalRMessageState {
  final dynamic error;
  SignalRMessageFailure(this.error);
}

//events implementation
class SignalRMessageListener extends SignalRMessageEvent {}

class SetToInitialSignalRMessage extends SignalRMessageEvent {}
