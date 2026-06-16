import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../models/cg_balance_model.dart';

class FetchCGBalanceBloc extends Bloc<FetchCGBalanceEvent, FetchCGBalanceState> {
  final CGApiRepository _cgApiRepository;
  FetchCGBalanceBloc(this._cgApiRepository) : super(FetchCGBalanceInitial()) {
    on<FetchCGBalance>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCGBalanceBloc');
      emit(FetchCGBalanceProgress());
      try {
        final Response<CGBalanceResponse> response = await _cgApiRepository.getCGBalance(event.provider);
        if (response.statusCode == 200) {
          List<CGBalanceData> cgBalanceData = response.body!.data;
          emit(FetchCGBalanceSuccess(cgBalanceData: cgBalanceData));
        } else {
          if (kDebugMode) debugPrint("FetchCGBalanceBloc - non 200 response ${response.statusCode}");
          emit(FetchCGBalanceFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('');
        emit(FetchCGBalanceFailure(e));
      }
    });
  }
}

//states
abstract class FetchCGBalanceState {}

//events
abstract class FetchCGBalanceEvent {}

//states implementation
class FetchCGBalanceInitial extends FetchCGBalanceState {}

class FetchCGBalanceProgress extends FetchCGBalanceState {}

class FetchCGBalanceSuccess extends FetchCGBalanceState {
  List<CGBalanceData> cgBalanceData;
  FetchCGBalanceSuccess({required this.cgBalanceData});
}

class FetchCGBalanceFailure extends FetchCGBalanceState {
  final dynamic error;
  FetchCGBalanceFailure(this.error);
}

//events implementation
class FetchCGBalance extends FetchCGBalanceEvent {
  FetchCGBalance({required this.provider});
  final String provider;
}
