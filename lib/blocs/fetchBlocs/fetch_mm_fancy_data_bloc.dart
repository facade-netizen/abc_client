import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/mm_fancy_model.dart';

class FetchMMFancyBloc extends Bloc<FetchMMFancyEvent, FetchMMFancyState> {
  final FavouriteApiRepository _favouriteApiRepository;
  FetchMMFancyBloc(this._favouriteApiRepository) : super(FetchMMFancyInitial()) {
    on<FetchMMFancy>((event, emit) async {
      emit(FetchMMFancyProgress());
      if (kDebugMode) debugPrint('Called FetchMMFancyBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.fetchMMFancy();
          if (response.statusCode == 200) {
            const blockedStatuses = {'active', 'suspended', 'online', 'open', 'suspend'};
            final filteredData = response.body!.data
                .map((outer) => outer.where((fancy) => blockedStatuses.contains(fancy.status.toLowerCase())).toList())
                .where((outer) => outer.isNotEmpty)
                .toList();
            emit(FetchMMFancySuccess(fancyMarketData: filteredData));
          } else {
            if (kDebugMode) debugPrint("fetch_mm_fancy_data_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchMMFancyFailure(error: 'fetch_mm_fancy_data_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchMMFancyFailure(error: "User not Logged in"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("fetch_mm_fancy_data_bloc.dart Catch Error >>>> $e");
        emit(FetchMMFancyFailure(error: 'Catch Error >>>> $e'));
      }
    });
    on<SetToInitialFetchMMFancy>((event, emit) async {
      emit(FetchMMFancyInitial());
    });
  }
}

//states instantiation
abstract class FetchMMFancyState {}

//events instantiation
abstract class FetchMMFancyEvent {}

//states implementation
class FetchMMFancyInitial extends FetchMMFancyState {}

class FetchMMFancyProgress extends FetchMMFancyState {}

class FetchMMFancySuccess extends FetchMMFancyState {
  FetchMMFancySuccess({required this.fancyMarketData});
  final List<List<MMFancyMarketData>> fancyMarketData;
}

class FetchMMFancyFailure extends FetchMMFancyState {
  final dynamic error;
  FetchMMFancyFailure({this.error});
}

//events implementation
class FetchMMFancy extends FetchMMFancyEvent {}

class SetToInitialFetchMMFancy extends FetchMMFancyEvent {}
