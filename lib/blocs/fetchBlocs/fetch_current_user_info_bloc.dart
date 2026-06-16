import 'package:chopper/chopper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../../models/user_details_model.dart';

class FetchUserAccountDetailsBloc extends Bloc<FetchUserAccountDetailsEvent, FetchUserAccountDetailsState> {
  final AuthApiRepository _authApiRepository;
  FetchUserAccountDetailsBloc(this._authApiRepository) : super(FetchUserAccountDetailsInitial()) {
    on<FetchUserAccountDetails>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchUserAccountDetailsBloc');
      emit(FetchUserAccountDetailsProgress());
      try {
        final Response<UserAccountResponse> response = await _authApiRepository.getUserDetails();
        if (response.statusCode == 200) {
          // if (kDebugMode) debugPrint("User Account Details >>  ${response.body!.data}");
          UserAccountDetails userDetails = response.body!.data;
          emit(FetchUserAccountDetailsSuccess(userDetails: userDetails));
        } else {
          if (kDebugMode) debugPrint("FetchUserAccountDetailsBloc - non 200 response ${response.statusCode}");
          emit(FetchUserAccountDetailsFailure("Non ${response.statusCode} Status"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('');
        emit(FetchUserAccountDetailsFailure(e));
      }
    });
  }
}

//states
abstract class FetchUserAccountDetailsState {}

//events
abstract class FetchUserAccountDetailsEvent {}

//states implementation
class FetchUserAccountDetailsInitial extends FetchUserAccountDetailsState {}

class FetchUserAccountDetailsProgress extends FetchUserAccountDetailsState {}

class FetchUserAccountDetailsSuccess extends FetchUserAccountDetailsState {
  final UserAccountDetails userDetails;
  FetchUserAccountDetailsSuccess({required this.userDetails});
}

class FetchUserAccountDetailsFailure extends FetchUserAccountDetailsState {
  final dynamic error;
  FetchUserAccountDetailsFailure(this.error);
}

//events implementation
class FetchUserAccountDetails extends FetchUserAccountDetailsEvent {}
