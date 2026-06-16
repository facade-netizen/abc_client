import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';

///connection Listener
final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

final StreamController<String> userLogoutSessionStreamController = StreamController.broadcast();
Stream<String> get userLogoutSessionStream => userLogoutSessionStreamController.stream;

String? token;

class SingleUserLoginSessionStreamerRBloc extends Bloc<SingleUserLoginSessionStreamerREvent, SingleUserLoginSessionStreamerRState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(loginSession, options: HttpConnectionOptions(accessTokenFactory: () async => token ?? "", requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();
  SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;

  SingleUserLoginSessionStreamerRBloc() : super(SingleUserLoginSessionStreamerRInitial()) {
    on<SingleUserLoginSessionStreamerR>((event, emit) async {
      debugPrint("[SingleUserLoginSessionStreamerRBloc] SingleUserLoginSessionStreamerR event called");
      connectionStateController.add('connecting');
      emit(SingleUserLoginSessionStreamerRProgress());
      token = savedTokenData?.token;
      if (savedTokenData != null && savedTokenData?.token != null) {
        try {
          if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
            await send(savedTokenData?.token);
          } else {
            await connect(savedTokenData?.token);
          }
        } catch (e) {
          connectionStateController.add('disconnected');
          emit(SingleUserLoginSessionStreamerRFailure(e.toString()));
        }
      } else {}
    });
    on<DisconnectUserSessionSignalR>((event, emit) async {
      debugPrint("[SingleUserLoginSessionStreamerRBloc] DisconnectMultiEventsSignalR called for User");
      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await hubConnection.invoke("AuthenticateUser", args: [token!]);
          debugPrint("[SingleUserLoginSessionStreamerRBloc] Unsubscribed from User");
        }
      } catch (e) {
        debugPrint("[SingleUserLoginSessionStreamerRBloc] SignalR unsubscribe failed: $e");
      }
    });

    /// Handling Reconnection Events
    hubConnection.onreconnecting(({Object? error}) async {
      if (kDebugMode) debugPrint("[SingleUserLoginSessionStreamerRBloc] SignalR reconnecting: $error");
      connectionStateController.add('reconnecting');
    });

    hubConnection.onreconnected(({String? connectionId}) async {
      if (kDebugMode) debugPrint("[SingleUserLoginSessionStreamerRBloc] SignalR reconnected $connectionId");
      connectionStateController.add('reconnected');
      await send(savedTokenData?.token);
    });

    hubConnection.on('userUpdate', (message) {
      parseProtoToOddsModel(message);
    });
  }

  void parseProtoToOddsModel(List<Object?>? message) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          userLogoutSessionStreamController.sink.add(message.first.toString());
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  Future<void> connect(String? token) async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      try {
        await hubConnection.start();
        if (kDebugMode) debugPrint("Hub listener SignalR Connection Start");
        await send(token);
      } catch (e) {
        await send(token);
        if (kDebugMode) debugPrint("[SingleUserLoginSessionStreamerRBloc Connect Failed] SignalR connect failed: $e");
      }
    }
  }

  Future<void> send(String? token) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      try {
        final result = await hubConnection.invoke("AuthenticateUser", args: [token!]);
        if (kDebugMode) debugPrint("[SingleUserLoginSessionStreamerRBloc Send] SignalR Send Done, Result - $result ");
      } catch (e) {
        if (kDebugMode) debugPrint("[SingleUserLoginSessionStreamerRBloc Send Failed] SignalR send failed: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      connectionStateController.close();
      userLogoutSessionStreamController.close();
      await hubConnection.stop();
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionStateController.close();
    userLogoutSessionStreamController.close();
    return super.close();
  }
}

abstract class SingleUserLoginSessionStreamerRState {}

class SingleUserLoginSessionStreamerRInitial extends SingleUserLoginSessionStreamerRState {}

class SingleUserLoginSessionStreamerRProgress extends SingleUserLoginSessionStreamerRState {}

class SingleUserLoginSessionStreamerRSuccess extends SingleUserLoginSessionStreamerRState {
  final String data;
  SingleUserLoginSessionStreamerRSuccess(this.data);
}

class SingleUserLoginSessionStreamerRFailure extends SingleUserLoginSessionStreamerRState {
  final dynamic error;
  SingleUserLoginSessionStreamerRFailure(this.error);
}

abstract class SingleUserLoginSessionStreamerREvent {}

class SingleUserLoginSessionStreamerR extends SingleUserLoginSessionStreamerREvent {}

class DisconnectUserSessionSignalR extends SingleUserLoginSessionStreamerREvent {}
