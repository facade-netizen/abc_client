import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UpdateOnclickBetBloc extends Bloc<UpdateOnclickBetEvent, UpdateOnclickBetState> {
  final FavouriteApiRepository _favouriteApiRepository;
  UpdateOnclickBetBloc(this._favouriteApiRepository) : super(UpdateOnclickBetInitial()) {
    on<UpdateOnclickBet>((event, emit) async {
      emit(UpdateOnclickBetProgress());
      if (kDebugMode) debugPrint('Called UpdateOnclickBetBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          if (event.type == 1) {
            final url = Uri.parse(FavoriteApiConstants.isClicked);
            final response = await http.put(
              url,
              headers: {
                'accept': 'text/plain',
                'Authorization': 'Bearer ${savedTokenData.token}',
                'Content-Type': 'application/json',
              },
              body: "${event.isClicked}",
            );
            if (response.statusCode == 200) {
              final bodyString = response.body;
              final decoded = jsonDecode(bodyString);
              if (decoded["status"] == 200) {
                emit(UpdateOnclickBetSuccess());
              } else {
                final message = decoded['message'] ?? '';
                emit(UpdateOnclickBetFailure(error: message));
              }
            } else {
              if (kDebugMode) debugPrint("[updateOnclickBet response error]>> ${response.statusCode}");
              emit(UpdateOnclickBetFailure(error: '[updateOnclickBet response error]>> ${response.statusCode}'));
            }
          } else if (event.type == 2) {
            final response = await _favouriteApiRepository.updateOnclickBetAllStakes(body: event.body ?? {});
            if (response.statusCode == 200) {
              final decoded = jsonDecode(response.bodyString);
              if (decoded["status"] == 200) {
                emit(UpdateOnclickBetSuccess());
              } else {
                final message = decoded['message'] ?? '';
                emit(UpdateOnclickBetFailure(error: message));
              }
            } else {
              if (kDebugMode) debugPrint("[updateOnclickBetAllStakes response error]>> ${response.statusCode}");
              emit(UpdateOnclickBetFailure(error: '[updateOnclickBetAllStakes response error]>> ${response.statusCode}'));
            }
          } else if (event.type == 3) {
            final url = Uri.parse(FavoriteApiConstants.defaultStake);
            final response = await http.put(
              url,
              headers: {
                'accept': 'text/plain',
                'Authorization': 'Bearer ${savedTokenData.token}',
                'Content-Type': 'application/json',
              },
              body: event.defaultStake,
            );
            if (response.statusCode == 200) {
              final bodyString = response.body;
              final decoded = jsonDecode(bodyString);
              if (decoded["status"] == 200) {
                emit(UpdateOnclickBetSuccess());
              } else {
                final message = decoded['message'] ?? '';
                emit(UpdateOnclickBetFailure(error: message));
              }
            } else {
              if (kDebugMode) debugPrint("[updateOnclickBet response error]>> ${response.statusCode}");
              emit(UpdateOnclickBetFailure(error: '[updateOnclickBet response error]>> ${response.statusCode}'));
            }
          }
        } else {
          emit(UpdateOnclickBetFailure(error: "User not Logged in"));
        }
      } catch (e) {
        emit(UpdateOnclickBetFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class UpdateOnclickBetState {}

//events instantiation
abstract class UpdateOnclickBetEvent {}

//states implementation
class UpdateOnclickBetInitial extends UpdateOnclickBetState {}

class UpdateOnclickBetProgress extends UpdateOnclickBetState {}

class UpdateOnclickBetSuccess extends UpdateOnclickBetState {}

class UpdateOnclickBetFailure extends UpdateOnclickBetState {
  final dynamic error;
  UpdateOnclickBetFailure({this.error});
}

//events implementation
class UpdateOnclickBet extends UpdateOnclickBetEvent {
  UpdateOnclickBet({this.body, required this.type, this.isClicked, this.defaultStake});
  final Map<String, dynamic>? body;
  final int type;
  final bool? isClicked;
  final String? defaultStake;
}
