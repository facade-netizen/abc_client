import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/mm_fancy_model.dart';
import 'protoUsage/receive/receive.pb.dart';

/// CONNECTION STATE
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

/// LINE STREAM
final StreamController<Map<String, MMFancyMarketData>> lineMMStreamController = StreamController<Map<String, MMFancyMarketData>>.broadcast();
Stream<Map<String, MMFancyMarketData>> get lineMMStream => lineMMStreamController.stream;

class SignalRMMFancyListenerBloc extends Bloc<SignalRMMFancyListenerEvent, SignalRMMFancyListenerState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(SportsApiConstants.bmSignalRUrl, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();

  /// CURRENT EVENT
  List<String>? currentEventId;

  final Map<String, ABCModel> oddsMarketMap = {};
  final Map<String, ABCModel> bmMarketMap = {};
  final Map<String, MMFancyMarketData> lineMarketMap = {};

  SignalRMMFancyListenerBloc() : super(SignalRMMFancyListenerInitial()) {
    /// SUBSCRIBE EVENT
    on<SignalRMMFancyListener>((event, emit) async {
      emit(SignalRMMFancyListenerProgress());

      currentEventId = _sanitizeEventIds(event.eventId);

      /// CLEAR OLD EVENT DATA
      oddsMarketMap.clear();
      bmMarketMap.clear();
      lineMarketMap.clear();

      connectionStateController.add('connecting');
      try {
        if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
          await send(currentEventId!);
        } else {
          await connect(currentEventId!);
        }
      } catch (e) {
        connectionStateController.add('disconnected');
        emit(SignalRMMFancyListenerFailure(e.toString()));
      }
    });

    /// UNSUBSCRIBE EVENT
    on<SignalREventFancyDisconnect>((event, emit) async {
      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await hubConnection.invoke("UnsubscribeEvent", args: [event.eventId ?? 0]);
        }

        /// REMOVE PREVIOUS EVENT DATA
        oddsMarketMap.clear();
        bmMarketMap.clear();
        lineMarketMap.clear();
      } catch (e) {
        debugPrint("SignalR unsubscribe failed: $e");
      }
    });

    /// RECONNECTING
    hubConnection.onreconnecting(({Object? error}) {
      if (kDebugMode) debugPrint("SignalR reconnecting: $error");
      connectionStateController.add('reconnecting');
    });

    /// RECONNECTED
    hubConnection.onreconnected(({String? connectionId}) async {
      if (kDebugMode) debugPrint("SignalR reconnected");
      connectionStateController.add('reconnected');
      if (currentEventId != null) {
        await send(currentEventId!);
      }
    });

    /// LINE LISTENER
    hubConnection.on('line', (message) {
      parseProtoToLineModel(message, isLine: true);
    });

    /// LINE LISTENER
    hubConnection.on('lines', (message) {
      parseProtoToLineModel(message);
    });
  }

  /// LINE PARSER
  void parseProtoToLineModel(List<Object?>? message, {bool isLine = false}) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          if (isLine) {
            final String base64String = message.first as String;
            final bytes = base64.decode(base64String);
            final ABCModel model = ABCModel.fromBuffer(bytes);
            if (currentEventId == null || !currentEventId!.contains(model.eventId)) return;
            MMFancyMarketData fancyData = MMFancyMarketData.fromBuffer(model);
            lineMarketMap[model.marketId] = fancyData;
            lineMMStreamController.add(Map<String, MMFancyMarketData>.from(lineMarketMap));
          } else {
            final String base64String = message.first as String;
            final bytes = base64.decode(base64String);
            final ABCModelList modelList = ABCModelList.fromBuffer(bytes);
            for (final model in modelList.items) {
              if (currentEventId == null || !currentEventId!.contains(model.eventId)) continue;
              final MMFancyMarketData fancyData = MMFancyMarketData.fromBuffer(model);
              lineMarketMap[model.marketId] = fancyData;
            }
            lineMMStreamController.add(Map<String, MMFancyMarketData>.from(lineMarketMap));
          }
        }
      } catch (e) {
        debugPrint("LINE parse error $e");
      }
    }
  }

  Future<void> connect(List<String> eventId) async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      await hubConnection.start();
      if (kDebugMode) debugPrint("SignalR Connected");
      await send(eventId);
    }
  }

  Future<void> send(List<String> eventId) async {
    final sanitizedIds = _sanitizeEventIds(eventId);
    if (hubConnection.state == HubConnectionState.Connected) {
      final result = await hubConnection.invoke("SubscribeLines", args: [sanitizedIds]);
      if (kDebugMode) debugPrint("Subscribe Done $result");
    }
  }

  List<String> _sanitizeEventIds(List<String> eventIds) {
    return eventIds.map(_sanitizeEventId).where((id) => id.isNotEmpty).toSet().toList();
  }

  String _sanitizeEventId(String eventId) {
    return eventId.replaceAll(RegExp(r'(?:sr|vci):match:?', caseSensitive: false), '').trim();
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.stop();
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionStateController.close();
    lineMMStreamController.close();
    return super.close();
  }
}

/// STATES

abstract class SignalRMMFancyListenerState {}

class SignalRMMFancyListenerInitial extends SignalRMMFancyListenerState {}

class SignalRMMFancyListenerProgress extends SignalRMMFancyListenerState {}

class SignalRMMFancyListenerSuccess extends SignalRMMFancyListenerState {}

class SignalRMMFancyListenerFailure extends SignalRMMFancyListenerState {
  final dynamic error;
  SignalRMMFancyListenerFailure(this.error);
}

/// EVENTS

abstract class SignalRMMFancyListenerEvent {}

class SignalRMMFancyListener extends SignalRMMFancyListenerEvent {
  final List<String> eventId;
  SignalRMMFancyListener({required this.eventId});
}

class SignalREventFancyDisconnect extends SignalRMMFancyListenerEvent {
  final String? eventId;
  SignalREventFancyDisconnect({this.eventId});
}
