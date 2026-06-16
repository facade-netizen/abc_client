import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../signalr_event_listener_bloc.dart';

class SignalRBMDataBloc extends Bloc<SignalRBMDataEvent, SignalRBMDataState> {
  SignalRBMDataBloc() : super(SignalRBMDataInitial()) {
    on<SignalRBMDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRBMDataListener started");
      emit(SignalRBMDataProgress());

      try {
        await emit.forEach<ABCModel>(
          bmStream,
          onData: (bm) {
            //if (kDebugMode) debugPrint("BOOKMAKER Receive [BettingType - ${bm.bettingType} |   ${bm.eventId} | ${bm.runner.first.name} | ${bm.runner.last.name}  | ${bm..marketId}  | ${bm..marketId} | ${bm.runner.first.status}]");
            // if (kDebugMode) debugPrint("BOOKMAKER Receive [ ${bm.eventId} | ${bm.runner.first.name} | ${bm.runner.last.name}| ${bm.runner.first.status} | ${bm.runner.last.status}]");
            return SignalRBMDataSuccess(bm);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("BOOKMAKER SignalR Error: $error");
            return SignalRBMDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in SignalRBMDataBloc: $e');
        emit(SignalRBMDataFailure(e));
      }
    });

    on<SetToInitialSignalRBM>((event, emit) async {
      emit(SignalRBMDataInitial());
    });
  }
}

//states
abstract class SignalRBMDataState {}

//events
abstract class SignalRBMDataEvent {}

//states implementation
class SignalRBMDataInitial extends SignalRBMDataState {}

class SignalRBMDataProgress extends SignalRBMDataState {}

class SignalRBMDataSuccess extends SignalRBMDataState {
  SignalRBMDataSuccess(this.bm);
  ABCModel bm;
}

class SignalRBMDataFailure extends SignalRBMDataState {
  final dynamic error;
  SignalRBMDataFailure(this.error);
}

//events implementation
class SignalRBMDataListener extends SignalRBMDataEvent {}

class SetToInitialSignalRBM extends SignalRBMDataEvent {}
