import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authBlocs/user_login_bloc.dart';
import '../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../blocs/miscBlocs/change_main_menu_index.dart';
import '../blocs/miscBlocs/change_page_index.dart' as page_index;
import '../blocs/miscBlocs/sports_left_panel_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';

// import all required blocs here

class LogoutHelper {
  static void resetAll(BuildContext context) {
    // Auth & Fav
    context.read<FetchFavStakeBloc>().add(SetToInitialFetchFavStake());
    context.read<UserLoginBloc>().add(SetLoginToInitial());

    // Navigation reset
    context.read<ChangeMainTabViewBloc>().add(ChangePageSetToInit());
    context.read<page_index.ChangePageViewBloc>().add(page_index.ChangePageSetToInit());
    context.read<SportsLeftPanelBloc>().add(ResetSportsPanel());

    // Market/data reset
    context.read<FetchBookMakerBloc>().add(SetToInitialBM());
    context.read<FetchODDSDataBloc>().add(SetToInitialODDS());
    context.read<FetchFancyDataBloc>().add(SetToInitialFancy());
    context.read<FetchScoreBoardBloc>().add(SetToInitialFetchScoreBoard());

    // Realtime reset
    context.read<SignalRBMDataBloc>().add(SetToInitialSignalRBM());
    context.read<SignalRODDSDataBloc>().add(SetToInitialSignalRTODDS());
    context.read<SignalRFancyDataBloc>().add(SetToInitialSignalRFancy());
    context.read<SignalRAccountDataBloc>().add(SetToInitialSignalRAccount());
    context.read<SignalRMessageBloc>().add(SetToInitialSignalRMessage());

    // Profit/Loss reset
    context.read<BmProfitLossBloc>().add(SetToInitialBmProfitLoss());
    context.read<OddsProfitLossBloc>().add(SetToInitialOddsProfitLoss());
    context.read<FancyProfitLossBloc>().add(SetToInitialFancyProfitLoss());
  }
}