import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/fancy_model.dart';
import '../signalr_event_listener_bloc.dart';

class SignalRFancyDataBloc extends Bloc<SignalRFancyDataEvent, SignalRFancyDataState> {
  final Map<String, FancyMarketData> fancyMap = {};
  StreamSubscription<Map<String, FancyMarketData>>? _subscription;
  Timer? _debounceTimer;

  SignalRFancyDataBloc() : super(SignalRFancyDataInitial()) {
    on<SignalRFancyDataListener>(_onListen);
    on<_EmitFancyInternal>(_onEmitFancy);
    on<_EmitFancyErrorInternal>(_onEmitFancyError);
    on<SetToInitialSignalRFancy>(_onReset);
  }

  // ---------------- LISTENER ----------------
  Future<void> _onListen(SignalRFancyDataListener event, Emitter<SignalRFancyDataState> emit) async {
    if (kDebugMode) debugPrint("SignalRFancyDataListener started");

    await _subscription?.cancel();
    fancyMap.clear();
    emit(SignalRFancyDataProgress());

    _subscription = lineStream.listen(
      (incomingMap) {
        bool changed = false;
        incomingMap.forEach((key, value) {
          final cleanKey = key.trim();
          final existing = fancyMap[cleanKey];
          if (existing != null) {
            if (_hasChanged(existing, value)) {
              fancyMap[cleanKey] = value;
              changed = true;
            }
            if (value.marketName == "2936299") log('Fancy data changed for key: ${value.marketName}, status: ${value.status},');
          } else {
            fancyMap[cleanKey] = value;
            changed = true;
          }
        });

        // Debounce emissions to reduce rebuild spam
        if (changed) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 50), () {
            add(_EmitFancyInternal(Map<String, FancyMarketData>.from(fancyMap)));
          });
        }
      },
      onError: (e) => add(_EmitFancyErrorInternal(e)),
    );
  }

  // ---------------- EMIT ----------------
  void _onEmitFancy(_EmitFancyInternal event, Emitter<SignalRFancyDataState> emit) {
    emit(SignalRFancyDataSuccess(event.data));
  }

  void _onEmitFancyError(_EmitFancyErrorInternal event, Emitter<SignalRFancyDataState> emit) {
    emit(SignalRFancyDataFailure(event.error));
  }

  // ---------------- RESET ----------------
  Future<void> _onReset(SetToInitialSignalRFancy event, Emitter<SignalRFancyDataState> emit) async {
    await _subscription?.cancel();
    _subscription = null;
    _debounceTimer?.cancel();
    fancyMap.clear();
    emit(SignalRFancyDataInitial());
  }

  // ---------------- CHANGE CHECK ----------------
  bool _hasChanged(FancyMarketData old, FancyMarketData updated) {
    if (old.status != updated.status) return true;
    if (old.sportingEvent != updated.sportingEvent) return true;
    if (old.runners.length != updated.runners.length) return true;
    if (old.marketCondition != updated.marketCondition) return true;

    for (int i = 0; i < old.runners.length; i++) {
      final o = old.runners[i];
      final u = updated.runners[i];

      final oldBackPrice = o.backs.isNotEmpty ? o.backs.first.price : null;
      final oldBackLine = o.backs.isNotEmpty ? o.backs.first.line : null;
      final oldLayPrice = o.lays.isNotEmpty ? o.lays.first.price : null;
      final oldLayLine = o.lays.isNotEmpty ? o.lays.first.line : null;

      final newBackPrice = u.backs.isNotEmpty ? u.backs.first.price : null;
      final newBackLine = u.backs.isNotEmpty ? u.backs.first.line : null;
      final newLayPrice = u.lays.isNotEmpty ? u.lays.first.price : null;
      final newLayLine = u.lays.isNotEmpty ? u.lays.first.line : null;

      if (oldBackPrice != newBackPrice || oldBackLine != newBackLine || oldLayPrice != newLayPrice || oldLayLine != newLayLine) {
        return true;
      }
    }
    return false;
  }

  // ---------------- DISPOSE ----------------
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

//
// EVENTS
//
abstract class SignalRFancyDataEvent {}

class SignalRFancyDataListener extends SignalRFancyDataEvent {}

class SetToInitialSignalRFancy extends SignalRFancyDataEvent {}

class _EmitFancyInternal extends SignalRFancyDataEvent {
  final Map<String, FancyMarketData> data;
  _EmitFancyInternal(this.data);
}

class _EmitFancyErrorInternal extends SignalRFancyDataEvent {
  final dynamic error;
  _EmitFancyErrorInternal(this.error);
}

//
// STATES
//
abstract class SignalRFancyDataState {}

class SignalRFancyDataInitial extends SignalRFancyDataState {}

class SignalRFancyDataProgress extends SignalRFancyDataState {}

class SignalRFancyDataSuccess extends SignalRFancyDataState {
  final Map<String, FancyMarketData> fancy;
  SignalRFancyDataSuccess(this.fancy);
}

class SignalRFancyDataFailure extends SignalRFancyDataState {
  final dynamic error;
  SignalRFancyDataFailure(this.error);
}
