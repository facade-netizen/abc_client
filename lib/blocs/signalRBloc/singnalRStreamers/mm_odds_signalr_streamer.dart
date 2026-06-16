import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../signalr_mm_odds_bm_listener_bloc.dart';

class SignalRMMODDSDataBloc extends Bloc<SignalRMMODDSDataEvent, SignalRMMODDSDataState> {
  final Map<String, ABCModel> _marketOddsMap = {};

  SignalRMMODDSDataBloc() : super(SignalRMMODDSDataInitial()) {
    on<SignalRMMODDSDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRMMODDSDataListener started");
      emit(SignalRMMODDSDataProgress());

      try {
        await emit.forEach<ABCModel>(
          mmOddsStream,
          onData: (odds) {
            _marketOddsMap[odds.marketId] = odds;
            return SignalRMMODDSDataSuccess(odds, Map<String, ABCModel>.from(_marketOddsMap));
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("ODDSData SignalR Error: $error");
            return SignalRMMODDSDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in ODDSsSignalRBloc: $e');
        emit(SignalRMMODDSDataFailure(e));
      }
    });

    on<SetToInitialSignalRMMODDS>((event, emit) async {
      emit(SignalRMMODDSDataInitial());
    });
  }
}

//states
abstract class SignalRMMODDSDataState {}

//events
abstract class SignalRMMODDSDataEvent {}

//states implementation
class SignalRMMODDSDataInitial extends SignalRMMODDSDataState {}

class SignalRMMODDSDataProgress extends SignalRMMODDSDataState {}

class SignalRMMODDSDataSuccess extends SignalRMMODDSDataState {
  SignalRMMODDSDataSuccess(this.oddsData, this.oddsDataByMarket);
  final ABCModel oddsData;
  final Map<String, ABCModel> oddsDataByMarket;
}

class SignalRMMODDSDataFailure extends SignalRMMODDSDataState {
  final dynamic error;
  SignalRMMODDSDataFailure(this.error);
}

//events implementation
class SignalRMMODDSDataListener extends SignalRMMODDSDataEvent {}

class SetToInitialSignalRMMODDS extends SignalRMMODDSDataEvent {}
