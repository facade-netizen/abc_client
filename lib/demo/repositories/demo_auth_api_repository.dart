import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import 'package:chopper/chopper.dart';
import '../../models/activity_log_model.dart';
import '../../models/user_details_model.dart';
import '../data/demo_hive_store.dart';
import 'demo_response.dart';

class DemoAuthApiRepository extends AuthApiRepository {
  DemoAuthApiRepository(this.store) : super();

  final DemoHiveStore store;

  @override
  Future<Response<UserAccountResponse>> getUserDetails() async {
    final account = await store.map('account');
    final json = {'status': 200, 'data': account, 'message': 'success'};
    return DemoResponse.typed(json, UserAccountResponse.fromJson(json));
  }

  @override
  Future<ActivityLogsResponse> getUserActivityLogs({required Map<String, dynamic> body}) async {
    final logs = await store.list('activityLogs');
    final pageSize = body['limit'] ?? body['pageSize'] ?? logs.length;
    final json = {'status': 'success', 'data': logs, 'page': body['page'] ?? 1, 'pageSize': pageSize, 'result': logs.length, 'totalPages': 1, 'totalRecords': logs.length};
    return ActivityLogsResponse.fromJson(json);
  }

  @override
  Future<Response> changeNewPassword({required Map<String, dynamic> body}) async {
    return DemoResponse.raw({'status': 200, 'message': 'Demo password updated locally'});
  }

  @override
  Future<Response> restPassword({required Map<String, dynamic> body}) async {
    return DemoResponse.raw({'status': 200, 'message': 'Demo password reset locally'});
  }
}
