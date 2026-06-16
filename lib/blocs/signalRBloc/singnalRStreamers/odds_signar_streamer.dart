import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../signalr_event_listener_bloc.dart';

class SignalRODDSDataBloc extends Bloc<SignalRODDSDataEvent, SignalRODDSDataState> {
  SignalRODDSDataBloc() : super(SignalRODDSDataInitial()) {
    on<SignalRODDSDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRODDSDataListener started");
      emit(SignalRODDSDataProgress());

      try {
        await emit.forEach<ABCModel>(
          oddsStream,
          onData: (odds) {
            // if (kDebugMode) debugPrint("ODDS Receive [$odds]");
            // if (kDebugMode) {
            //   debugPrint("Odd Receive [ ${odds.eventId} | ${odds.runner.first.name} | ${odds.runner.last.name}| ${odds.runner.first.status} | ${odds.runner.last.status}]");
            // }
            return SignalRODDSDataSuccess(odds);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("ODDSData SignalR Error: $error");
            return SignalRODDSDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in ODDSsSignalRBloc: $e');
        emit(SignalRODDSDataFailure(e));
      }
    });

    on<SetToInitialSignalRTODDS>((event, emit) async {
      emit(SignalRODDSDataInitial());
    });
  }
}

//states
abstract class SignalRODDSDataState {}

//events
abstract class SignalRODDSDataEvent {}

//states implementation
class SignalRODDSDataInitial extends SignalRODDSDataState {}

class SignalRODDSDataProgress extends SignalRODDSDataState {}

class SignalRODDSDataSuccess extends SignalRODDSDataState {
  SignalRODDSDataSuccess(this.oddsData);
  ABCModel oddsData;
}

class SignalRODDSDataFailure extends SignalRODDSDataState {
  final dynamic error;
  SignalRODDSDataFailure(this.error);
}

//events implementation
class SignalRODDSDataListener extends SignalRODDSDataEvent {}

class SetToInitialSignalRTODDS extends SignalRODDSDataEvent {}
