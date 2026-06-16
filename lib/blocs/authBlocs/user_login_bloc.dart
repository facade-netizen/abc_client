import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../constants/app_string_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

class UserLoginBloc extends Bloc<UserLoginEvent, UserLoginState> {
  UserLoginBloc() : super(UserLoginInitial()) {
    on<UserLogin>((event, emit) async {
      emit(UserLoginProgress());
      try {
        // Format current time
        final now = DateTime.now();
        final formattedLoginTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
        final response = await http.post(
          Uri.parse(AuthApiConstants.login),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "username": event.username,
            "password": event.password,
            "loginTime": formattedLoginTime,
            "isp": isp.value.isEmpty ? "Blocked" : isp.value,
            "ip": ip.value.isEmpty ? "Blocked" : ip.value,
            "agent": agent.value.isEmpty ? "Blocked" : agent.value,
            "address": address.value.isEmpty ? "Blocked" : address.value,
          }),
        );
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final data = decoded["data"];
          log(data.toString(), name: "login data");
          if (decoded["status"] == 200) {
            if (data["changePassword"] == true) {
              emit(UserLoginResetPasswordRequiredSuccess(userName:event.username ));
            } else {
              final role = data["role"];
              final userName = data["userName"];
              if (role.toString().toLowerCase().contains('client')) {
                SaveTokenBox.loginTokenBox.saveLoginToken = SaveLoginTokenModel(
                  token: data["token"],
                  refreshToken: data["refreshToken"],
                  validTill: data["validTill"],
                  savedAt: DateTime.now(),
                  userId: data["userId"],
                  role: role,
                  userName: userName,
                  userStatus: data["UserStatus"],
                );
                emit(UserLoginSuccess());
              } else {
                emit(UserLoginFailure("Login failed! Super user can't allow to login"));
              }
            }
          } else if (decoded["status"] == 400) {
            emit(UserLoginFailure("${decoded["message"]}"));
          }
        } else {
          emit(UserLoginFailure("${response.reasonPhrase}"));
        }
      } catch (e) {
        debugPrint("Login Error => $e");
        emit(UserLoginFailure("Invalid user"));
      }
    });
    on<SetLoginToInitial>((event, emit) async {
      emit(UserLoginInitial());
    });
  }
}

//event
abstract class UserLoginEvent {}

//state
abstract class UserLoginState {}

//event impl
class UserLogin extends UserLoginEvent {
  final String username;
  final String password;
  UserLogin({required this.username, required this.password});
}

//states impl
class UserLoginInitial extends UserLoginState {}

class UserLoginProgress extends UserLoginState {}

class UserLoginSuccess extends UserLoginState {}

class UserLoginResetPasswordRequiredSuccess extends UserLoginState {
  UserLoginResetPasswordRequiredSuccess({required this.userName});
  final String userName;
}

class UserLoginFailure extends UserLoginState {
  final String error;
  UserLoginFailure(this.error);
}

class SetLoginToInitial extends UserLoginEvent {}
