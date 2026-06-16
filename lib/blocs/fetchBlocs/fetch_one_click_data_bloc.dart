import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/oneclick_bet_model.dart';

class FetchOneClickDataBloc extends Bloc<FetchOneClickDataEvent, FetchOneClickDataState> {
  final FavouriteApiRepository _favouriteApiRepository;
  FetchOneClickDataBloc(this._favouriteApiRepository) : super(FetchOneClickDataInitial()) {
    on<FetchOneClickData>((event, emit) async {
      emit(FetchOneClickDataProgress());
      if (kDebugMode) debugPrint('Called FetchOneClickDataBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.getOneClickData();
          if (response.statusCode == 200) {
            emit(FetchOneClickDataSuccess(oneClickData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_one_click_data_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOneClickDataFailure(error: 'fetch_one_click_data_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOneClickDataFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(FetchOneClickDataFailure(error: 'Catch Error >>>> $e'));
      }
    });
    on<SetToInitialFetchOneClickData>((event, emit) async {
      emit(FetchOneClickDataInitial());
    });
  }
}

//states instantiation
abstract class FetchOneClickDataState {}

//events instantiation
abstract class FetchOneClickDataEvent {}

//states implementation
class FetchOneClickDataInitial extends FetchOneClickDataState {}

class FetchOneClickDataProgress extends FetchOneClickDataState {}

class FetchOneClickDataSuccess extends FetchOneClickDataState {
  FetchOneClickDataSuccess({required this.oneClickData});
  final OneClickBetData oneClickData;
}

class FetchOneClickDataFailure extends FetchOneClickDataState {
  final dynamic error;
  FetchOneClickDataFailure({this.error});
}

//events implementation
class FetchOneClickData extends FetchOneClickDataEvent {}

class SetToInitialFetchOneClickData extends FetchOneClickDataEvent {}
