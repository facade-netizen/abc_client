// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sports_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SportsApiServices extends SportsApiServices {
  _$SportsApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SportsApiServices;

  @override
  Future<Response<EventTypeResponse>> getSportsCategory() {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/eventTypes');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<EventTypeResponse, EventTypeResponse>($request);
  }

  @override
  Future<Response<ResultResponse>> getResultMatch() {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/resultMatch');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<ResultResponse, ResultResponse>($request);
  }

  @override
  Future<ResultLineResponse> getResultLineMatch(
      {required bool isYesterDay}) async {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/resultLine');
    final Map<String, dynamic> $params = <String, dynamic>{
      'isYesterDay': isYesterDay
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response $response =
        await client.send<ResultLineResponse, ResultLineResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<SportsResponse>> getEventWithType({
    required int evenTypeID,
    required bool tomorrow,
    required bool inPlay,
  }) {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/sportsEvents');
    final Map<String, dynamic> $params = <String, dynamic>{
      'evenTypeID': evenTypeID,
      'tomorrow': tomorrow,
      'inPlay': inPlay,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SportsResponse, SportsResponse>($request);
  }
}
