import 'package:chopper/chopper.dart';

import '../../../models/activity_log_model.dart';
import '../../../models/user_details_model.dart';
import 'auth_api_services.dart';

class AuthApiRepository {
  AuthApiRepository() : _authApiServices = AuthApiServices.create();
  final AuthApiServices _authApiServices;

  Future<Response<UserAccountResponse>> getUserDetails() async {
    try {
      return _authApiServices.getUserDetails();
    } catch (e) {
      rethrow;
    }
  }

  Future<ActivityLogsResponse> getUserActivityLogs({required Map<String, dynamic> body}) async {
    return await _authApiServices.getUserActivityLogs(body: body);
  }

  Future<Response> changeNewPassword({required Map<String, dynamic> body}) async {
    return await _authApiServices.changeNewPassword(body: body);
  }

  Future<Response> restPassword({required Map<String, dynamic> body}) async {
    return await _authApiServices.restPassword(body: body);
  }
}
