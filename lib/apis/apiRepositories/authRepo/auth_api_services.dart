import 'package:chopper/chopper.dart';

import '../../../models/activity_log_model.dart';
import '../../../models/user_details_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'auth_api_services.chopper.dart';

final _authApiClient = ChopperClient(
  baseUrl: Uri.parse(AuthApiConstants.baseUrl),
  converter: JsonSerializableConverter(
    {
      UserAccountResponse: (json) => UserAccountResponse.fromJson(json),
      ActivityLogsResponse: (json) => ActivityLogsResponse.fromJson(json),
    },
  ),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: AuthApiConstants.baseUrl)
abstract class AuthApiServices extends ChopperService {
  ///Don't modify
  static AuthApiServices create() {
    return _$AuthApiServices(_authApiClient);
  }

  @GET(path: AuthApiConstants.account)
  Future<Response<UserAccountResponse>> getUserDetails();

  @POST(path: AuthApiConstants.activityLog)
  Future<ActivityLogsResponse> getUserActivityLogs({@Body() required Map<String, dynamic> body});

  @POST(path: AuthApiConstants.changePassword)
  Future<Response> changeNewPassword({@Body() required Map<String, dynamic> body});

  @POST(path: AuthApiConstants.resetPassword)
  Future<Response> restPassword({@Body() required Map<String, dynamic> body});
}
