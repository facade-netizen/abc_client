import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../models/casion_history_model.dart';

class FetchCGHistoryBloc extends Bloc<FetchCGHistoryEvent, FetchCGHistoryState> {
  final CGApiRepository _cgApiRepository;
  FetchCGHistoryBloc(this._cgApiRepository) : super(FetchCGHistoryInitial()) {
    on<FetchCGHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGHistoryBloc');
      emit(FetchCGHistoryProgress());
      try {
        final Response<CasinoHistoryResponse> response = await _cgApiRepository.getCGHistory(
          event.fromDate ?? '',
          event.toDate ?? '',
          event.limit ?? 10,
          event.page ?? 1,
        );
        if (response.statusCode == 200 && response.body != null) {
          final CasinoHistoryResponse responseBody = response.body!;
          emit(FetchCGHistorySuccess(response: responseBody));
        } else {
          if (kDebugMode) debugPrint("FetchCGHistoryBloc - non 200 response ${response.statusCode}");
          emit(FetchCGHistoryFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('FetchCGHistoryBloc - exception: $e');
        emit(FetchCGHistoryFailure(e));
      }
    });
    on<FetchCGHistoryInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGHistoryInt');
      emit(FetchCGHistoryInitial());
    });
  }
}

//states
abstract class FetchCGHistoryState {}

//events
abstract class FetchCGHistoryEvent {}

//states implementation
class FetchCGHistoryInitial extends FetchCGHistoryState {}

class FetchCGHistoryProgress extends FetchCGHistoryState {}

class FetchCGHistorySuccess extends FetchCGHistoryState {
  final CasinoHistoryResponse response;
  FetchCGHistorySuccess({required this.response});
}

class FetchCGHistoryFailure extends FetchCGHistoryState {
  final dynamic error;
  FetchCGHistoryFailure(this.error);
}

//events implementation
class FetchCGHistory extends FetchCGHistoryEvent {
  final String? fromDate;
  final String? toDate;
  final int? limit;
  final int? page;

  FetchCGHistory({this.fromDate, this.toDate, this.limit, this.page});
}

class FetchCGHistoryInt extends FetchCGHistoryEvent {}
