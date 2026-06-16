// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$OrdersApiServices extends OrdersApiServices {
  _$OrdersApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = OrdersApiServices;

  @override
  Future<Response<dynamic>> postOrder({required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/order');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<BettingResponse>> getOrders() {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/order');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<BettingResponse, BettingResponse>($request);
  }

  @override
  Future<Response<OpenBettingResponse>> getOpenOrders() {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/openOrder');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<OpenBettingResponse, OpenBettingResponse>($request);
  }

  @override
  Future<OddsRunnerPLResponse> getOddsRunnersPl(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/matchProfitLoss');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<OddsRunnerPLResponse, OddsRunnerPLResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<FancyRunnerPLResponse> getFancyRunnersPl(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/matchProfitLoss');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<FancyRunnerPLResponse, FancyRunnerPLResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<BMRunnerPLResponse> getBMRunnersPl(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/matchProfitLoss');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<BMRunnerPLResponse, BMRunnerPLResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<FancyBookResponse> getFancyBook(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/matchBook');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<FancyBookResponse, FancyBookResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<ProfitLossResponse>> getPlByOrders({
    required int page,
    required int limit,
  }) {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/pnlHistory');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<ProfitLossResponse, ProfitLossResponse>($request);
  }

  @override
  Future<PlayerBetHistoryResponse> getPlayerBetHistory(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/orderReport');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client
        .send<PlayerBetHistoryResponse, PlayerBetHistoryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<PlayerProfitAndLossResponse> getPlayerProfitAndLoss(
      {required Map<String, dynamic> body}) async {
    final Uri $url = Uri.parse('https://abcorder.dmxchge.com/profitLoss');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response = await client.send<PlayerProfitAndLossResponse,
        PlayerProfitAndLossResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<UserMMOddBmPlResponse> getUserMatchProfitAndLossOddAndBm() async {
    final Uri $url =
        Uri.parse('https://abcorder.dmxchge.com/userMatchProfitLoss-Odds');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response = await client
        .send<UserMMOddBmPlResponse, UserMMOddBmPlResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<UserMMFancyPlResponse> getUserMatchProfitAndLossLine() async {
    final Uri $url =
        Uri.parse('https://abcorder.dmxchge.com/userMatchProfitLoss-Line');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    final Response $response = await client
        .send<UserMMFancyPlResponse, UserMMFancyPlResponse>($request);
    return $response.bodyOrThrow;
  }
}
