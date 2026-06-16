import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';

class FetchPremiumBloc extends Bloc<FetchPremiumEvent, FetchPremiumState> {
  final CGApiRepository _cgApiRepository;
  Map<String, dynamic>? _lastFetchPremiumMap;

  FetchPremiumBloc(this._cgApiRepository) : super(FetchPremiumInitial()) {
    on<FetchPremium>((event, emit) async {
      final isDuplicateRequest = _lastFetchPremiumMap != null && mapEquals(_lastFetchPremiumMap!, event.fetchPremiumMap);
      if (isDuplicateRequest && (state is FetchPremiumProgress || state is FetchPremiumSuccess)) {
        if (kDebugMode) debugPrint('Skipping duplicate FetchPremium request');
        return;
      }

      _lastFetchPremiumMap = Map<String, dynamic>.from(event.fetchPremiumMap);
      emit(FetchPremiumProgress());
      if (kDebugMode) debugPrint('Called FetchPremiumBloc');
      try {
        final response = await _cgApiRepository.fetchPremium(body: event.fetchPremiumMap);
        if (response.statusCode == 200) {
          if (kDebugMode) debugPrint(response.bodyString);
          final decoded = jsonDecode(response.bodyString);
          final message = decoded['message'] ?? '';
          if (decoded['status'] == 200) {
            final data = decoded['data'] ?? '';
            final url = data['url'] ?? '';
            emit(FetchPremiumSuccess(message: message, url: url));
          } else {
            emit(FetchPremiumFailure(error: message));
          }
        } else {
          if (kDebugMode) debugPrint("fetch_premium_market_bloc.dart [response error]>> ${response.statusCode}");
        }
      } catch (e) {
        emit(FetchPremiumFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class FetchPremiumState {}

//events instantiation
abstract class FetchPremiumEvent {}

//states implementation
class FetchPremiumInitial extends FetchPremiumState {}

class FetchPremiumProgress extends FetchPremiumState {}

class FetchPremiumSuccess extends FetchPremiumState {
  FetchPremiumSuccess({required this.message, required this.url});
  final String message;
  final String url;
}

class FetchPremiumFailure extends FetchPremiumState {
  final dynamic error;
  FetchPremiumFailure({this.error});
}

//events implementation
class FetchPremium extends FetchPremiumEvent {
  FetchPremium({required this.fetchPremiumMap});
  final Map<String, dynamic> fetchPremiumMap;
}
