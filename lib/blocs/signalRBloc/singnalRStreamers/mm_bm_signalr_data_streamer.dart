import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../signalr_mm_odds_bm_listener_bloc.dart';

class SignalRMMBMDataBloc extends Bloc<SignalRMMBMDataEvent, SignalRMMBMDataState> {
  SignalRMMBMDataBloc() : super(SignalRMMBMDataInitial()) {
    on<SignalRMMBMDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRMMBMDataListener started");
      emit(SignalRMMBMDataProgress());

      try {
        await emit.forEach<ABCModel>(
          mmBmStream,
          onData: (bm) {
            //if (kDebugMode) debugPrint("BOOKMAKER Receive [BettingType - ${bm.bettingType} |   ${bm.eventId} | ${bm.runner.first.name} | ${bm.runner.last.name}  | ${bm..marketId}  | ${bm..marketId} | ${bm.runner.first.status}]");
            // if (kDebugMode) debugPrint("BOOKMAKER Receive [ ${bm.eventId} | ${bm.runner.first.name} | ${bm.runner.last.name}| ${bm.runner.first.status} | ${bm.runner.last.status}]");
            return SignalRMMBMDataSuccess(bm);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("BOOKMAKER SignalR Error: $error");
            return SignalRMMBMDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in SignalRMMBMDataBloc: $e');
        emit(SignalRMMBMDataFailure(e));
      }
    });

    on<SetToInitialSignalRMMBM>((event, emit) async {
      emit(SignalRMMBMDataInitial());
    });
  }
}

//states
abstract class SignalRMMBMDataState {}

//events
abstract class SignalRMMBMDataEvent {}

//states implementation
class SignalRMMBMDataInitial extends SignalRMMBMDataState {}

class SignalRMMBMDataProgress extends SignalRMMBMDataState {}

class SignalRMMBMDataSuccess extends SignalRMMBMDataState {
  SignalRMMBMDataSuccess(this.bm);
  ABCModel bm;
}

class SignalRMMBMDataFailure extends SignalRMMBMDataState {
  final dynamic error;
  SignalRMMBMDataFailure(this.error);
}

//events implementation
class SignalRMMBMDataListener extends SignalRMMBMDataEvent {}

class SetToInitialSignalRMMBM extends SignalRMMBMDataEvent {}
