import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../apis/apiRepositories/scoreboardRepo/scoreboard_api_repo.dart';
import '../apis/apiRepositories/sports/sports_api_repository.dart';
import '../blocs/addBloc/add_cg_money_bloc.dart';
import '../blocs/addBloc/add_fav_stake_bloc.dart';
import '../blocs/addBloc/add_favourite_event_bloc.dart';
import '../blocs/addBloc/recall_cg_balance_bloc.dart';
import '../blocs/addBloc/send_order_bloc.dart';
import '../blocs/addBloc/update_onclick_bet_bloc.dart';
import '../blocs/authBlocs/change_password_bloc.dart';
import '../blocs/authBlocs/reset_password_bloc.dart';
import '../blocs/authBlocs/user_auth_change_bloc.dart';
import '../blocs/authBlocs/user_login_bloc.dart';
import '../blocs/authBlocs/user_logout_bloc.dart';
import '../blocs/fetchBlocs/fetch_added_mm_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_all_events_for_search_bloc.dart';
import '../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../blocs/fetchBlocs/fetch_book_maker_bloc.dart';
import '../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../blocs/fetchBlocs/fetch_cg_category_bloc.dart';
import '../blocs/fetchBlocs/fetch_cg_history_bloc.dart';
import '../blocs/fetchBlocs/fetch_competation_with_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_current_bets_bloc.dart';
import '../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../blocs/fetchBlocs/fetch_fancy_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../blocs/fetchBlocs/fetch_inplay_count_only_bloc.dart';
import '../blocs/fetchBlocs/fetch_line_result_bloc.dart';
import '../blocs/fetchBlocs/fetch_lmt_match_id_bloc.dart';
import '../blocs/fetchBlocs/fetch_match_result_bloc.dart';
import '../blocs/fetchBlocs/fetch_mm_fancy_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_news_announcements_bloc.dart';
import '../blocs/fetchBlocs/fetch_odds_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_one_click_data_bloc.dart';
import '../blocs/fetchBlocs/fetch_only_inplay_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../blocs/fetchBlocs/fetch_orders_bloc.dart';
import '../blocs/fetchBlocs/fetch_odds_runners_pl_bloc.dart';
import '../blocs/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../blocs/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../blocs/fetchBlocs/fetch_premium_market_bloc.dart';
import '../blocs/fetchBlocs/fetch_profit_loss_by_order_bloc.dart';
import '../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../blocs/fetchBlocs/fetch_sport_events_bloc.dart';
import '../blocs/fetchBlocs/fetch_sportsbook_history_bloc.dart';
import '../blocs/fetchBlocs/fetch_sprots_category_bloc.dart';
import '../blocs/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../blocs/fetchBlocs/fetch_user_mm_fancy_pl_bloc.dart';
import '../blocs/fetchBlocs/fetch_user_mm_markets_pl_bloc.dart';
import '../blocs/fetchBlocs/fetch_wl_details_bloc.dart';
import '../blocs/fileBlocs/file_download_bloc.dart';
import '../blocs/miscBlocs/bet_slip_bloc.dart';
import '../blocs/miscBlocs/change_main_menu_index.dart';
import '../blocs/miscBlocs/change_page_index.dart';
import '../blocs/miscBlocs/check_match_stream_live_bloc.dart';
import '../blocs/miscBlocs/enable_match_button_bloc.dart';
import '../blocs/miscBlocs/get_market_id_in_app_bloc.dart';
import '../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../blocs/miscBlocs/sports_left_panel_bloc.dart';
import '../blocs/miscBlocs/user_ip_bloc.dart';
import '../blocs/signalRBloc/signalr_event_listener_bloc.dart';
import '../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../blocs/signalRBloc/signalr_mm_fancy_listener_bloc.dart';
import '../blocs/signalRBloc/signalr_mm_odds_bm_listener_bloc.dart';
import '../blocs/signalRBloc/signalr_remove_events_bloc.dart';
import '../blocs/signalRBloc/single_user_login_session_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/bm_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/bm_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/fancy_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/fancy_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/me_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/message_signalr_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/mm_bm_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/mm_fancy_signalr_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/mm_odds_signalr_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/news_signalr_bloc.dart';
import '../blocs/signalRBloc/singnalRStreamers/odds_profit_loss_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/odds_signar_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/remove_event_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/signalr_account_data_streamer.dart';
import '../blocs/signalRBloc/singnalRStreamers/user_login_session_stream_bloc.dart';
import '../blocs/signalRBloc/subscribe_multievents_signalr_bloc.dart';
import '../blocs/signalRBloc/subscribe_scoring_signalr_bloc.dart';

