import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/scoreboardRepo/scoreboard_api_repo.dart';
import '../../models/scoreboard_model.dart';

class FetchScoreBoardBloc extends Bloc<FetchScoreBoardEvent, FetchScoreBoardState> {
  final ScoreBoardApiRepository _scoreBoardApiRepository;

  FetchScoreBoardBloc(this._scoreBoardApiRepository) : super(FetchScoreBoardInitial()) {
    on<FetchScoreBoard>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchScoreBoardBloc');
      emit(FetchScoreBoardProgress());

      try {
        final response = await _scoreBoardApiRepository.fetchScoreBoard(event.eventId);
        emit(FetchScoreBoardSuccess(scoreBoard: response));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('fetch_scoreboard_bloc.dart [Exception]>> \n $e');
        }
        emit(FetchScoreBoardFailure(e));
      }
    });
    on<SetToInitialFetchScoreBoard>((event, emit) async {
      emit(FetchScoreBoardInitial());
    });
  }
}

abstract class FetchScoreBoardState {}

class FetchScoreBoardInitial extends FetchScoreBoardState {}

class FetchScoreBoardProgress extends FetchScoreBoardState {}

class FetchScoreBoardSuccess extends FetchScoreBoardState {
  FetchScoreBoardSuccess({required this.scoreBoard});

  final ScoreBoardModel scoreBoard;
}

class FetchScoreBoardFailure extends FetchScoreBoardState {
  FetchScoreBoardFailure(this.error);
  final dynamic error;
}

abstract class FetchScoreBoardEvent {}

class FetchScoreBoard extends FetchScoreBoardEvent {
  FetchScoreBoard({required this.eventId});
  final int eventId;
}

class SetToInitialFetchScoreBoard extends FetchScoreBoardEvent {}
