import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/fancy_model.dart';
import 'protoUsage/receive/receive.pb.dart';

/// CONNECTION STATE
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

/// ODDS STREAM
final StreamController<ABCModel> oddsStreamController = StreamController<ABCModel>.broadcast();
Stream<ABCModel> get oddsStream => oddsStreamController.stream;

/// BOOKMAKER STREAM
final StreamController<ABCModel> bmStreamController = StreamController<ABCModel>.broadcast();
Stream<ABCModel> get bmStream => bmStreamController.stream;

/// LINE STREAM
final StreamController<Map<String, FancyMarketData>> lineStreamController = StreamController<Map<String, FancyMarketData>>.broadcast();
Stream<Map<String, FancyMarketData>> get lineStream => lineStreamController.stream;

class SignalREventListenerBloc extends Bloc<SignalREventListenerEvent, SignalREventListenerState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(SportsApiConstants.bmSignalRUrl, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();

  /// CURRENT EVENT
  String? currentEventId;

  final Map<String, ABCModel> oddsMarketMap = {};
  final Map<String, ABCModel> bmMarketMap = {};
  final Map<String, FancyMarketData> lineMarketMap = {};

  SignalREventListenerBloc() : super(SignalREventListenerInitial()) {
    /// SUBSCRIBE EVENT
    on<SignalREventListener>((event, emit) async {
      emit(SignalREventListenerProgress());

      currentEventId = event.eventId;

      /// CLEAR OLD EVENT DATA
      oddsMarketMap.clear();
      bmMarketMap.clear();
      lineMarketMap.clear();

      connectionStateController.add('connecting');
      try {
        if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
          await send(event.eventId);
        } else {
          await connect(event.eventId);
        }
      } catch (e) {
        connectionStateController.add('disconnected');
        emit(SignalREventListenerFailure(e.toString()));
      }
    });

    /// UNSUBSCRIBE EVENT
    on<SignalREventDisconnect>((event, emit) async {
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

    /// ODDS LISTENER
    hubConnection.on('odds', (message) {
      parseProtoToOddsModel(message);
    });

    /// BOOKMAKER LISTENER
    hubConnection.on('bookmaker', (message) {
      parseProtoToBookMakerModel(message);
    });

    /// LINE LISTENER
    hubConnection.on('lines', (message) {
      parseProtoToLineModel(message);
    });
    hubConnection.on('line', (message) {
      parseProtoToLineModel(message, isLine: true);
    });
  }

  /// ODDS PARSER
  void parseProtoToOddsModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          final String base64String = message.first as String;
          final bytes = base64.decode(base64String);
          final ABCModel model = ABCModel.fromBuffer(bytes);
          if (model.eventId != currentEventId) return;
          oddsMarketMap[model.marketId] = model;
          oddsStreamController.add(model);
        }
      } catch (e) {
        debugPrint("Odds parse error $e");
      }
    }
  }

  /// BOOKMAKER PARSER
  void parseProtoToBookMakerModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          final String base64String = message.first as String;
          final bytes = base64.decode(base64String);
          final ABCModel model = ABCModel.fromBuffer(bytes);
          if (model.eventId != currentEventId) return;
          bmMarketMap[model.marketId] = model;
          bmStreamController.add(model);
        }
      } catch (e) {
        debugPrint("BM parse error $e");
      }
    }
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
            if (model.eventId != currentEventId) return;
            FancyMarketData fancyData = FancyMarketData.fromBuffer(model);
            lineMarketMap[model.marketId] = fancyData;
            lineStreamController.add(Map<String, FancyMarketData>.from(lineMarketMap));
          } else {
            final String base64String = message.first as String;
            final bytes = base64.decode(base64String);
            final ABCModelList modelList = ABCModelList.fromBuffer(bytes);
            for (final model in modelList.items) {
              if (model.eventId != currentEventId) continue;
              final FancyMarketData fancyData = FancyMarketData.fromBuffer(model);
              lineMarketMap[model.marketId] = fancyData;
            }
            lineStreamController.add(Map<String, FancyMarketData>.from(lineMarketMap));
          }
        }
      } catch (e) {
        debugPrint("LINE parse error $e");
      }
    }
  }

  Future<void> connect(String eventId) async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      await hubConnection.start();
      if (kDebugMode) debugPrint("SignalR Connected");
      await send(eventId);
    }
  }

  Future<void> send(String eventId) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      final result = await hubConnection.invoke("SubscribeEvent", args: [eventId]);
      if (kDebugMode) debugPrint("Subscribe Done $result");
    }
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      try {
        await hubConnection.stop();
      } catch (error, stackTrace) {
        if (kDebugMode) debugPrint('[SignalREventListenerBloc] stop failed: $error\n$stackTrace');
      }
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionStateController.close();
    oddsStreamController.close();
    bmStreamController.close();
    lineStreamController.close();
    return super.close();
  }
}

/// STATES

abstract class SignalREventListenerState {}

class SignalREventListenerInitial extends SignalREventListenerState {}

class SignalREventListenerProgress extends SignalREventListenerState {}

class SignalREventListenerSuccess extends SignalREventListenerState {}

class SignalREventListenerFailure extends SignalREventListenerState {
  final dynamic error;
  SignalREventListenerFailure(this.error);
}

/// EVENTS

abstract class SignalREventListenerEvent {}

class SignalREventListener extends SignalREventListenerEvent {
  final String eventId;
  SignalREventListener({required this.eventId});
}

class SignalREventDisconnect extends SignalREventListenerEvent {
  final String? eventId;
  SignalREventDisconnect({this.eventId});
}
