import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../apis/apiHandlers/api_constants.dart';
import '../../../models/news_announcement_model.dart';

class NewsSRBloc extends Bloc<NewsSREvent, NewsSRState> {
  HubConnection? hubConnection;

  NewsSRBloc() : super(NewsSRInitial()) {
    on<ConnectNewsSR>((event, emit) async {
      emit(NewsSRProgress());

      if (kDebugMode) log("NewsSRBloc Connecting...");

      try {
        if (kDebugMode) log("Building HubConnection to ${AppNewsStringConstants.newsSignalREndpoint}");
        hubConnection = HubConnectionBuilder().withUrl(AppNewsStringConstants.newsSignalREndpoint).withAutomaticReconnect().build();
        hubConnection?.on("message", (arguments) {
          try {
            if (arguments == null || arguments.isEmpty) return;
            final rawData = arguments.first;
            if (kDebugMode) log("SignalR message received: ${rawData.runtimeType}");
            final decoded = rawData is String ? jsonDecode(rawData) : rawData;
            if (kDebugMode) {
              try {
                final pretty = JsonEncoder.withIndent('  ').convert(decoded);
                if (kDebugMode) log("Decoded payload: $pretty");
              } catch (err) {
                if (kDebugMode) log("Decoded payload (raw): $decoded", error: err);
              }
            }
            List<NewsAnnouncement> newsList = [];
            if (decoded is List) {
              newsList = decoded.where((e) => e != null && e is Map<String, dynamic>).map((e) => NewsAnnouncement.fromJson(e as Map<String, dynamic>)).toList();
            } else if (decoded is Map<String, dynamic>) {
              newsList = [NewsAnnouncement.fromJson(decoded)];
            } else {
              if (kDebugMode) log("Unexpected data format: ${decoded.runtimeType}");
              return;
            }
            add(_NewsSRDataReceived(newsList));
          } catch (e) {
            if (kDebugMode) log("Parsing error", error: e);
          }
        });

        await hubConnection?.start();
        if (kDebugMode) log("NewsSR Connected");
        emit(NewsSRConnected());
      } catch (e) {
        log("NewsSR Connection Error: $e", error: e);
        emit(NewsSRFailure(e.toString()));
      }
    });

    on<_NewsSRDataReceived>((event, emit) {
      if (kDebugMode) log("Emitting NewsSRSuccess with ${event.newsList.length} items");
      emit(NewsSRSuccess(newsList: event.newsList));
    });

    on<DisconnectNewsSR>((event, emit) async {
      if (kDebugMode) log("Disconnecting NewsSR...");
      await hubConnection?.stop();
      if (kDebugMode) log("NewsSR Disconnected");
      emit(NewsSRInitial());
    });
  }

  @override
  Future<void> close() async {
    if (kDebugMode) log("Closing NewsSRBloc and stopping hubConnection");
    await hubConnection?.stop();
    return super.close();
  }
}

abstract class NewsSREvent {}

class ConnectNewsSR extends NewsSREvent {}

class DisconnectNewsSR extends NewsSREvent {}

/// Internal event (not used from UI)
class _NewsSRDataReceived extends NewsSREvent {
  final List<NewsAnnouncement> newsList;

  _NewsSRDataReceived(this.newsList);
}

abstract class NewsSRState {}

class NewsSRInitial extends NewsSRState {}

class NewsSRProgress extends NewsSRState {}

class NewsSRConnected extends NewsSRState {}

class NewsSRSuccess extends NewsSRState {
  final List<NewsAnnouncement> newsList;

  NewsSRSuccess({required this.newsList});
}

class NewsSRFailure extends NewsSRState {
  final dynamic error;

  NewsSRFailure(this.error);
}
