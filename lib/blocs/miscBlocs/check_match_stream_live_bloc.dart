import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class CheckMatchStreamLiveBloc extends Bloc<CheckMatchStreamLiveEvent, CheckMatchStreamLiveState> {
  CheckMatchStreamLiveBloc() : super(CheckMatchStreamLiveInitial()) {
    on<CheckMatchStreamLive>((event, emit) async {
      emit(CheckMatchStreamLiveProgress());
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedTokenData != null) {
        try {
          emit(CheckMatchStreamLiveSuccess(event.isLive, event.eventId));
        } catch (e) {
          emit(CheckMatchStreamLiveFailure(e));
        }
      } else {
        emit(CheckMatchStreamLiveFailure('User not logged in'));
      }
    });
  }
}

//states
abstract class CheckMatchStreamLiveState {}

//events
abstract class CheckMatchStreamLiveEvent {}

//states implementation
class CheckMatchStreamLiveInitial extends CheckMatchStreamLiveState {}

class CheckMatchStreamLiveProgress extends CheckMatchStreamLiveState {}

class CheckMatchStreamLiveSuccess extends CheckMatchStreamLiveState {
  CheckMatchStreamLiveSuccess(this.isLive, this.eventId);
  final bool isLive;
  final String eventId;
}

class CheckMatchStreamLiveFailure extends CheckMatchStreamLiveState {
  final dynamic error;
  CheckMatchStreamLiveFailure(this.error);
}

//events implementation
class CheckMatchStreamLive extends CheckMatchStreamLiveEvent {
  CheckMatchStreamLive(this.isLive, this.eventId);
  final bool isLive;
  final String eventId;
}
