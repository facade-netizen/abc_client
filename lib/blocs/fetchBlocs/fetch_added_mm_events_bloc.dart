import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/mm_add_markets_model.dart';

class FetchAddedMMEventsBloc extends Bloc<FetchAddedMMEventsEvent, FetchAddedMMEventsState> {
  final FavouriteApiRepository _favouriteApiRepository;
  FetchAddedMMEventsBloc(this._favouriteApiRepository) : super(FetchAddedMMEventsInitial()) {
    on<FetchAddedMMEvents>((event, emit) async {
      emit(FetchAddedMMEventsProgress());
      if (kDebugMode) debugPrint('Called FetchAddedMMEventsBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.fetchAddedFavEvent();
          if (response.statusCode == 200) {
            emit(FetchAddedMMEventsSuccess(favEvents: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchAddedMMEventsFailure(error: 'fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchAddedMMEventsFailure(error: "User not Logged in"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart Catch Error >>>> $e");
        emit(FetchAddedMMEventsFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class FetchAddedMMEventsState {}

//events instantiation
abstract class FetchAddedMMEventsEvent {}

//states implementation
class FetchAddedMMEventsInitial extends FetchAddedMMEventsState {}

class FetchAddedMMEventsProgress extends FetchAddedMMEventsState {}

class FetchAddedMMEventsSuccess extends FetchAddedMMEventsState {
  FetchAddedMMEventsSuccess({required this.favEvents});
  final List<AddedMMEventItem> favEvents;
}

class FetchAddedMMEventsFailure extends FetchAddedMMEventsState {
  final dynamic error;
  FetchAddedMMEventsFailure({this.error});
}

//events implementation
class FetchAddedMMEvents extends FetchAddedMMEventsEvent {}
