import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserAuthChangesBloc extends Bloc<UserAuthChangesEvent, UserAuthChangesState> {
  UserAuthChangesBloc() : super(UserAuthChangesInitial()) {
    on<StartUserChangeListener>((event, emit) async {
      emit(UserAuthChangesProgress());
      final savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (savedData == null || savedData.token == null || savedData.validTill == null) {
        emit(UserAuthChangesFailure());
        return;
      }

      try {
        final uri = Uri.parse(AuthApiConstants.varifyToken).replace(queryParameters: {'accessToken': savedData.token});
        final verifyTokenRes = await http.get(uri);
        if (verifyTokenRes.statusCode != 200) {
          emit(UserAuthChangesFailure());
          return;
        }
        final decodedData = jsonDecode(verifyTokenRes.body);
        final apiStatus = decodedData['status'];
        final apiUserId = decodedData['data']?['UserId'];
        final formatter = DateFormat("dd:MM:yyyy HH:mm:ss");
        final expiry = formatter.parse(savedData.validTill!);
        final now = DateTime.now();
        final isNotExpired = now.isBefore(expiry);
        final isValidStatus = apiStatus == 200;
        final isSameUser = apiUserId == savedData.userId;

        if (isNotExpired && isValidStatus && isSameUser) {
          emit(UserAuthChangesSuccess(savedUserAuth: savedData));
        } else {
          await SaveTokenBox.loginTokenBox.clearLoginToken();
          emit(UserAuthChangesFailure());
        }
      } catch (e) {
        emit(UserAuthChangesSuccess(savedUserAuth: savedData));
      }
    });
  }
}

//states
abstract class UserAuthChangesState {}

//events
abstract class UserAuthChangesEvent {}

//states implementation
class UserAuthChangesInitial extends UserAuthChangesState {}

class UserAuthChangesProgress extends UserAuthChangesState {}

class UserAuthChangesSuccess extends UserAuthChangesState {
  UserAuthChangesSuccess({required this.savedUserAuth});
  final SaveLoginTokenModel? savedUserAuth;
}

class UserAuthChangesFailure extends UserAuthChangesState {}

//events implementation
class StartUserChangeListener extends UserAuthChangesEvent {}
