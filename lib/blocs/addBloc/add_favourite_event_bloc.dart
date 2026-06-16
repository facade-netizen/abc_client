import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

enum FavType { odds, bookmaker, line, lines, na }

String formatFavType(FavType type) {
  switch (type) {
    case FavType.odds:
      return 'Odd';
    case FavType.bookmaker:
      return 'BookMaker';
    case FavType.line:
      return 'Line';
    case FavType.lines:
      return 'Lines';
    case FavType.na:
      return 'N/A';
  }
}

class AddFavouriteEventsBloc extends Bloc<AddFavouriteEventsEvent, AddFavouriteEventsState> {
  final FavouriteApiRepository _favouriteApiRepository;
  AddFavouriteEventsBloc(this._favouriteApiRepository) : super(AddFavouriteEventsInitial()) {
    on<AddFavouriteEvents>((event, emit) async {
      emit(AddFavouriteEventsProgress());
      if (kDebugMode) debugPrint('Called AddFavouriteEventsBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null && event.favType != FavType.na) {
          final Map<String, dynamic> favEventMap = {
            "marketId": event.marketId ?? "",
            "eventId": event.eventId,
            "userId": savedTokenData.userId,
            "type": formatFavType(event.favType),
          };
          final response = await _favouriteApiRepository.addFavouriteEvents(body: favEventMap);
          if (response.statusCode == 200) {
            if (kDebugMode) debugPrint(response.bodyString);
            final decoded = jsonDecode(response.bodyString);
            final message = decoded['message'] ?? '';
            emit(AddFavouriteEventsSuccess(message: message, eventId: event.eventId));
          } else {
            if (kDebugMode) debugPrint("add_favourite_event_bloc.dart [response error]>> ${response.statusCode}");
            emit(AddFavouriteEventsFailure(error: 'add_favourite_event_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(AddFavouriteEventsFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(AddFavouriteEventsFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class AddFavouriteEventsState {}

//events instantiation
abstract class AddFavouriteEventsEvent {}

//states implementation
class AddFavouriteEventsInitial extends AddFavouriteEventsState {}

class AddFavouriteEventsProgress extends AddFavouriteEventsState {}

class AddFavouriteEventsSuccess extends AddFavouriteEventsState {
  AddFavouriteEventsSuccess({required this.message, this.eventId});
  final String message;
  final String? eventId;
}

class AddFavouriteEventsFailure extends AddFavouriteEventsState {
  final dynamic error;
  AddFavouriteEventsFailure({this.error});
}

//events implementation
class AddFavouriteEvents extends AddFavouriteEventsEvent {
  AddFavouriteEvents({
    required this.eventId,
    this.marketId,
    required this.favType,
  });
  final String eventId;
  final String? marketId;
  final FavType favType;
}
