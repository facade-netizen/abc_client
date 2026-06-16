import 'package:chopper/chopper.dart';

import '../../../models/open_order_model.dart';
import '../../../models/order_data_model.dart';
import '../../../models/player_bet_history_model.dart';
import '../../../models/players_profit_and_loss_model.dart';
import '../../../models/profit_loss_model.dart';
import '../../../models/runners_pl_model.dart';
import '../../../models/user_mm_pl_model.dart';
import 'orders_api_services.dart';

class OrdersApiRepository {
  OrdersApiRepository() : _ordersApiServices = OrdersApiServices.create();
  final OrdersApiServices _ordersApiServices;

  Future<Response> postOrder({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.postOrder(body: body);
  }

  //Orders
  Future<Response<BettingResponse>> getOrders() async {
    try {
      return _ordersApiServices.getOrders();
    } catch (e) {
      rethrow;
    }
  }

  //Open Orders
  Future<Response<OpenBettingResponse>> getOpenOrders() async {
    try {
      return _ordersApiServices.getOpenOrders();
    } catch (e) {
      rethrow;
    }
  }

  Future<OddsRunnerPLResponse> getOddsRunnerPl({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getOddsRunnersPl(body: body);
  }

  Future<FancyRunnerPLResponse> getFancyRunnerPl({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getFancyRunnersPl(body: body);
  }

  Future<BMRunnerPLResponse> getBMRunnerPl({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getBMRunnersPl(body: body);
  }

  Future<FancyBookResponse> getFancyBook({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getFancyBook(body: body);
  }

  //Open Orders
  Future<Response<ProfitLossResponse>> getPlByOrders({int? page, int? limit}) async {
    try {
      return _ordersApiServices.getPlByOrders(page: page ?? 1, limit: limit ?? 10);
    } catch (e) {
      rethrow;
    }
  }

  ///getPlayerBetHistory
  Future<PlayerBetHistoryResponse> getPlayerBetHistory({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getPlayerBetHistory(body: body);
  }

  ///getPlayerProfitAndLoss
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss({required Map<String, dynamic> body}) async {
    return await _ordersApiServices.getPlayerProfitAndLoss(body: body);
  }

  ///getUserMatchProfitAndLoss
  Future<UserMMOddBmPlResponse> getUserMatchProfitAndLossOddAndBm() async {
    return await _ordersApiServices.getUserMatchProfitAndLossOddAndBm();
  }

  ///getUserMatchProfitAndLoss
  Future<UserMMFancyPlResponse> getUserMatchProfitAndLossLine() async {
    return await _ordersApiServices.getUserMatchProfitAndLossLine();
  }
}