//
class MainAppBlocProvider extends StatelessWidget {
  const MainAppBlocProvider({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CGApiRepository()),
        RepositoryProvider(create: (_) => AuthApiRepository()),
        RepositoryProvider(create: (_) => SportApiRepository()),
        RepositoryProvider(create: (_) => OrdersApiRepository()),
        RepositoryProvider(create: (_) => FavouriteApiRepository()),
        RepositoryProvider(create: (_) => ScoreBoardApiRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctxt) => NewsSRBloc()),
          BlocProvider(create: (ctxt) => UserIPBloc()),
          BlocProvider(create: (ctxt) => BetSlipBloc()),
          BlocProvider(create: (ctxt) => UserLoginBloc()),
          BlocProvider(create: (ctxt) => UserLogoutBloc()),
          BlocProvider(create: (ctxt) => GetMarketIDBloc()),
          BlocProvider(create: (ctxt) => FileDownloadBloc()),
          BlocProvider(create: (ctxt) => BmProfitLossBloc()),
          BlocProvider(create: (ctxt) => FetchODDSDataBloc()),
          BlocProvider(create: (ctxt) => SignalRBMDataBloc()),
          BlocProvider(create: (ctxt) => ResetPasswordBloc()),
          BlocProvider(create: (ctxt) => OddsProfitLossBloc()),
          BlocProvider(create: (ctxt) => FancyProfitLossBloc()),
          BlocProvider(create: (ctxt) => FetchBookMakerBloc()),
          BlocProvider(create: (ctxt) => FetchFancyDataBloc()),
          BlocProvider(create: (ctxt) => FetchWlDetailsBloc()),
          BlocProvider(create: (ctxt) => ChangePageViewBloc()),
          BlocProvider(create: (ctxt) => SignalRMessageBloc()),
          BlocProvider(create: (ctxt) => SignalRODDSDataBloc()),
          BlocProvider(create: (ctxt) => UserAuthChangesBloc()),
          BlocProvider(create: (ctxt) => SportsLeftPanelBloc()),
          BlocProvider(create: (ctxt) => FetchCGCategoryBloc()),
          BlocProvider(create: (ctxt) => SignalRMMBMDataBloc()),
          BlocProvider(create: (ctxt) => FetchLMTMatchIdBloc()),
          BlocProvider(create: (ctxt) => FetchSportEventsBloc()),
          BlocProvider(create: (ctxt) => SignalRFancyDataBloc()),
          BlocProvider(create: (ctxt) => JoinMatchSignalRBloc()),
          BlocProvider(create: (ctxt) => ChangeMainTabViewBloc()),
          BlocProvider(create: (ctxt) => UserSessionStreamBloc()),
          BlocProvider(create: (ctxt) => EnableMatchButtonBloc()),
          BlocProvider(create: (ctxt) => SignalRMMODDSDataBloc()),
          BlocProvider(create: (ctxt) => SignalRAccountDataBloc()),
          BlocProvider(create: (ctxt) => SignalRHubListenerBloc()),
          BlocProvider(create: (ctxt) => SignalRMMFancyDataBloc()),
          BlocProvider(create: (ctxt) => FetchSportsCategoryBloc()),
          BlocProvider(create: (ctxt) => SignalREventListenerBloc()),
          BlocProvider(create: (ctxt) => CheckMatchStreamLiveBloc()),
          BlocProvider(create: (ctxt) => RemoveEventsListenerBloc()),
          BlocProvider(create: (ctxt) => FetchOnlyInplayEventsBloc()),
          BlocProvider(create: (ctxt) => FetchOnlyInplayCountsBloc()),
          BlocProvider(create: (ctxt) => SignalRMMFancyListenerBloc()),
          BlocProvider(create: (ctxt) => MultiEventsSignalRDataBloc()),
          BlocProvider(create: (ctxt) => FetchNewsAnnouncementsBloc()),
          BlocProvider(create: (ctxt) => SignalRMMOddBMListenerBloc()),
          BlocProvider(create: (ctxt) => FetchAllEventsForSearchBloc()),
          BlocProvider(create: (ctxt) => FetchCompetitionWithEventsBloc()),
          BlocProvider(create: (ctxt) => RemoveEventSignalRStreamerBloc()),
          BlocProvider(create: (ctxt) => SubscribeMultiEventsSignalRBloc()),
          BlocProvider(create: (ctxt) => SingleUserLoginSessionStreamerRBloc()),
          BlocProvider(create: (context) => AddCGMoneyBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchPremiumBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => SendOrderBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchCGBalanceBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchCGHistoryBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => RecallCGBalanceBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchOrdersBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => ChangePasswordBloc(context.read<AuthApiRepository>())),
          BlocProvider(create: (context) => FetchMatchResultBloc(context.read<SportApiRepository>())),
          BlocProvider(create: (context) => FetchLineResultBloc(context.read<SportApiRepository>())),
          BlocProvider(create: (context) => FetchMMFancyBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchFancyBookBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => AddFavStakeBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchPlByOrdersBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchOpenOrdersBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchBMRunnerPLBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchCurrentBetsBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchFavStakeBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchOddsRunnerPLBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchFavouriteBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchSportsBookHistoryBloc(context.read<CGApiRepository>())),
          BlocProvider(create: (context) => FetchUserMMFancyPLBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchUserMMPLOddBMBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchScoreBoardBloc(context.read<ScoreBoardApiRepository>())),
          BlocProvider(create: (context) => FetchFancyRunnerPLBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => UpdateOnclickBetBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchUserActivityLogsBloc(context.read<AuthApiRepository>())),
          BlocProvider(create: (context) => FetchOneClickDataBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchAddedMMEventsBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => AddFavouriteEventsBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchPlayerBetHistoryBloc(context.read<OrdersApiRepository>())),
          BlocProvider(create: (context) => FetchUserAccountDetailsBloc(context.read<AuthApiRepository>())),
          BlocProvider(create: (context) => RemoveFavouriteEventsBloc(context.read<FavouriteApiRepository>())),
          BlocProvider(create: (context) => FetchPlayerProfitAndLossBloc(context.read<OrdersApiRepository>())),
        ],
        child: child,
      ),
    );
  }
}
