import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/runners_pl_model.dart';
import '../signalr_hub_listener_bloc.dart';

class BmProfitLossBloc extends Bloc<BmProfitLossEvent, BmProfitLossState> {
  BmProfitLossBloc() : super(BmProfitLossInitial()) {
    on<BmProfitLossListener>((event, emit) async {
      if (kDebugMode) debugPrint("BmProfitLossListener started");
      emit(BmProfitLossProgress());

      try {
        await emit.forEach<List<BMRunnerPLData>>(
          bmPLStream,
          onData: (bm) {
            for (var i in bm) {
              log('BM >> runnerId: ${i.runnerId} | net: ${i.net}');
            }
            return BmProfitLossSuccess(bm);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) {
              debugPrint("BM SignalR Error: $error");
            }
            return BmProfitLossFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in BmProfitLossBloc: $e');
        emit(BmProfitLossFailure(e));
      }
    });

    on<SetToInitialBmProfitLoss>((event, emit) async {
      emit(BmProfitLossInitial());
    });
  }
}

//states
abstract class BmProfitLossState {}

//events
abstract class BmProfitLossEvent {}

//states implementation
class BmProfitLossInitial extends BmProfitLossState {}

class BmProfitLossProgress extends BmProfitLossState {}

class BmProfitLossSuccess extends BmProfitLossState {
  BmProfitLossSuccess(this.bmPl);
  List<BMRunnerPLData> bmPl;
}

class BmProfitLossFailure extends BmProfitLossState {
  final dynamic error;
  BmProfitLossFailure(this.error);
}

//events implementation
class BmProfitLossListener extends BmProfitLossEvent {}

class SetToInitialBmProfitLoss extends BmProfitLossEvent {}
