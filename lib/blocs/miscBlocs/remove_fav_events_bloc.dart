import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../addBloc/add_favourite_event_bloc.dart';

class RemoveFavouriteEventsBloc extends Bloc<RemoveFavouriteEventsEvent, RemoveFavouriteEventsState> {
  final FavouriteApiRepository _favouriteApiRepository;
  RemoveFavouriteEventsBloc(this._favouriteApiRepository) : super(RemoveFavouriteEventsInitial()) {
    on<RemoveFavouriteEvents>((event, emit) async {
      emit(RemoveFavouriteEventsProgress());
      if (kDebugMode) debugPrint('Called RemoveFavouriteEventsBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null && event.favType != FavType.na) {
          final Map<String, dynamic> removeMMEventMap = {
            "marketId": event.marketId ?? "",
            "eventId": event.eventId,
            "userId": savedTokenData.userId,
            "type": formatFavType(event.favType),
          };
          final response = await _favouriteApiRepository.removeFavouriteEvents(body: removeMMEventMap);
          if (response.statusCode == 200) {
            if (kDebugMode) debugPrint(response.bodyString);
            final decoded = jsonDecode(response.bodyString);
            final message = decoded['message'] ?? '';
            emit(RemoveFavouriteEventsSuccess(message: message, eventId: event.eventId));
          } else {
            if (kDebugMode) debugPrint("remove_fav_events_bloc.dart [response error]>> ${response.statusCode}");
            emit(RemoveFavouriteEventsFailure(error: 'remove_fav_events_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(RemoveFavouriteEventsFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(RemoveFavouriteEventsFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class RemoveFavouriteEventsState {}

//events instantiation
abstract class RemoveFavouriteEventsEvent {}

//states implementation
class RemoveFavouriteEventsInitial extends RemoveFavouriteEventsState {}

class RemoveFavouriteEventsProgress extends RemoveFavouriteEventsState {}

class RemoveFavouriteEventsSuccess extends RemoveFavouriteEventsState {
  RemoveFavouriteEventsSuccess({required this.message, this.eventId});
  final String message;
  final String? eventId;
}

class RemoveFavouriteEventsFailure extends RemoveFavouriteEventsState {
  final dynamic error;
  RemoveFavouriteEventsFailure({this.error});
}

//events implementation
class RemoveFavouriteEvents extends RemoveFavouriteEventsEvent {
  RemoveFavouriteEvents({
    required this.eventId,
    this.marketId,
    required this.favType,
  });
  final String eventId;
  final String? marketId;
  final FavType favType;
}
