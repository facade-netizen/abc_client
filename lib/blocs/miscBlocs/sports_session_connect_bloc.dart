import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../fetchBlocs/fetch_book_maker_bloc.dart';
import '../fetchBlocs/fetch_fancy_data_bloc.dart';
import '../fetchBlocs/fetch_odds_data_bloc.dart';
import '../fetchBlocs/fetch_scoreboard_bloc.dart';
import '../signalRBloc/signalr_event_listener_bloc.dart';
import '../signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../signalRBloc/subscribe_scoring_signalr_bloc.dart';

enum SessionType { connect, disconnect, na }

void sportsSessionConnect({required BuildContext ctxt, required SessionType type, required String eventId}) {
  switch (type) {
    case SessionType.na:
      if (kDebugMode) log('SportsSessionConnect: NA - skipped');
      return;

    case SessionType.connect:
      ctxt.read<FetchODDSDataBloc>().add(FetchODDSData(eventId: eventId));
      if (kDebugMode) log('Called - SportsSessionConnectBloc - Connect - $eventId');
      ctxt.read<FetchScoreBoardBloc>().add(FetchScoreBoard(eventId: int.tryParse(eventId) ?? 0));
      Future.delayed(const Duration(milliseconds: 500), () {
        ctxt.read<FetchBookMakerBloc>().add(FetchBookMaker(eventId: eventId));
      });
      ctxt.read<FetchFancyDataBloc>().add(FetchFancyData(eventId: eventId));
      ctxt.read<JoinMatchSignalRBloc>().add(JoinMatchSignalR(eventId: int.tryParse(eventId) ?? 0));
      ctxt.read<SignalRBMDataBloc>().add(SignalRBMDataListener());
      ctxt.read<SignalRODDSDataBloc>().add(SignalRODDSDataListener());
      ctxt.read<SignalRFancyDataBloc>().add(SignalRFancyDataListener());
      break;

    case SessionType.disconnect:
      if (kDebugMode) log('Called - SportsSessionConnectBloc - Disconnect - $eventId');
      ctxt.read<SignalREventListenerBloc>().add(SignalREventDisconnect(eventId: "0"));
      ctxt.read<JoinMatchSignalRBloc>().add(DisconnectScoringSignalR(eventId: int.tryParse(eventId) ?? 0));

      ctxt.read<FetchScoreBoardBloc>().add(SetToInitialFetchScoreBoard());
      ctxt.read<FetchBookMakerBloc>().add(SetToInitialBM());
      ctxt.read<FetchFancyDataBloc>().add(SetToInitialFancy());
      ctxt.read<FetchODDSDataBloc>().add(SetToInitialODDS());

      ctxt.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
      ctxt.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
      ctxt.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
      break;
  }
}
