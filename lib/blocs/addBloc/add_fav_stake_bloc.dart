import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class AddFavStakeBloc extends Bloc<AddFavStakeEvent, AddFavStakeState> {
  final FavouriteApiRepository _favouriteApiRepository;
  AddFavStakeBloc(this._favouriteApiRepository) : super(AddFavStakeInitial()) {
    on<AddFavStake>((event, emit) async {
      emit(AddFavStakeProgress());
      if (kDebugMode) debugPrint('Called AddFavStakeBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          final response = await _favouriteApiRepository.addFavStake(body: event.body);
          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.bodyString);
            if (decoded["status"] == 200) {
              emit(AddFavStakeSuccess());
            } else {
              final message = decoded['message'] ?? '';
              emit(AddFavStakeFailure(error: message));
            }
            emit(AddFavStakeSuccess());
          } else {
            if (kDebugMode) debugPrint("fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}");
            emit(AddFavStakeFailure(error: 'fetch_fav_events_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(AddFavStakeFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(AddFavStakeFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class AddFavStakeState {}

//events instantiation
abstract class AddFavStakeEvent {}

//states implementation
class AddFavStakeInitial extends AddFavStakeState {}

class AddFavStakeProgress extends AddFavStakeState {}

class AddFavStakeSuccess extends AddFavStakeState {}

class AddFavStakeFailure extends AddFavStakeState {
  final dynamic error;
  AddFavStakeFailure({this.error});
}

//events implementation
class AddFavStake extends AddFavStakeEvent {
  AddFavStake({required this.body});
  final Map<String, dynamic> body;
}
