import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/profit_loss_model.dart';

class FetchPlByOrdersBloc extends Bloc<FetchPlByOrdersEvent, FetchPlByOrdersState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchPlByOrdersBloc(this._ordersApiRepository) : super(FetchPlByOrdersInitial()) {
    on<FetchPlByOrders>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchPlByOrdersBloc');
      emit(FetchPlByOrdersProgress());
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getPlByOrders(page: event.page, limit: event.pagelimit);
          if (response.statusCode == 200) {
            // if (kDebugMode) debugPrint(response.bodyString);
            emit(FetchPlByOrdersSuccess(plByorders: response.body!.data));
          } else {
            if (kDebugMode) debugPrint("fetch_orders_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchPlByOrdersFailure('fetch_orders_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchPlByOrdersFailure('User not logged in'));
          emit(FetchPlByOrdersFailure('User not logged in'));
        }
      } catch (e) {
        if (kDebugMode) debugPrint('fetch_orders_bloc.dart.dart [Try Block Exception]>> \n $e');
        emit(FetchPlByOrdersFailure(e));
      }
    });
  }
}

// states
abstract class FetchPlByOrdersState {}

// events
abstract class FetchPlByOrdersEvent {}

// states implementation
class FetchPlByOrdersInitial extends FetchPlByOrdersState {}

class FetchPlByOrdersProgress extends FetchPlByOrdersState {}

class FetchPlByOrdersSuccess extends FetchPlByOrdersState {
  FetchPlByOrdersSuccess({required this.plByorders});
  final List<ProfitLoss> plByorders;
}

class FetchPlByOrdersFailure extends FetchPlByOrdersState {
  FetchPlByOrdersFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchPlByOrders extends FetchPlByOrdersEvent {
  FetchPlByOrders({
    this.page,
    this.pagelimit,
  });
  final int? page;
  final int? pagelimit;
}
