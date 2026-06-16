import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../signalr_remove_events_bloc.dart';

class RemoveEventSignalRStreamerBloc extends Bloc<RemoveEventSignalRStreamerEvent, RemoveEventSignalRStreamerState> {
  RemoveEventSignalRStreamerBloc() : super(RemoveEventSignalRStreamerInitial()) {
    on<RemoveEventSignalRStreamerListener>((event, emit) async {
      if (kDebugMode) debugPrint("RemoveEventSignalRStreamerListener started");
      emit(RemoveEventSignalRStreamerProgress());
      try {
        await emit.forEach<String>(
          removeEventsStream,
          onData: (msg) {
            final ids = extractEventIds(msg);
            final forInplayIds = extractEventForInplayIds(msg);
            return RemoveEventSignalRStreamerSuccess(ids, forInplayIds);
          },
          onError: (error, stackTrace) {
            if (kDebugMode) debugPrint("RemoveEvent SignalR Error: $error");
            return RemoveEventSignalRStreamerFailure(error);
          },
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error in RemoveEventSignalRStreamerBloc: $e');
        emit(RemoveEventSignalRStreamerFailure(e));
      }
    });

    on<SetToInitialRemoveEventSignalRStreamer>((event, emit) async {
      emit(RemoveEventSignalRStreamerInitial());
    });
  }
  List<String> extractEventForInplayIds(String msg) {
    try {
      final payload = jsonDecode(msg);
      if (payload is Map<String, dynamic>) {
        final signal = payload['Signal']?.toString();
        final directId = payload['id'];
        final data = payload['Data'];
        final extractedIds = tryExtractIdsFromData(data);
        final combinedIds = <String>{};

        if (directId != null) {
          final directIdString = directId.toString();
          if (directIdString.isNotEmpty) combinedIds.add(directIdString);
        }
        combinedIds.addAll(extractedIds);

        if (signal != null) {
          if (signal == 'Delete') {
            return combinedIds.toList();
          }
          if (signal == 'Update') {
            if (data is Map<String, dynamic>) {
              final forceAddInPlay = data['forceAddInPlay'];

              if (forceAddInPlay == false) {
                return combinedIds.toList();
              }
            }
            return <String>[];
          }
        }

        if (combinedIds.isNotEmpty) return combinedIds.toList();

        final arguments = payload['arguments'];
        if (arguments is List && arguments.isNotEmpty && arguments.first is String) {
          final inner = jsonDecode(arguments.first as String);
          if (inner is Map<String, dynamic>) {
            final innerData = inner['Data'];
            final innerSignal = inner['Signal']?.toString();
            final innerIds = tryExtractIdsFromData(innerData).toSet();
            final directInnerId = inner['id'];
            if (directInnerId != null) {
              final directInnerIdString = directInnerId.toString();
              if (directInnerIdString.isNotEmpty) innerIds.add(directInnerIdString);
            }

            if (innerSignal == 'Delete') {
              return innerIds.toList();
            }
            if (innerSignal == 'Update') {
              if (innerData is Map<String, dynamic>) {
                final enabledByAlpha = innerData['enabledByAlpha'];
                final forceAddInPlay = innerData['forceAddInPlay'];
                if (enabledByAlpha == false) {
                  return innerIds.toList();
                }
                if (forceAddInPlay == false) {
                  return innerIds.toList();
                }
              }
              return <String>[];
            }
            if (innerIds.isNotEmpty) return innerIds.toList();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to extract remove-event id: $e');
    }

    return <String>[];
  }

  List<String> extractEventIds(String msg) {
    try {
      final payload = jsonDecode(msg);
      if (payload is Map<String, dynamic>) {
        final signal = payload['Signal']?.toString();
        final directId = payload['id'];
        final data = payload['Data'];
        final extractedIds = tryExtractIdsFromData(data);
        final combinedIds = <String>{};

        if (directId != null) {
          final directIdString = directId.toString();
          if (directIdString.isNotEmpty) combinedIds.add(directIdString);
        }
        combinedIds.addAll(extractedIds);

        if (signal != null) {
          if (signal == 'Delete') {
            return combinedIds.toList();
          }
          if (signal == 'Update') {
            if (data is Map<String, dynamic>) {
              final enabledByAlpha = data['enabledByAlpha'];
              if (enabledByAlpha == false) {
                return combinedIds.toList();
              }
            }
            return <String>[];
          }
        }

        if (combinedIds.isNotEmpty) return combinedIds.toList();

        final arguments = payload['arguments'];
        if (arguments is List && arguments.isNotEmpty && arguments.first is String) {
          final inner = jsonDecode(arguments.first as String);
          if (inner is Map<String, dynamic>) {
            final innerData = inner['Data'];
            final innerSignal = inner['Signal']?.toString();
            final innerIds = tryExtractIdsFromData(innerData).toSet();
            final directInnerId = inner['id'];
            if (directInnerId != null) {
              final directInnerIdString = directInnerId.toString();
              if (directInnerIdString.isNotEmpty) innerIds.add(directInnerIdString);
            }

            if (innerSignal == 'Delete') {
              return innerIds.toList();
            }
            if (innerSignal == 'Update') {
              if (innerData is Map<String, dynamic>) {
                final enabledByAlpha = innerData['enabledByAlpha'];
                final forceAddInPlay = innerData['forceAddInPlay'];
                if (enabledByAlpha == false) {
                  return innerIds.toList();
                }
                if (forceAddInPlay == false) {
                  return innerIds.toList();
                }
              }
              return <String>[];
            }
            if (innerIds.isNotEmpty) return innerIds.toList();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to extract remove-event id: $e');
    }

    return <String>[];
  }

  List<String> tryExtractIdsFromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final ids = <String>[];
      for (final candidate in [
        data['id'],
        data['EventId'],
        data['eventId'],
        data['eventID'],
        data['SREventId'],
      ]) {
        if (candidate != null) {
          final candidateString = candidate.toString();
          if (candidateString.isNotEmpty && !ids.contains(candidateString)) {
            ids.add(candidateString);
          }
        }
      }
      return ids;
    }
    return <String>[];
  }
}

//states
abstract class RemoveEventSignalRStreamerState {}

//events
abstract class RemoveEventSignalRStreamerEvent {}

//states implementation
class RemoveEventSignalRStreamerInitial extends RemoveEventSignalRStreamerState {}

class RemoveEventSignalRStreamerProgress extends RemoveEventSignalRStreamerState {}

class RemoveEventSignalRStreamerSuccess extends RemoveEventSignalRStreamerState {
  RemoveEventSignalRStreamerSuccess(this.ids, this.forInplayIds);
  final List<String> ids;
  final List<String> forInplayIds;
}

class RemoveEventSignalRStreamerFailure extends RemoveEventSignalRStreamerState {
  final dynamic error;
  RemoveEventSignalRStreamerFailure(this.error);
}

//events implementation
class RemoveEventSignalRStreamerListener extends RemoveEventSignalRStreamerEvent {}

class SetToInitialRemoveEventSignalRStreamer extends RemoveEventSignalRStreamerEvent {}
