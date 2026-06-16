import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import 'protoUsage/receive/receive.pb.dart';

///connection Listener
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;
// Stream for all multi-events
final StreamController<List<ABCModel>> multiEventsStreamController = StreamController<List<ABCModel>>.broadcast();
Stream<List<ABCModel>> get multiEventsStream => multiEventsStreamController.stream;

// Keep internal list of all received ABCModels
final List<ABCModel> multiEventsOutPut = [];

class SubscribeMultiEventsSignalRBloc extends Bloc<SubscribeMultiEventsSignalREvent, SubscribeMultiEventsSignalRState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(SportsApiConstants.bmSignalRUrl, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();
  List<String>? eventIDS;
  SubscribeMultiEventsSignalRBloc() : super(SubscribeMultiEventsSignalRInitial()) {
    on<SubscribeMultiEventsSignalR>((event, emit) async {
      debugPrint("[SubscribeMultiEventsSignalRBloc] SubscribeMultiEventsSignalR event called");
      connectionStateController.add('connecting');
      emit(SubscribeMultiEventsSignalRProgress());
      final List<String> eventIds = _sanitizeEventIds(event.eventIds);
      eventIDS = eventIds;
      try {
        if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
          await send(eventIds);
        } else {
          await connect(eventIds);
        }

        emit(SubscribeMultiEventsSignalRSuccess());
      } catch (e) {
        connectionStateController.add('disconnected');
        emit(SubscribeMultiEventsSignalRFailure(e.toString()));
      }
    });

    on<DisconnectMultiEventsSignalR>((event, emit) async {
      debugPrint("[SubscribeMultiEventsSignalRBloc] DisconnectMultiEventsSignalR called for EventId: ${event.eventIds}");
      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await hubConnection.invoke("UnSubscribeMultiEvents");
          emit(SubscribeMultiEventsSignalRSuccess());
          debugPrint("[SubscribeMultiEventsSignalRBloc] Unsubscribed from EventId: ${event.eventIds}");
        }
      } catch (e) {
        debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR unsubscribe failed: $e");
      }
    });

    /// Handling Reconnection Events
    hubConnection.onreconnecting(({Object? error}) async {
      if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR reconnecting: $error");
      connectionStateController.add('reconnecting');
    });

    hubConnection.onreconnected(({String? connectionId}) async {
      if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR reconnected $connectionId");
      connectionStateController.add('reconnected');
      await send(eventIDS!);
    });

    hubConnection.on('odds', (message) {
      parseProtoToOddsModel(message);
    });
  }

  void parseProtoToOddsModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        final String base64String = message.first as String;
        final Uint8List bytes = base64.decode(base64String);
        final ABCModel me = ABCModel.fromBuffer(bytes);

        // Check if this event already exists in the list
        final index = multiEventsOutPut.indexWhere((e) => e.eventId == me.eventId);
        if (index >= 0) {
          // Update existing event
          multiEventsOutPut[index] = me;
        } else {
          // Add new event
          multiEventsOutPut.add(me);
        }

        // Emit full list
        multiEventsStreamController.sink.add(List<ABCModel>.from(multiEventsOutPut));
      } catch (e) {
        if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] Error parsing odds: $e");
      }
    }
  }

  Future<void> connect(List<String> eventIds) async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      try {
        await hubConnection.start();
        if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR Connection Start");
        await send(eventIds);
      } catch (e) {
        if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR connect failed: $e");
      }
    }
  }

  List<String> _sanitizeEventIds(List<String> eventIds) {
    return eventIds
        .where((id) => !(id.contains('sr:match') || id.contains('vci:match')))
        .map((id) => id.replaceAll(RegExp(r'(?:sr|vci):match:?'), '').trim())
        .where((id) => id.isNotEmpty)
        .toList();
  }

  Future<void> send(List<String> eventIds) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      try {
        final result = await hubConnection.invoke("SubscribeMultiEvents", args: [eventIds]);
        if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR Send Done, Result - $result >> $eventIds");
      } catch (e) {
        if (kDebugMode) debugPrint("[SubscribeMultiEventsSignalRBloc] SignalR send failed: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      connectionStateController.close();
      multiEventsStreamController.close();
      await hubConnection.stop();
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionStateController.close();
    multiEventsStreamController.close();
    return super.close();
  }
}

abstract class SubscribeMultiEventsSignalRState {}

class SubscribeMultiEventsSignalRInitial extends SubscribeMultiEventsSignalRState {}

class SubscribeMultiEventsSignalRProgress extends SubscribeMultiEventsSignalRState {}

class SubscribeMultiEventsSignalRSuccess extends SubscribeMultiEventsSignalRState {}

class SubscribeMultiEventsSignalRFailure extends SubscribeMultiEventsSignalRState {
  final dynamic error;
  SubscribeMultiEventsSignalRFailure(this.error);
}

abstract class SubscribeMultiEventsSignalREvent {}

class SubscribeMultiEventsSignalR extends SubscribeMultiEventsSignalREvent {
  final List<String> eventIds;
  SubscribeMultiEventsSignalR({required this.eventIds});
}

class DisconnectMultiEventsSignalR extends SubscribeMultiEventsSignalREvent {
  final List<String>? eventIds;
  DisconnectMultiEventsSignalR({this.eventIds});
}
