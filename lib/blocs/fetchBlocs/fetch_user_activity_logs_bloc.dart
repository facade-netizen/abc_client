import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/activity_log_model.dart';

String formatDateYYYYMMDD(dynamic date) {
  if (date is DateTime) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 00:00:00.000";
  } else if (date is String && date.length >= 10) {
    final d = DateTime.tryParse(date.substring(0, 10));
    if (d != null) {
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} 00:00:00.000";
    }
  }
  return date.toString();
}

class FetchUserActivityLogsBloc extends Bloc<FetchUserActivityLogsEvent, FetchUserActivityLogsState> {
  final AuthApiRepository _authApiRepository;
  FetchUserActivityLogsBloc(this._authApiRepository) : super(FetchUserActivityLogsInitial()) {
    on<FetchUserActivityLogs>((event, emit) async {
      emit(FetchUserActivityLogsProgress());
      debugPrint("Called FetchUserActivityLogsBloc");
      SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedData != null) {
          String userId = event.userId ?? savedData.userId ?? '';
          String to = event.to ?? formatDateYYYYMMDD(DateTime.now());
          String from;
          if (event.from != null) {
            from = formatDateYYYYMMDD(event.from!);
          } else {
            DateTime toDate = DateTime.parse(to.substring(0, 10));
            DateTime fromDate = toDate.subtract(const Duration(days: 30));
            from = formatDateYYYYMMDD(fromDate);
          }
          int limit = event.limit ?? 25;
          int page = event.page ?? 1;

          Map<String, dynamic> userActivityLogsMap = {"userId": userId, "from": from, "to": to, "limit": limit, "page": page};
          final response = await _authApiRepository.getUserActivityLogs(body: userActivityLogsMap);
          if (response.status == "success") {
            // if (kDebugMode) debugPrint(response.data.toString());
            emit(FetchUserActivityLogsSuccess(activityLogsResponse: response));
          } else {
            if (kDebugMode) debugPrint("fetch_user_activity_logs_bloc.dart [response error]>> \\${response.status}");
            emit(FetchUserActivityLogsFailure('fetch_user_activity_logs_bloc.dart [response error]>> \\${response.status}'));
          }
        } else {
          emit(FetchUserActivityLogsFailure("User not in"));
        }
      } catch (e) {
        debugPrint("fetch_user_activity_logs_bloc.dart 1 [Platform Exception] >>error: $e");
        emit(FetchUserActivityLogsFailure(e));
      }
    });
  }
}

//states
abstract class FetchUserActivityLogsState {}

//events
abstract class FetchUserActivityLogsEvent {}

//states implementation
class FetchUserActivityLogsInitial extends FetchUserActivityLogsState {}

class FetchUserActivityLogsProgress extends FetchUserActivityLogsState {}

class FetchUserActivityLogsSuccess extends FetchUserActivityLogsState {
  final ActivityLogsResponse activityLogsResponse;
  FetchUserActivityLogsSuccess({required this.activityLogsResponse});
}

class FetchUserActivityLogsFailure extends FetchUserActivityLogsState {
  final dynamic error;
  FetchUserActivityLogsFailure(this.error);
}

//events implementation
// events implementation
class FetchUserActivityLogs extends FetchUserActivityLogsEvent {
  String? userId;
  String? from;
  String? to;
  int? limit;
  int? page;

  FetchUserActivityLogs({this.userId, this.from, this.to, this.limit, this.page});
}
