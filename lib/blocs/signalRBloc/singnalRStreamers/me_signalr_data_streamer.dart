import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../protoUsage/receive/receive.pb.dart';
import '../subscribe_multievents_signalr_bloc.dart';

class MultiEventsSignalRDataBloc extends Bloc<MultiEventsSignalRDataEvent, MultiEventsSignalRDataState> {
  MultiEventsSignalRDataBloc() : super(MultiEventsSignalRDataInitial()) {
    // Listen to buffered list stream
    on<MultiEventsSignalRDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("MultiEventsSignalRDataListener started");
      emit(MultiEventsSignalRDataProgress());

      try {
        await emit.forEach<List<ABCModel>>(
          multiEventsStream,
          onData: (meList) {
            return MultiEventsSignalRDataSuccess(meList);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("MultiEvents SignalR Error: $error");
            return MultiEventsSignalRDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in MultiEventsSignalRDataBloc: $e');
        emit(MultiEventsSignalRDataFailure(e));
      }
    });
  }
}

// STATES
abstract class MultiEventsSignalRDataState {}

class MultiEventsSignalRDataInitial extends MultiEventsSignalRDataState {}

class MultiEventsSignalRDataProgress extends MultiEventsSignalRDataState {}

// Now holds List<ABCModel> instead of single model
class MultiEventsSignalRDataSuccess extends MultiEventsSignalRDataState {
  MultiEventsSignalRDataSuccess(this.me);
  final List<ABCModel> me;
}

class MultiEventsSignalRDataFailure extends MultiEventsSignalRDataState {
  final dynamic error;
  MultiEventsSignalRDataFailure(this.error);
}

// EVENTS
abstract class MultiEventsSignalRDataEvent {}

class MultiEventsSignalRDataListener extends MultiEventsSignalRDataEvent {}

