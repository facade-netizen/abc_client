import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user_details_model.dart';
import '../signalr_hub_listener_bloc.dart';

class SignalRAccountDataBloc extends Bloc<SignalRAccountDataEvent, SignalRAccountDataState> {
  UserAccountDetails? _lastEmittedAccount;
  bool _shouldEmit = false;
  bool _hasAccountDetailsChanged(UserAccountDetails? previous, UserAccountDetails current) {
    if (previous == null) return true;
    return previous.balancePoint != current.balancePoint || previous.exposure != current.exposure;
  }

  SignalRAccountDataBloc() : super(SignalRAccountDataInitial()) {
    on<SignalRAccountDataListener>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRAccountDataListener started");
      emit(SignalRAccountDataProgress());

      try {
        await emit.forEach<UserAccountDetails>(
          accountStream,
          onData: (account) {
            _shouldEmit = _hasAccountDetailsChanged(_lastEmittedAccount, account);
            if (_shouldEmit) {
              _lastEmittedAccount = account;
              return SignalRAccountDataSuccess(_lastEmittedAccount!);
            } else {
              return state;
            }
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("Account SignalR Error: $error");
            return SignalRAccountDataFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in SignalRAccountDataBloc: $e');
        emit(SignalRAccountDataFailure(e));
      }
    });

    on<SetToInitialSignalRAccount>((event, emit) async {
      _lastEmittedAccount = null;
      _shouldEmit = false;
      emit(SignalRAccountDataInitial());
    });
  }
}

//states
abstract class SignalRAccountDataState {}

//events
abstract class SignalRAccountDataEvent {}

//states implementation
class SignalRAccountDataInitial extends SignalRAccountDataState {}

class SignalRAccountDataProgress extends SignalRAccountDataState {}

class SignalRAccountDataSuccess extends SignalRAccountDataState {
  SignalRAccountDataSuccess(this.accountDetails);
  UserAccountDetails accountDetails;
}

class SignalRAccountDataFailure extends SignalRAccountDataState {
  final dynamic error;
  SignalRAccountDataFailure(this.error);
}

//events implementation
class SignalRAccountDataListener extends SignalRAccountDataEvent {}

class SetToInitialSignalRAccount extends SignalRAccountDataEvent {}
