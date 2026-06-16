import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/wl_app_data_model.dart';

class FetchWlDetailsBloc extends Bloc<FetchWlDetailsEvent, FetchWlDetailsState> {
  FetchWlDetailsBloc() : super(FetchWlDetailsInitial()) {
    on<FetchWlDetails>((event, emit) async {
      emit(FetchWlDetailsProgress());
      try {
        final responseWL = await http.get(Uri.parse(wlUrl));
        Map<String, dynamic> decodedData = {};
        if (responseWL.statusCode == 200) {
          decodedData = jsonDecode(responseWL.body);
          AppResponse appData = AppResponse.fromJson(decodedData);
          emit(FetchWlDetailsSuccess(appData: appData.data));
        }
      } catch (e) {
        debugPrint("USer Ip Error => $e");
        emit(FetchWlDetailsFailure("USer Ip user"));
      }
    });
    on<SetLoginToInitial>((event, emit) async {
      emit(FetchWlDetailsInitial());
    });
  }
}

//event
abstract class FetchWlDetailsEvent {}

//state
abstract class FetchWlDetailsState {}

//event impl
class FetchWlDetails extends FetchWlDetailsEvent {}

//states impl
class FetchWlDetailsInitial extends FetchWlDetailsState {}

class FetchWlDetailsProgress extends FetchWlDetailsState {}

class FetchWlDetailsSuccess extends FetchWlDetailsState {
  FetchWlDetailsSuccess({required this.appData});
  final AppData appData;
}

class FetchWlDetailsFailure extends FetchWlDetailsState {
  final String error;
  FetchWlDetailsFailure(this.error);
}

class SetLoginToInitial extends FetchWlDetailsEvent {}
