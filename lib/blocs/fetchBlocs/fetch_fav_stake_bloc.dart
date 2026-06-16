import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/fav_stake_model.dart';

class FetchFavStakeBloc extends Bloc<FetchFavStakeEvent, FetchFavStakeState> {
  final FavouriteApiRepository _favouriteApiRepository;
  FetchFavStakeBloc(this._favouriteApiRepository) : super(FetchFavStakeInitial()) {
    on<FetchFavStake>((event, emit) async {
      emit(FetchFavStakeProgress());
      if (kDebugMode) debugPrint('Called FetchFavStakeBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.getFavStake();
          if (response.statusCode == 200) {
            emit(FetchFavStakeSuccess(favStakeData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchFavStakeFailure(error: 'fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchFavStakeFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(FetchFavStakeFailure(error: 'Catch Error >>>> $e'));
      }
    });
    on<SetToInitialFetchFavStake>((event, emit) async {
      emit(FetchFavStakeInitial());
    });
  }
}

//states instantiation
abstract class FetchFavStakeState {}

//events instantiation
abstract class FetchFavStakeEvent {}

//states implementation
class FetchFavStakeInitial extends FetchFavStakeState {}

class FetchFavStakeProgress extends FetchFavStakeState {}

class FetchFavStakeSuccess extends FetchFavStakeState {
  FetchFavStakeSuccess({required this.favStakeData});
  final FavStakeData favStakeData;
}

class FetchFavStakeFailure extends FetchFavStakeState {
  final dynamic error;
  FetchFavStakeFailure({this.error});
}

//events implementation
class FetchFavStake extends FetchFavStakeEvent {}

class SetToInitialFetchFavStake extends FetchFavStakeEvent {}
