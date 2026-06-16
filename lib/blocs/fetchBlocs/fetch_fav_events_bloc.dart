import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/favourite_model.dart';

class FetchFavouriteBloc extends Bloc<FetchFavouriteEvent, FetchFavouriteState> {
  final FavouriteApiRepository _favouriteApiRepository;
  FetchFavouriteBloc(this._favouriteApiRepository) : super(FetchFavouriteInitial()) {
    on<FetchFavourite>((event, emit) async {
      emit(FetchFavouriteProgress());
      if (kDebugMode) debugPrint('Called FetchFavouriteBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.fetchFavEvent();
          if (response.statusCode == 200) {
            emit(FetchFavouriteSuccess(favEvents: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchFavouriteFailure(error: 'fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchFavouriteFailure(error: "User not Logged in"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart Catch Error >>>> $e");
        emit(FetchFavouriteFailure(error: 'Catch Error >>>> $e'));
      }
    });
    on<SetToInitialFetchFavourite>((event, emit) async {
      emit(FetchFavouriteInitial());
    });
  }
}

//states instantiation
abstract class FetchFavouriteState {}

//events instantiation
abstract class FetchFavouriteEvent {}

//states implementation
class FetchFavouriteInitial extends FetchFavouriteState {}

class FetchFavouriteProgress extends FetchFavouriteState {}

class FetchFavouriteSuccess extends FetchFavouriteState {
  FetchFavouriteSuccess({required this.favEvents});
  final List<FavouriteEventData> favEvents;
}

class FetchFavouriteFailure extends FetchFavouriteState {
  final dynamic error;
  FetchFavouriteFailure({this.error});
}

//events implementation
class FetchFavourite extends FetchFavouriteEvent {}

class SetToInitialFetchFavourite extends FetchFavouriteEvent {}
