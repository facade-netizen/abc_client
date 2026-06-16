import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/runners_pl_model.dart';
import '../signalr_hub_listener_bloc.dart';

class FancyProfitLossBloc extends Bloc<FancyProfitLossEvent, FancyProfitLossState> {
  List<FancyRunnerPLData> _lastFancyData = [];

  FancyProfitLossBloc() : super(FancyProfitLossInitial()) {
    on<FancyProfitLossListener>((event, emit) async {
      if (kDebugMode) debugPrint("FancyProfitLossListener started");
      emit(FancyProfitLossProgress());

      try {
        await emit.forEach<List<FancyRunnerPLData>>(
          fancyPLStream,
          onData: (fancy) {
            // Don't emit empty data if we have previous data
            if (fancy.isEmpty && _lastFancyData.isNotEmpty) {
              if (kDebugMode) debugPrint("FancyProfitLossBloc: Received empty data, keeping previous");
              return FancyProfitLossSuccess(_lastFancyData);
            }

            if (fancy.isNotEmpty) {
              _lastFancyData = fancy;
            }

            for (var i in fancy) {
              log('FANCY >> runnerId: ${i.runnerId} | net: ${i.net}');
            }
            return FancyProfitLossSuccess(fancy);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) {
              debugPrint("Fancy SignalR Error: $error");
            }
            return FancyProfitLossFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in FancyProfitLossBloc: $e');
        emit(FancyProfitLossFailure(e));
      }
    });

    on<SetToInitialFancyProfitLoss>((event, emit) async {
      _lastFancyData = [];
      emit(FancyProfitLossInitial());
    });
  }
}

//states
abstract class FancyProfitLossState {}

//events
abstract class FancyProfitLossEvent {}

//states implementation
class FancyProfitLossInitial extends FancyProfitLossState {}

class FancyProfitLossProgress extends FancyProfitLossState {}

class FancyProfitLossSuccess extends FancyProfitLossState {
  FancyProfitLossSuccess(this.fancyPl);
  List<FancyRunnerPLData> fancyPl;
}

class FancyProfitLossFailure extends FancyProfitLossState {
  final dynamic error;
  FancyProfitLossFailure(this.error);
}

//events implementation
class FancyProfitLossListener extends FancyProfitLossEvent {}

class SetToInitialFancyProfitLoss extends FancyProfitLossEvent {}
