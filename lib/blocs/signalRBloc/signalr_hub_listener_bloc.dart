import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../localDb/token/login_token_box.dart';
import '../../localDb/token/login_token_model.dart';
import '../../models/runners_pl_model.dart';
import '../../models/user_details_model.dart';

/// reconnection Listener
final StreamController<String> connectionHubStateController = StreamController<String>.broadcast();
Stream<String> get connectionHubStateStream => connectionHubStateController.stream;

// Account Streamer
final StreamController<UserAccountDetails> accountStreamController = StreamController.broadcast();
Stream<UserAccountDetails> get accountStream => accountStreamController.stream;

// Message Streamer
final StreamController<String> msgStreamController = StreamController.broadcast();
Stream<String> get msgStream => msgStreamController.stream;

///
final StreamController<List<FancyRunnerPLData>> fancyPLController = StreamController.broadcast();
Stream<List<FancyRunnerPLData>> get fancyPLStream => fancyPLController.stream;

///
final StreamController<List<BMRunnerPLData>> bmPLController = StreamController.broadcast();
Stream<List<BMRunnerPLData>> get bmPLStream => bmPLController.stream;

///
final StreamController<List<OddsRunnerPLData>> oddsPLController = StreamController.broadcast();
Stream<List<OddsRunnerPLData>> get oddsPLStream => oddsPLController.stream;

class SignalRHubListenerBloc extends Bloc<SignalRHubListenerEvent, SignalRHubListenerState> {
  HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(OrdersApiConstants.listener, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000))
      .withAutomaticReconnect()
      .build();

  SignalRHubListenerBloc() : super(SignalRHubListenerInitial()) {
    on<SignalRHubListener>((event, emit) async {
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      if (kDebugMode) debugPrint("SignalRHubListenerBloc Called");
      connectionHubStateController.add('connecting');
      emit(SignalRHubListenerProgress());
      try {
        if (savedTokenData != null) {
          if (hubConnection.state == HubConnectionState.Connected || hubConnection.state == HubConnectionState.Connecting) {
            await send(savedTokenData.token!);
          } else {
            await connect(savedTokenData.token!);
          }
        } else {
          connectionHubStateController.add('disconnected');
          emit(SignalRHubListenerFailure("User not logged in"));
        }
      } catch (e) {
        connectionHubStateController.add('disconnected');
        emit(SignalRHubListenerFailure(e.toString()));
      }
    });

    on<SignalRHubDisconnect>((event, emit) async {
      if (kDebugMode) debugPrint("SignalRHubDisconnect Called ");
      try {} catch (e) {
        if (kDebugMode) debugPrint("SignalR unsubscribe failed: $e");
      }
    });

    /// Handling Reconnection Events
    hubConnection.onreconnecting(({Object? error}) async {
      if (kDebugMode) debugPrint("HUB Listener SignalR reconnecting: $error");
      connectionHubStateController.add('reconnecting');
    });

    hubConnection.onreconnected(({String? connectionId}) async {
      if (kDebugMode) debugPrint("Hub Listener SignalR reconnected $connectionId");
      SaveLoginTokenModel? savedTokenData = SaveTokenBox.loginTokenBox.fetchLoginToken;
      connectionHubStateController.add('reconnected');
      await send(savedTokenData!.token!);
    });

    /// Listener method called odds
    hubConnection.on('message', (message) {
      parseProtoToMessageModel(message, "message Signal");
    });
    hubConnection.on('account', (message) {
      parseProtoToAccountModel(message, "account Signal");
    });
    hubConnection.on('order', (message) {
      parseProtoOrderToMessageModel(message, "Order Message Signal");
    });
    hubConnection.on('profitLoss', (message) {
      parseProtoProfitLossToMessageModel(message, "profitLoss Message Signal");
    });
  }

  void parseProtoToMessageModel(List<Object?>? message, String type) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          msgStreamController.sink.add(message.first.toString());
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  void parseProtoOrderToMessageModel(List<Object?>? message, String type) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          msgStreamController.sink.add(message.first.toString());
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  void parseProtoToAccountModel(List<Object?>? message, String type) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          final Map<String, dynamic> jsonMap = json.decode(message.first.toString());
          final UserAccountDetails model = UserAccountDetails.fromJson(jsonMap);
          accountStreamController.sink.add(model);
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  void parseProtoProfitLossToMessageModel(List<Object?>? message, String type) {
    if (message != null && message.isNotEmpty) {
      try {
        if (message.runtimeType.toString() == "Uint8List" || message.runtimeType.toString().contains("minified") || message.runtimeType == List<Object?>) {
          // debugPrint('jsonMap: ${message.first.toString()}');
          final List<dynamic> jsonList = json.decode(message.first.toString());
          final List<FancyRunnerPLData> fpl =
              jsonList.where((e) => (e['bettingType'] as String).toUpperCase() == "LINE").map((e) => FancyRunnerPLData.fromJson(e as Map<String, dynamic>)).toList();
          final List<BMRunnerPLData> bmpl = jsonList
              .where((e) => (e['bettingType'] as String).toUpperCase() == "BOOKMAKER" || (e['bettingType'] as String).toUpperCase() == "BM")
              .map((e) => BMRunnerPLData.fromJson(e as Map<String, dynamic>))
              .toList();
          final List<OddsRunnerPLData> oddsPl =
              jsonList.where((e) => (e['bettingType'] as String).toUpperCase() == "ODDS").map((e) => OddsRunnerPLData.fromJson(e as Map<String, dynamic>)).toList();
          fancyPLController.add(fpl);
          bmPLController.add(bmpl);
          oddsPLController.add(oddsPl);
        } else {
          if (kDebugMode) debugPrint("Message type not recognized : ${message.runtimeType.toString()}");
        }
      } catch (e) {
        if (kDebugMode) debugPrint("Caught Error : $e");
      }
    }
  }

  Future<void> connect(String token) async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      try {
        await hubConnection.start();
        if (kDebugMode) debugPrint("Hub listener SignalR Connection Start");
        await send(token);
      } catch (e) {
        if (kDebugMode) debugPrint("Hub listener SignalR connect failed: $e");
      }
    }
  }

  Future<void> send(String token) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      try {
        final result = await hubConnection.invoke("AuthenticateUser", args: [token]);
        if (kDebugMode) debugPrint("Hub listener SignalR Send Done, Result - $result");
      } catch (e) {
        if (kDebugMode) debugPrint("Hub listener SignalR send failed: $e");
      }
    }
  }

  Future<void> disconnect() async {
    if (hubConnection.state == HubConnectionState.Connected) {
      connectionHubStateController.close();
      accountStreamController.close();
      msgStreamController.close();
      fancyPLController.close();
      bmPLController.close();
      oddsPLController.close();
      await hubConnection.stop();
    }
  }

  @override
  Future<void> close() async {
    await disconnect();
    connectionHubStateController.close();
    accountStreamController.close();
    msgStreamController.close();
    fancyPLController.close();
    bmPLController.close();
    oddsPLController.close();
    return super.close();
  }
}

abstract class SignalRHubListenerState {}

class SignalRHubListenerInitial extends SignalRHubListenerState {}

class SignalRHubListenerProgress extends SignalRHubListenerState {}

class SignalRHubListenerSuccess extends SignalRHubListenerState {
  SignalRHubListenerSuccess();
}

class SignalRHubListenerFailure extends SignalRHubListenerState {
  final dynamic error;
  SignalRHubListenerFailure(this.error);
}

abstract class SignalRHubListenerEvent {}

class SignalRHubListener extends SignalRHubListenerEvent {}

class SignalRHubDisconnect extends SignalRHubListenerEvent {}
