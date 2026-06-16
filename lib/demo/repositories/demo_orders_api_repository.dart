import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import 'package:chopper/chopper.dart';
import '../../models/open_order_model.dart';
import '../../models/order_data_model.dart';
import '../../models/player_bet_history_model.dart';
import '../../models/players_profit_and_loss_model.dart';
import '../../models/profit_loss_model.dart';
import '../../models/runners_pl_model.dart';
import '../data/demo_hive_store.dart';
import '../data/demo_order_engine.dart';
import 'demo_response.dart';

class DemoOrdersApiRepository extends OrdersApiRepository {
  DemoOrdersApiRepository(this.store, this.engine) : super();

  final DemoHiveStore store;
  final DemoOrderEngine engine;

  @override
  Future<Response> postOrder({required Map<String, dynamic> body}) async {
    final json = await engine.placeOrder(body);
    return DemoResponse.raw(json, statusCode: json['status'] == 200 ? 200 : 400);
  }

  @override
  Future<Response<BettingResponse>> getOrders() async {
    final json = await engine.currentBetsResponse();
    return DemoResponse.typed(json, BettingResponse.fromJson(json));
  }

  @override
  Future<Response<OpenBettingResponse>> getOpenOrders() async {
    final json = await engine.openOrdersResponse();
    return DemoResponse.typed(json, OpenBettingResponse.fromJson(json));
  }

  @override
  Future<OddsRunnerPLResponse> getOddsRunnerPl({required Map<String, dynamic> body}) async {
    final json = await engine.runnerPlResponse(marketId: '${body['marketId'] ?? ''}', bettingType: 0);
    return OddsRunnerPLResponse.fromJson(json);
  }

  @override
  Future<FancyRunnerPLResponse> getFancyRunnerPl({required Map<String, dynamic> body}) async {
    final json = await engine.runnerPlResponse(marketId: '${body['marketId'] ?? ''}', bettingType: 1);
    return FancyRunnerPLResponse.fromJson(json);
  }

  @override
  Future<BMRunnerPLResponse> getBMRunnerPl({required Map<String, dynamic> body}) async {
    final json = await engine.runnerPlResponse(marketId: '${body['marketId'] ?? ''}', bettingType: 2);
    return BMRunnerPLResponse.fromJson(json);
  }

  @override
  Future<FancyBookResponse> getFancyBook({required Map<String, dynamic> body}) async {
    final json = await engine.fancyBookResponse('${body['marketId'] ?? ''}');
    return FancyBookResponse.fromJson(json);
  }

  @override
  Future<Response<ProfitLossResponse>> getPlByOrders({int? page, int? limit}) async {
    final json = await engine.profitLossResponse();
    return DemoResponse.typed(json, ProfitLossResponse.fromJson(json));
  }

  @override
  Future<PlayerBetHistoryResponse> getPlayerBetHistory({required Map<String, dynamic> body}) async {
    final json = await engine.playerBetHistoryResponse();
    return PlayerBetHistoryResponse.fromJson(json);
  }

  @override
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss({required Map<String, dynamic> body}) async {
    final json = await engine.playerProfitLossResponse();
    return PlayerProfitAndLossResponse.fromJson(json);
  }
}
