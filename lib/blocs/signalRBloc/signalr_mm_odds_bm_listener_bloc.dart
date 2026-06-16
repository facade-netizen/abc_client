import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import 'protoUsage/receive/receive.pb.dart';

/// CONNECTION STATE
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

/// ODDS STREAM
final StreamController<ABCModel> mmOddsStreamController = StreamController<ABCModel>.broadcast();
Stream<ABCModel> get mmOddsStream => mmOddsStreamController.stream;

/// BOOKMAKER STREAM
final StreamController<ABCModel> mmBmStreamController = StreamController<ABCModel>.broadcast();
Stream<ABCModel> get mmBmStream => mmBmStreamController.stream;

class SignalRMMOddBMListenerBloc extends Bloc<SignalRMMOddBMListenerEvent, SignalRMMOddBMListenerState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(SportsApiConstants.bmSignalRUrl, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();

  /// CURRENT EVENT
  List<String>? currentEventIds;

  final Map<String, ABCModel> oddsMarketMap = {};
  final Map<String, ABCModel> bmMarketMap = {};

  SignalRMMOddBMListenerBloc() : super(SignalRMMOddBMListenerInitial()) {
    /// SUBSCRIBE EVENT
    on<SignalRMMOddBMListener>((event, emit) async {
      emit(SignalRMMOddBMListenerProgress());

      currentEventIds = _sanitizeEventIds(event.eventId);

      /// CLEAR OLD EVENT DATA
      oddsMarketMap.clear();
      bmMarketMap.clear();

      connectionStateController.add('connecting');
      try {
        if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
          await send(currentEventIds!);
        } else {
          await connect(currentEventIds!);
        }
      } catch (e) {
        connectionStateController.add('disconnected');
        emit(SignalRMMOddBMListenerFailure(e.toString()));
      }
    });

    /// UNSUBSCRIBE EVENT
    on<SignalREventOddBMDisconnect>((event, emit) async {
      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await hubConnection.invoke("UnSubscribeMultiEvents", args: [event.eventId ?? 0]);
        }

        /// REMOVE PREVIOUS EVENT DATA
        oddsMarketMap.clear();
        bmMarketMap.clear();
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
      if (currentEventIds != null) {
        await send(currentEventIds!);
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
  }

  /// ODDS PARSER
  void parseProtoToOddsModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          final String base64String = message.first as String;
          final bytes = base64.decode(base64String);
          final ABCModel model = ABCModel.fromBuffer(bytes);

          final incomingEventId = _sanitizeEventId(model.eventId);
          if (currentEventIds == null || !currentEventIds!.contains(incomingEventId)) return;
          oddsMarketMap[model.marketId] = model;
          mmOddsStreamController.add(model);
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
          final incomingEventId = _sanitizeEventId(model.eventId);
          if (currentEventIds == null || !currentEventIds!.contains(incomingEventId)) return;
          bmMarketMap[model.marketId] = model;
          mmBmStreamController.add(model);
        }
      } catch (e) {
        debugPrint("BM parse error $e");
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
      final result = await hubConnection.invoke("SubscribeBookAndOdds", args: [sanitizedIds]);
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
    mmOddsStreamController.close();
    mmBmStreamController.close();
    return super.close();
  }
}

/// STATES

abstract class SignalRMMOddBMListenerState {}

class SignalRMMOddBMListenerInitial extends SignalRMMOddBMListenerState {}

class SignalRMMOddBMListenerProgress extends SignalRMMOddBMListenerState {}

class SignalRMMOddBMListenerSuccess extends SignalRMMOddBMListenerState {}

class SignalRMMOddBMListenerFailure extends SignalRMMOddBMListenerState {
  final dynamic error;
  SignalRMMOddBMListenerFailure(this.error);
}

/// EVENTS

abstract class SignalRMMOddBMListenerEvent {}

class SignalRMMOddBMListener extends SignalRMMOddBMListenerEvent {
  final List<String> eventId;
  SignalRMMOddBMListener({required this.eventId});
}

class SignalREventOddBMDisconnect extends SignalRMMOddBMListenerEvent {
  final String? eventId;
  SignalREventOddBMDisconnect({this.eventId});
}
