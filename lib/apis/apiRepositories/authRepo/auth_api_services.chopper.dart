// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_services.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AuthApiServices extends AuthApiServices {
  _$AuthApiServices([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AuthApiServices;

  @override
  Future<Response<UserAccountResponse>> getUserDetails() {
    final Uri $url = Uri.parse('https://abcuser.dmxchge.com/api/Account');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UserAccountResponse, UserAccountResponse>($request);
  }

  @override
  Future<ActivityLogsResponse> getUserActivityLogs(
      {required Map<String, dynamic> body}) async {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Account/activityLog');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response $response =
        await client.send<ActivityLogsResponse, ActivityLogsResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<dynamic>> changeNewPassword(
      {required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Auth/change-password');
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
  Future<Response<dynamic>> restPassword({required Map<String, dynamic> body}) {
    final Uri $url =
        Uri.parse('https://abcuser.dmxchge.com/api/Auth/change-password-1');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
