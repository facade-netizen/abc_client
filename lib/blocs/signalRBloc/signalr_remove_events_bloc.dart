import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';

///connection Listener
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

final StreamController<String> removeEventsStreamController = StreamController.broadcast();
Stream<String> get removeEventsStream => removeEventsStreamController.stream;
String? token;

class RemoveEventsListenerBloc extends Bloc<RemoveEventsListenerEvent, RemoveEventsListenerState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(SportsApiConstants.eventHub, options: HttpConnectionOptions(accessTokenFactory: () async => token ?? "", requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();

  RemoveEventsListenerBloc() : super(RemoveEventsListenerInitial()) {
    on<RemoveEventsListener>((event, emit) async {
      if (kDebugMode) debugPrint("[RemoveEventsListenerBloc] RemoveEventsListener event called");
      connectionStateController.add('connecting');
      emit(RemoveEventsListenerProgress());

      try {
        if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
          await send();
        } else {
          await connect();
        }
      } catch (e) {
        connectionStateController.add('disconnected');
        emit(RemoveEventsListenerFailure(e.toString()));
      }
    });
    on<DisconnectUserSessionSignalR>((event, emit) async {
      debugPrint("[RemoveEventsListenerBloc] DisconnectMultiEventsSignalR called for User");
      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          if (kDebugMode) debugPrint("[RemoveEventsListenerBloc] Unsubscribed from User");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("[RemoveEventsListenerBloc] SignalR unsubscribe failed: $e");
      }
    });

    /// Handling Reconnection Events
    hubConnection.onreconnecting(({Object? error}) async {
      if (kDebugMode) debugPrint("[RemoveEventsListenerBloc] SignalR reconnecting: $error");
      connectionStateController.add('reconnecting');
    });

    hubConnection.onreconnected(({String? connectionId}) async {
      if (kDebugMode) debugPrint("[RemoveEventsListenerBloc] SignalR reconnected $connectionId");
      connectionStateController.add('reconnected');
      await send();
    });

    hubConnection.on('eventUpdate', (message) {
      parseProtoToOddsModel(message);
    });
  }

  void parseProtoToOddsModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          removeEventsStreamController.sink.add(message.first.toString());
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  Future<void> connect() async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      try {
        await hubConnection.start();
        if (kDebugMode) debugPrint("Hub listener SignalR Connection Start");
        await send();
      } catch (e) {
        await send();
        if (kDebugMode) debugPrint("[RemoveEventsListenerBloc Connect Failed] SignalR connect failed: $e");
      }
    }
  }

  Future<void> send() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      try {
        if (kDebugMode) debugPrint("[RemoveEventsListenerBloc Send] SignalR Send Done, Result ");
      } catch (e) {
        if (kDebugMode) debugPrint("[RemoveEventsListenerBloc Send Failed] SignalR send failed: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      connectionStateController.close();
      removeEventsStreamController.close();
      await hubConnection.stop();
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionStateController.close();
    removeEventsStreamController.close();
    return super.close();
  }
}

abstract class RemoveEventsListenerState {}

class RemoveEventsListenerInitial extends RemoveEventsListenerState {}

class RemoveEventsListenerProgress extends RemoveEventsListenerState {}

class RemoveEventsListenerSuccess extends RemoveEventsListenerState {
  final String data;
  RemoveEventsListenerSuccess(this.data);
}

class RemoveEventsListenerFailure extends RemoveEventsListenerState {
  final dynamic error;
  RemoveEventsListenerFailure(this.error);
}

abstract class RemoveEventsListenerEvent {}

class RemoveEventsListener extends RemoveEventsListenerEvent {}

class DisconnectUserSessionSignalR extends RemoveEventsListenerEvent {}
