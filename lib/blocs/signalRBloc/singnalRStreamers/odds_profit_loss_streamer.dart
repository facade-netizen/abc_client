import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/runners_pl_model.dart';
import '../signalr_hub_listener_bloc.dart';

class OddsProfitLossBloc extends Bloc<OddsProfitLossEvent, OddsProfitLossState> {
  // Cache last successful data
  List<OddsRunnerPLData> _lastOddsData = [];

  OddsProfitLossBloc() : super(OddsProfitLossInitial()) {
    on<OddsProfitLossListener>((event, emit) async {
      if (kDebugMode) debugPrint("OddsProfitLossListener started");
      emit(OddsProfitLossProgress());

      try {
        await emit.forEach<List<OddsRunnerPLData>>(
          oddsPLStream,
          onData: (odds) {
            // CRITICAL FIX: Don't emit empty data if we have previous data
            if (odds.isEmpty && _lastOddsData.isNotEmpty) {
              // Keep previous data instead of clearing
              if (kDebugMode) debugPrint("OddsProfitLossBloc: Received empty data, keeping previous");
              return OddsProfitLossSuccess(_lastOddsData);
            }

            // Update cache if we got data
            if (odds.isNotEmpty) {
              _lastOddsData = odds;
            }

            for (var i in odds) {
              log('ODDS >> runnerId: ${i.runnerId} | net: ${i.net}');
            }
            return OddsProfitLossSuccess(odds);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) {
              debugPrint("ODDS SignalR Error: $error");
            }
            return OddsProfitLossFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in ODDSsSignalRBloc: $e');
        emit(OddsProfitLossFailure(e));
      }
    });

    on<SetToInitialOddsProfitLoss>((event, emit) async {
      _lastOddsData = []; // Clear cache on reset
      emit(OddsProfitLossInitial());
    });
  }
}

//states
abstract class OddsProfitLossState {}

//events
abstract class OddsProfitLossEvent {}

//states implementation
class OddsProfitLossInitial extends OddsProfitLossState {}

class OddsProfitLossProgress extends OddsProfitLossState {}

class OddsProfitLossSuccess extends OddsProfitLossState {
  OddsProfitLossSuccess(this.oddsPl);
  List<OddsRunnerPLData> oddsPl;
}

class OddsProfitLossFailure extends OddsProfitLossState {
  final dynamic error;
  OddsProfitLossFailure(this.error);
}

//events implementation
class OddsProfitLossListener extends OddsProfitLossEvent {}

class SetToInitialOddsProfitLoss extends OddsProfitLossEvent {}
