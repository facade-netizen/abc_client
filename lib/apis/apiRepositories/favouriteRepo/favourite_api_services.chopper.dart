// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FavouriteApiServices extends FavouriteApiServices {
  _$FavouriteApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FavouriteApiServices;

  @override
  Future<Response<dynamic>> addFavouriteEvents(
      {required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/favorites');
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
  Future<Response<FavouriteModelResponse>> fetchFavEvent() {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/favorites');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<FavouriteModelResponse, FavouriteModelResponse>($request);
  }

  @override
  Future<Response<MMFancyMarketResponse>> fetchMMFancy() {
    final Uri $url =
        Uri.parse('https://abcdata.dmxchge.com/api/favorites/Fancy');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<MMFancyMarketResponse, MMFancyMarketResponse>($request);
  }

  @override
  Future<Response<dynamic>> removeFavouriteEvents(
      {required Map<String, dynamic> body}) {
    final Uri $url = Uri.parse('https://abcdata.dmxchge.com/api/favorites');
    final $body = body;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<FavouriteStakeResponse>> getFavStake() {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/utility/favStake');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client
        .send<FavouriteStakeResponse, FavouriteStakeResponse>($request);
  }

  @override
  Future<Response<dynamic>> addFavStake({required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/utility/favStake');
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
  Future<Response<dynamic>> updateFavStake(
      {required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/utility/favStake');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AddedMMResponse>> fetchAddedFavEvent() {
    final Uri $url =
        Uri.parse('https://abcdata.dmxchge.com/api/favorites/detail');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AddedMMResponse, AddedMMResponse>($request);
  }

  @override
  Future<Response<OneClickBetResponse>> getOneClickData() {
    final Uri $url = Uri.parse('https://abcuser.dmxchge.com/api/oneclick');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<OneClickBetResponse, OneClickBetResponse>($request);
  }

  @override
  Future<Response<dynamic>> updateOnclickBetAllStakes(
      {required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/oneclick/allStakes');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
