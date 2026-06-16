import 'package:chopper/chopper.dart';

import '../../../models/open_order_model.dart';
import '../../../models/order_data_model.dart';
import '../../../models/player_bet_history_model.dart';
import '../../../models/players_profit_and_loss_model.dart';
import '../../../models/profit_loss_model.dart';
import '../../../models/runners_pl_model.dart';
import '../../../models/user_mm_pl_model.dart';
import '../../apiHandlers/api_constants.dart';
import '../../apiHandlers/api_interceptors.dart';
import '../../apiHandlers/json_to_type_converter.dart';

part 'orders_api_services.chopper.dart';

final _ordersApiClient = ChopperClient(
  baseUrl: Uri.parse(AuthApiConstants.baseUrl),
  converter: JsonSerializableConverter({
    BettingResponse: (json) => BettingResponse.fromJson(json),
    UserMMFancyPlResponse: (json) => UserMMFancyPlResponse.fromJson(json),
    UserMMOddBmPlResponse: (json) => UserMMOddBmPlResponse.fromJson(json),
    FancyBookResponse: (json) => FancyBookResponse.fromJson(json),
    BMRunnerPLResponse: (json) => BMRunnerPLResponse.fromJson(json),
    ProfitLossResponse: (json) => ProfitLossResponse.fromJson(json),
    OpenBettingResponse: (json) => OpenBettingResponse.fromJson(json),
    OddsRunnerPLResponse: (json) => OddsRunnerPLResponse.fromJson(json),
    FancyRunnerPLResponse: (json) => FancyRunnerPLResponse.fromJson(json),
    PlayerBetHistoryResponse: (json) => PlayerBetHistoryResponse.fromJson(json),
    PlayerProfitAndLossResponse: (json) => PlayerProfitAndLossResponse.fromJson(json),
  }),
  interceptors: [ApiAuthInterceptor(), ApiResponseInterceptor(), ApiRequestInterceptor()],
  errorConverter: const JsonConverter(),
);

@ChopperApi(baseUrl: OrdersApiConstants.baseUrl)
abstract class OrdersApiServices extends ChopperService {
  ///Don't modify
  static OrdersApiServices create() {
    return _$OrdersApiServices(_ordersApiClient);
  }

  @POST(path: OrdersApiConstants.order)
  Future<Response> postOrder({@Body() required Map<String, dynamic> body});

  @GET(path: OrdersApiConstants.order)
  Future<Response<BettingResponse>> getOrders();

  @GET(path: OrdersApiConstants.openOrder)
  Future<Response<OpenBettingResponse>> getOpenOrders();

  @POST(path: OrdersApiConstants.matchProfitLoss)
  Future<OddsRunnerPLResponse> getOddsRunnersPl({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.matchProfitLoss)
  Future<FancyRunnerPLResponse> getFancyRunnersPl({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.matchProfitLoss)
  Future<BMRunnerPLResponse> getBMRunnersPl({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.matchBook)
  Future<FancyBookResponse> getFancyBook({@Body() required Map<String, dynamic> body});

  @GET(path: OrdersApiConstants.pnlHistory)
  Future<Response<ProfitLossResponse>> getPlByOrders({@Query() required int page, @Query() required int limit});

  @POST(path: OrdersApiConstants.orderReport)
  Future<PlayerBetHistoryResponse> getPlayerBetHistory({@Body() required Map<String, dynamic> body});

  @POST(path: OrdersApiConstants.profitLoss)
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss({@Body() required Map<String, dynamic> body});

  @GET(path: OrdersApiConstants.userMatchProfitLossOdds)
  Future<UserMMOddBmPlResponse> getUserMatchProfitAndLossOddAndBm();

  @GET(path: OrdersApiConstants.userMatchProfitLossLine)
  Future<UserMMFancyPlResponse> getUserMatchProfitAndLossLine();
}
