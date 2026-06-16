import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/mm_fancy_model.dart';
import '../signalr_mm_fancy_listener_bloc.dart';

class SignalRMMFancyDataBloc extends Bloc<SignalRMMFancyDataEvent, SignalRMMFancyDataState> {
  final Map<String, MMFancyMarketData> fancyMap = {};
  StreamSubscription<Map<String, MMFancyMarketData>>? _subscription;
  Timer? _debounceTimer;

  SignalRMMFancyDataBloc() : super(SignalRMMFancyDataInitial()) {
    on<SignalRMMFancyDataListener>(_onListen);
    on<_EmitFancyInternal>(_onEmitFancy);
    on<_EmitFancyErrorInternal>(_onEmitFancyError);
    on<SetToInitialSignalRMMFancy>(_onReset);
  }

  // ---------------- LISTENER ----------------
  Future<void> _onListen(SignalRMMFancyDataListener event, Emitter<SignalRMMFancyDataState> emit) async {
    if (kDebugMode) debugPrint("SignalRMMFancyDataListener started");

    await _subscription?.cancel();
    fancyMap.clear();
    emit(SignalRMMFancyDataProgress());

    _subscription = lineMMStream.listen(
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
            add(_EmitFancyInternal(Map<String, MMFancyMarketData>.from(fancyMap)));
          });
        }
      },
      onError: (e) => add(_EmitFancyErrorInternal(e)),
    );
  }

  // ---------------- EMIT ----------------
  void _onEmitFancy(_EmitFancyInternal event, Emitter<SignalRMMFancyDataState> emit) {
    emit(SignalRMMFancyDataSuccess(event.data));
  }

  void _onEmitFancyError(_EmitFancyErrorInternal event, Emitter<SignalRMMFancyDataState> emit) {
    emit(SignalRMMFancyDataFailure(event.error));
  }

  // ---------------- RESET ----------------
  Future<void> _onReset(SetToInitialSignalRMMFancy event, Emitter<SignalRMMFancyDataState> emit) async {
    await _subscription?.cancel();
    _subscription = null;
    _debounceTimer?.cancel();
    fancyMap.clear();
    emit(SignalRMMFancyDataInitial());
  }

  // ---------------- CHANGE CHECK ----------------
  bool _hasChanged(MMFancyMarketData old, MMFancyMarketData updated) {
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
abstract class SignalRMMFancyDataEvent {}

class SignalRMMFancyDataListener extends SignalRMMFancyDataEvent {}

class SetToInitialSignalRMMFancy extends SignalRMMFancyDataEvent {}

class _EmitFancyInternal extends SignalRMMFancyDataEvent {
  final Map<String, MMFancyMarketData> data;
  _EmitFancyInternal(this.data);
}

class _EmitFancyErrorInternal extends SignalRMMFancyDataEvent {
  final dynamic error;
  _EmitFancyErrorInternal(this.error);
}

//
// STATES
//
abstract class SignalRMMFancyDataState {}

class SignalRMMFancyDataInitial extends SignalRMMFancyDataState {}

class SignalRMMFancyDataProgress extends SignalRMMFancyDataState {}

class SignalRMMFancyDataSuccess extends SignalRMMFancyDataState {
  final Map<String, MMFancyMarketData> fancy;
  SignalRMMFancyDataSuccess(this.fancy);
}

class SignalRMMFancyDataFailure extends SignalRMMFancyDataState {
  final dynamic error;
  SignalRMMFancyDataFailure(this.error);
}
