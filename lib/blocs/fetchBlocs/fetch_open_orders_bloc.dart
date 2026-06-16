import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/open_order_model.dart';

class FetchOpenOrdersBloc extends Bloc<FetchOpenOrdersEvent, FetchOpenOrdersState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchOpenOrdersBloc(this._ordersApiRepository) : super(FetchOpenOrdersInitial()) {
    on<FetchOpenOrders>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenOrdersBloc');
      emit(FetchOpenOrdersProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getOpenOrders();
          if (response.statusCode == 200) {
            // if (kDebugMode) debugPrint(response.bodyString);
            emit(FetchOpenOrdersSuccess(openOrderData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_open_orders_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOpenOrdersFailure('fetch_open_orders_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOpenOrdersFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_open_orders_bloc.dart [Try Block Exception]>> \n $e');
        emit(FetchOpenOrdersFailure(e));
      }
    });
    on<FetchOpenOrdersInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOpenOrdersInt');
      emit(FetchOpenOrdersInitial());
    });
  }
}

// states
abstract class FetchOpenOrdersState {}

// events
abstract class FetchOpenOrdersEvent {}

// states implementation
class FetchOpenOrdersInitial extends FetchOpenOrdersState {}

class FetchOpenOrdersProgress extends FetchOpenOrdersState {}

class FetchOpenOrdersSuccess extends FetchOpenOrdersState {
  FetchOpenOrdersSuccess({required this.openOrderData});
  final List<OpenEventBettingData> openOrderData;
}

class FetchOpenOrdersFailure extends FetchOpenOrdersState {
  FetchOpenOrdersFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchOpenOrders extends FetchOpenOrdersEvent {}

class FetchOpenOrdersInt extends FetchOpenOrdersEvent {}
