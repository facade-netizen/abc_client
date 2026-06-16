import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/open_order_model.dart';

class FetchCurrentBetsBloc extends Bloc<FetchCurrentBetsEvent, FetchCurrentBetsState> {
  final OrdersApiRepository _ordersApiRepository;
  FetchCurrentBetsBloc(this._ordersApiRepository) : super(FetchCurrentBetsInitial()) {
    on<FetchCurrentBets>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCurrentBetsBloc');

      emit(FetchCurrentBetsProgress());

      if (event.betType == null) {
        await Future.delayed(const Duration(seconds: 1));
        emit(FetchCurrentBetsSuccess(openOrder: []));
        return;
      }
      //checking authentication
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

      try {
        if (savedTokenData != null) {
          final response = await _ordersApiRepository.getOpenOrders();
          if (response.statusCode == 200) {
            final List<OpenEventBettingData> openOrderData = response.body!.data;
            final List<OpenOrder> allOpenOrders = openOrderData.expand((e) => e.openOrders).toList();
            final List<OpenOrder> filteredOpenOrders = allOpenOrders.where((o) => o.betType == event.betType).toList();
            emit(FetchCurrentBetsSuccess(
              openOrder: filteredOpenOrders,
            ));
          } else {
            if (kDebugMode) debugPrint("fetch_current_bets_bloc.dart [response error]>> ${response.statusCode}");
            emit(FetchCurrentBetsFailure('fetch_current_bets_bloc.dart [response error]>> ${response.statusCode}'));
          }
        } else {
          emit(FetchCurrentBetsFailure('User not logged in'));
        }
      } catch (e, stackTrace) {
        if (kDebugMode) debugPrint('fetch_current_bets_bloc.dart [Try Block Exception]>> \n $e\n$stackTrace');
        emit(FetchCurrentBetsFailure(e.toString()));
      }
    });
    on<FetchCurrentBetsInt>((event, emit) async {
      if (kDebugMode) debugPrint('Called FetchCurrentBetsInt');
      emit(FetchCurrentBetsInitial());
    });
  }
}

// states
abstract class FetchCurrentBetsState {}

// events
abstract class FetchCurrentBetsEvent {}

// states implementation
class FetchCurrentBetsInitial extends FetchCurrentBetsState {}

class FetchCurrentBetsProgress extends FetchCurrentBetsState {}

class FetchCurrentBetsSuccess extends FetchCurrentBetsState {
  FetchCurrentBetsSuccess({required this.openOrder});
  final List<OpenOrder> openOrder;
}

class FetchCurrentBetsFailure extends FetchCurrentBetsState {
  FetchCurrentBetsFailure(this.error);
  final dynamic error;
}

// events implementation
class FetchCurrentBets extends FetchCurrentBetsEvent {
  final int? betType;
  FetchCurrentBets({this.betType});
}

class FetchCurrentBetsInt extends FetchCurrentBetsEvent {}
