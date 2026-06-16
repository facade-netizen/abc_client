import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../models/sportsbook_model.dart';

class FetchSportsBookHistoryBloc extends Bloc<FetchSportsBookHistoryEvent, FetchSportsBookHistoryState> {
  final CGApiRepository _cgApiRepository;
  FetchSportsBookHistoryBloc(this._cgApiRepository) : super(FetchSportsBookHistoryInitial()) {
    on<FetchSportsBookHistory>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportsBookHistoryBloc');
      emit(FetchSportsBookHistoryProgress());
      try {
        final Response<SportsBookResponse> response = await _cgApiRepository.getSportsBookHistory(event.status, event.fromDate ?? "", event.toDate ?? "", event.limit, event.page);
        if (response.statusCode == 200) {
          final responseBody = response.body!;
          final List<SportsBookModel> sportsBookData = responseBody.data;
          emit(
            FetchSportsBookHistorySuccess(
              sportsBookData: sportsBookData,
              page: responseBody.page,
              pageSize: responseBody.pageSize,
              totalPages: responseBody.totalPages,
              totalRecords: responseBody.totalRecords,
            ),
          );
        } else {
          if (kDebugMode) debugPrint("FetchSportsBookHistoryBloc - non 200 response ${response.statusCode}");
          emit(FetchSportsBookHistoryFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('FetchSportsBookHistoryBloc - exception: $e');
        emit(FetchSportsBookHistoryFailure(e));
      }
    });
    on<FetchSportsBookHistoryInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchSportsBookHistoryInt');
      emit(FetchSportsBookHistoryInitial());
    });
  }
}

//states
abstract class FetchSportsBookHistoryState {}

//events
abstract class FetchSportsBookHistoryEvent {}

//states implementation
class FetchSportsBookHistoryInitial extends FetchSportsBookHistoryState {}

class FetchSportsBookHistoryProgress extends FetchSportsBookHistoryState {}

class FetchSportsBookHistorySuccess extends FetchSportsBookHistoryState {
  final List<SportsBookModel> sportsBookData;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalRecords;

  FetchSportsBookHistorySuccess({required this.sportsBookData, required this.page, required this.pageSize, required this.totalPages, required this.totalRecords});
}

class FetchSportsBookHistoryFailure extends FetchSportsBookHistoryState {
  final dynamic error;
  FetchSportsBookHistoryFailure(this.error);
}

//events implementation
class FetchSportsBookHistory extends FetchSportsBookHistoryEvent {
  FetchSportsBookHistory({required this.status, this.fromDate, this.toDate, required this.limit, required this.page});
  final String status;
  final String? fromDate;
  final String? toDate;
  final int limit;
  final int page;
}

class FetchSportsBookHistoryInt extends FetchSportsBookHistoryEvent {}
