// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cg_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CGApiServices extends CGApiServices {
  _$CGApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CGApiServices;

  @override
  Future<Response<CGBalanceResponse>> getCGBalance(String provider) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/fetchBalance');
    final Map<String, dynamic> $params = <String, dynamic>{
      'provider': provider
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CGBalanceResponse, CGBalanceResponse>($request);
  }

  @override
  Future<Response<dynamic>> addCGMoney({required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('https://rgc.dmxchge.com/api/Casino/addMoney');
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
  Future<Response<dynamic>> withCGDrawMoney(
      {required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/withDrawMoney');
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
  Future<Response<CasinoHistoryResponse>> getCGHistory(
    String fromDate,
    String toDate,
    int limit,
    int page,
  ) {
    final Uri $url = Uri.parse('https://rgc.dmxchge.com/api/Casino/history');
    final Map<String, dynamic> $params = <String, dynamic>{
      'From': fromDate,
      'To': toDate,
      'Limit': limit,
      'Page': page,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CasinoHistoryResponse, CasinoHistoryResponse>($request);
  }

  @override
  Future<Response<dynamic>> fetchPremium({required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('https://rgc.dmxchge.com/api/Casino/cricket');
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
  Future<Response<SportsBookResponse>> getSportsBookHistory(
    String status,
    String fromDate,
    String toDate,
    int limit,
    int page,
  ) {
    final Uri $url =
        Uri.parse('https://rgc.dmxchge.com/api/Casino/sportHistory');
    final Map<String, dynamic> $params = <String, dynamic>{
      'status': status,
      'From': fromDate,
      'To': toDate,
      'Limit': limit,
      'Page': page,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SportsBookResponse, SportsBookResponse>($request);
  }
}
