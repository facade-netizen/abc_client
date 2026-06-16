import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../constants/app_string_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../services/app_config.dart';

enum OrderType { oddsMatch, bookMaker, fancy, multiOrder, na }

class SendOrderBloc extends Bloc<SendOrderEvent, SendOrderState> {
  final OrdersApiRepository _ordersApiRepository;
  SendOrderBloc(this._ordersApiRepository) : super(SendOrderInitial()) {
    on<SendOrder>((event, emit) async {
      emit(SendOrderProgress(
        type: event.type,
        marketDelay: event.marketDelay,
        eventId: event.orderMap['eventId']?.toString(),
        marketId: event.orderMap['marketId']?.toString(),
      ));
      if (kDebugMode) debugPrint('Called SendOrderBloc');
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      try {
        if (savedTokenData != null) {
          event.orderMap.addAll({
            "ip": ip.value,
            "isp": isp.value,
            "userId": savedTokenData.userId,
            "userName": savedTokenData.userName,
            "buildNumber": appConfig.buildNumber,
            "version": appConfig.version,
            "mode": appConfig.debugMode,
            "platform": appConfig.operatingSystem,
          });
          final response = await _ordersApiRepository.postOrder(body: event.orderMap);
          if (response.statusCode == 200) {
            if (kDebugMode) debugPrint(response.bodyString);
            final decoded = jsonDecode(response.bodyString);
            final message = decoded['message'] ?? '';
            if (decoded['status'] == 200) {
              final delaySeconds = event.marketDelay ?? 0;
              if (delaySeconds > 0) {
                await Future.delayed(Duration(seconds: delaySeconds));
              }
              emit(SendOrderSuccess(message: message));
            } else {
              emit(SendOrderFailure(error: message));
            }
          } else {
            if (kDebugMode) debugPrint("send_order_bloc.dart [response error]>> ${response.statusCode}");
            emit(SendOrderFailure(error: 'Response Error >>> ${response.statusCode}'));
          }
        } else {
          emit(SendOrderFailure(error: "User not Logged in"));
        }
      } catch (e) {
        if (kDebugMode) debugPrint("'Catch Error   >> ${e.toString()}");
        emit(SendOrderFailure(error: 'Catch Error >>>> $e'));
      }
    });
  }
}

//states instantiation
abstract class SendOrderState {}

//events instantiation
abstract class SendOrderEvent {}

//states implementation
class SendOrderInitial extends SendOrderState {}

class SendOrderProgress extends SendOrderState {
  final OrderType type;
  final int? marketDelay;
  final String? eventId;
  final String? marketId;
  SendOrderProgress({required this.type, this.marketDelay, this.eventId, this.marketId});
}

class SendOrderSuccess extends SendOrderState {
  SendOrderSuccess({required this.message});
  final String message;
}

class SendOrderFailure extends SendOrderState {
  final dynamic error;
  SendOrderFailure({this.error});
}

//events implementation
class SendOrder extends SendOrderEvent {
  SendOrder({required this.orderMap, this.type = OrderType.na, this.marketDelay});
  final Map<String, dynamic> orderMap;
  final OrderType type;
  final int? marketDelay;
}
