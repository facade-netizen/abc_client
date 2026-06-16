import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/order_data_model.dart';

class FetchOrdersBloc extends Bloc<FetchOrdersEvent, FetchOrdersState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchOrdersBloc(this._ordersApiRepository) : super(FetchOrdersInitial()) {
    on<FetchOrders>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchOrdersBloc');
      emit(FetchOrdersProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getOrders();
          if (response.statusCode == 200) {
            // if (kDebugMode) debugPrint(response.bodyString);
            emit(FetchOrdersSuccess(orderData: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_orders_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchOrdersFailure('fetch_orders_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchOrdersFailure('User not logged in'));
          emit(FetchOrdersFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_orders_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchOrdersFailure(e));
      }
    });
  }
}

// states
abstract class FetchOrdersState {}

// events
abstract class FetchOrdersEvent {}

// states implementation
class FetchOrdersInitial extends FetchOrdersState {}

class FetchOrdersProgress extends FetchOrdersState {}

class FetchOrdersSuccess extends FetchOrdersState {
  FetchOrdersSuccess({required this.orderData});
  final List<Order> orderData;
}

class FetchOrdersFailure extends FetchOrdersState {
  FetchOrdersFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchOrders extends FetchOrdersEvent {}
