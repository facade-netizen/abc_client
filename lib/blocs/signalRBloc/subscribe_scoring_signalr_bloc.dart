import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../apis/apiHandlers/api_constants.dart';
import '../../models/scoreboard_model.dart';

/// ================= STREAM =================

final StreamController<String> connectionStateController = StreamController<String>.broadcast();
Stream<String> get connectionStateStream => connectionStateController.stream;

/// optional (if needed)
final StreamController<ScoreBoardModel> scoringStreamController = StreamController<ScoreBoardModel>.broadcast();
Stream<ScoreBoardModel> get scoringStream => scoringStreamController.stream;

/// Stream for raw events (for debugging)
final StreamController<Map<String, dynamic>> rawEventController = StreamController<Map<String, dynamic>>.broadcast();
Stream<Map<String, dynamic>> get rawEventStream => rawEventController.stream;

/// ================= BLOC =================

class JoinMatchSignalRBloc extends Bloc<JoinMatchSignalREvent, JoinMatchSignalRState> {
  late HubConnection hubConnection;
  int? eventIdCache;

  JoinMatchSignalRBloc() : super(JoinMatchSignalRInitial()) {
    /// Init connection
    hubConnection = HubConnectionBuilder()
        .withUrl(ScoringApiConstants.criScoreSignalr, options: HttpConnectionOptions(transport: HttpTransportType.WebSockets, requestTimeout: 35000, skipNegotiation: true))
        .withAutomaticReconnect()
        .build();

    /// ================= EVENTS =================
    on<JoinMatchSignalR>((event, emit) async {
      debugPrint("[SignalR] JoinMatch called for eventId: ${event.eventId}");

      emit(JoinMatchSignalRProgress());
      connectionStateController.add('connecting');
      eventIdCache = event.eventId;

      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await _joinMatch(event.eventId);
        } else if (hubConnection.state == HubConnectionState.Connecting) {
          debugPrint("[SignalR] Connection already in progress, waiting to join: ${event.eventId}");
          // Wait for connection to complete
          if (hubConnection.state == HubConnectionState.Connected) {
            await _joinMatch(event.eventId);
          } else {
            await _connect(event.eventId);
          }
        } else {
          await _connect(event.eventId);
        }
      } catch (e) {
        debugPrint("[SignalR] JoinMatch error: $e");
        connectionStateController.add('disconnected');
        emit(JoinMatchSignalRFailure(e.toString()));
      }
    });

    on<_EmitScoreUpdate>((event, emit) {
      emit(JoinMatchSignalRSuccess(scoreBoard: event.data));
    });

    on<DisconnectScoringSignalR>((event, emit) async {
      debugPrint("[SignalR] Disconnect called for eventId: ${event.eventId}");

      try {
        if (hubConnection.state == HubConnectionState.Connected) {
          await hubConnection.invoke("LeaveMatch", args: [event.eventId.toString()]);
          debugPrint("[SignalR] Left match successfully");
        }
      } catch (e) {
        debugPrint("[SignalR] Disconnect error: $e");
      }
    });

    /// ================= SIGNALR LISTENERS =================

    ///Alternative event name
    hubConnection.on('ReceiveScoreUpdate', (message) {
      // debugPrint("[SignalR] Received ReceiveScoreUpdate event");
      _handleScoreUpdate(message);
    });

    ///MAIN EVENT - scoreUpdated (most important)
    hubConnection.on('scoreUpdated', (message) {
      // debugPrint("[SignalR] Received scoreUpdated event");
      _handleScoreUpdate(message);
    });

    ///NEW_BATSMAN event
    hubConnection.on('NEW_BATSMAN', (message) {
      // debugPrint("[SignalR] Received NEW_BATSMAN event");
      _handleScoreUpdate(message);
    });

    ///UNDO_BALL event
    hubConnection.on('UNDO_BALL', (message) {
      // debugPrint("[SignalR] Received UNDO_BALL event");
      _handleScoreUpdate(message);
    });

    ///WICKET event
    hubConnection.on('WICKET', (message) {
      // debugPrint("[SignalR] Received WICKET event");
      _handleScoreUpdate(message);
    });

    ///BALL event
    hubConnection.on('BALL', (message) {
      // debugPrint("[SignalR] Received BALL event");
      _handleScoreUpdate(message);
    });

    ///Generic handler for any unhandled events
    hubConnection.onreconnecting(({Object? error}) {
      debugPrint("[SignalR] reconnecting...: $error");
      connectionStateController.add('reconnecting');
    });

    hubConnection.onreconnected(({String? connectionId}) async {
      debugPrint("[SignalR] reconnected: $connectionId");
      connectionStateController.add('reconnected');

      if (eventIdCache != null) {
        debugPrint("[SignalR] Re-joining match: $eventIdCache");
        await _joinMatch(eventIdCache!);
      }
    });

    hubConnection.onclose(({Object? error}) {
      debugPrint("[SignalR] connection closed: ${error?.toString() ?? 'no error'}");
      connectionStateController.add('disconnected');
    });
  }

  /// ================= MAIN HANDLER =================

  void _handleScoreUpdate(List<Object?>? message) {
    if (message == null || message.isEmpty) {
      debugPrint("[SignalR] Empty message received");
      return;
    }

    // debugPrint("[SignalR] Processing message: $message");

    try {
      // Try to extract ScoreBoardModel from the message
      ScoreBoardModel? model = _extractScoreBoardFromMessage(message);

      if (model != null) {
        if (kDebugMode) {
          // log("PARSED SCORE => Runs: ${model.innings.first.score.runs}, Wickets: ${model.innings.first.score.wickets}");
        }

        // Emit to stream
        scoringStreamController.add(model);

        // Emit to bloc state
        add(_EmitScoreUpdate(model));
      } else {
        // debugPrint("[SignalR] Could not extract ScoreBoardModel from message: $message");

        // Emit raw event for debugging
        rawEventController.add({
          'type': _getEventType(message),
          'rawData': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e, stackTrace) {
      debugPrint("[SignalR] Parse Error: $e");
      debugPrint("[SignalR] StackTrace: $stackTrace");
    }
  }

  String _getEventType(List<Object?> message) {
    if (message.isNotEmpty && message.first is String) {
      return message.first as String;
    }
    return 'unknown';
  }

  ScoreBoardModel? _extractScoreBoardFromMessage(List<Object?> message) {
    // Try different extraction strategies

    // Strategy 1: Message might be a single string containing JSON
    if (message.length == 1 && message.first is String) {
      final String jsonStr = message.first as String;
      if (jsonStr.trim().isNotEmpty) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonStr);
          return ScoreBoardModel.fromJson(json);
        } catch (e) {
         if (kDebugMode) debugPrint("[SignalR] Failed to parse single string JSON: $e");
        }
      }
    }

    // Strategy 2: Message might be an array where the last element is the scoreboard
    for (int i = message.length - 1; i >= 0; i--) {
      final item = message[i];
      if (item is Map) {
        try {
          final Map<String, dynamic> json = jsonDecode(jsonEncode(item));
          // Check if this looks like a scoreboard (has 'innings' or 'currentState')
          if (json.containsKey('innings') || json.containsKey('currentState')) {
            return ScoreBoardModel.fromJson(json);
          }
        } catch (e) {
          // Continue to next item
        }
      } else if (item is String) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('innings') || decoded.containsKey('currentState')) {
              return ScoreBoardModel.fromJson(decoded);
            }
          }
        } catch (e) {
          // Continue
        }
      }
    }

    // Strategy 3: Try to find any JSON object in the message
    for (final item in message) {
      if (item != null) {
        try {
          String itemStr = item.toString();
          // Look for JSON pattern
          if (itemStr.contains('{') && itemStr.contains('}')) {
            // Try to extract JSON substring
            int start = itemStr.indexOf('{');
            int end = itemStr.lastIndexOf('}') + 1;
            if (start >= 0 && end > start) {
              String jsonStr = itemStr.substring(start, end);
              final Map<String, dynamic> json = jsonDecode(jsonStr);
              if (json.containsKey('innings') || json.containsKey('currentState')) {
                return ScoreBoardModel.fromJson(json);
              }
            }
          }
        } catch (e) {
          // Continue
        }
      }
    }

    return null;
  }

  /// ================= CONNECTION =================

  Future<void> _connect(int eventId) async {
    try {
      debugPrint("[SignalR] Starting connection...");
      await hubConnection.start();
      debugPrint("[SignalR] Connected successfully");
      await _joinMatch(eventIdCache ?? eventId);
    } catch (e) {
      debugPrint("[SignalR] Connect failed: $e");
      rethrow;
    }
  }

  Future<void> _joinMatch(int eventId) async {
    try {
      if (hubConnection.state == HubConnectionState.Connected) {
        debugPrint("[SignalR] Joining match: $eventId");
        await hubConnection.invoke("JoinMatch", args: [eventId.toString()]);
        debugPrint("[SignalR] Joined match successfully: $eventId");
        connectionStateController.add('connected');
      } else {
        debugPrint("[SignalR] Cannot join match - connection state: ${hubConnection.state}");
        throw Exception("Connection not ready");
      }
    } catch (e) {
      debugPrint("[SignalR] Join error: $e");
      rethrow;
    }
  }

  Future<void> _disconnect() async {
    try {
      if (hubConnection.state == HubConnectionState.Connected) {
        await hubConnection.stop();
        debugPrint("[SignalR] Disconnected successfully");
      }
    } catch (e) {
      debugPrint("[SignalR] Disconnect error: $e");
    }
  }

  @override
  Future<void> close() async {
    debugPrint("[SignalR] Closing bloc...");
    await _disconnect();
    await connectionStateController.close();
    await scoringStreamController.close();
    await rawEventController.close();
    return super.close();
  }
}

/// ================= STATES =================

abstract class JoinMatchSignalRState {}

class JoinMatchSignalRInitial extends JoinMatchSignalRState {}

class JoinMatchSignalRProgress extends JoinMatchSignalRState {}

class JoinMatchSignalRSuccess extends JoinMatchSignalRState {
  final ScoreBoardModel scoreBoard;
  JoinMatchSignalRSuccess({required this.scoreBoard});
}

class JoinMatchSignalRFailure extends JoinMatchSignalRState {
  final dynamic error;
  JoinMatchSignalRFailure(this.error);
}

/// ================= EVENTS =================

abstract class JoinMatchSignalREvent {}

class JoinMatchSignalR extends JoinMatchSignalREvent {
  final int eventId;
  JoinMatchSignalR({required this.eventId});
}

class DisconnectScoringSignalR extends JoinMatchSignalREvent {
  final int eventId;
  DisconnectScoringSignalR({required this.eventId});
}

/// Internal event (for emitting data)
class _EmitScoreUpdate extends JoinMatchSignalREvent {
  final ScoreBoardModel data;
  _EmitScoreUpdate(this.data);
}
