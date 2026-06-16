import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../apis/apiRepositories/authRepo/auth_api_repository.dart';
import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import '../../apis/apiRepositories/favouriteRepo/favourite_api_repository.dart';
import '../../apis/apiRepositories/ordersRepo/orders_api_repository.dart';
import '../../blocs/addBloc/add_cg_money_bloc.dart';
import '../../blocs/addBloc/add_fav_stake_bloc.dart';
import '../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../blocs/addBloc/recall_cg_balance_bloc.dart';
import '../../blocs/addBloc/send_order_bloc.dart';
import '../../blocs/authBlocs/change_password_bloc.dart';
import '../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../blocs/authBlocs/user_logout_bloc.dart';
import '../../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../../blocs/fetchBlocs/fetch_cg_balance_bloc.dart';
import '../../blocs/fetchBlocs/fetch_cg_history_bloc.dart';
import '../../blocs/fetchBlocs/fetch_current_bets_bloc.dart';
import '../../blocs/fetchBlocs/fetch_current_user_info_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fancy_book_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fancy_runners_pl_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fav_events_bloc.dart';
import '../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../blocs/fetchBlocs/fetch_odds_runners_pl_bloc.dart';
import '../../blocs/fetchBlocs/fetch_open_orders_bloc.dart';
import '../../blocs/fetchBlocs/fetch_orders_bloc.dart';
import '../../blocs/fetchBlocs/fetch_player_bet_history_bloc.dart';
import '../../blocs/fetchBlocs/fetch_player_profit_and_loss_bloc.dart';
import '../../blocs/fetchBlocs/fetch_profit_loss_by_order_bloc.dart';
import '../../blocs/fetchBlocs/fetch_user_activity_logs_bloc.dart';
import '../../blocs/miscBlocs/remove_fav_events_bloc.dart';
import '../../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../blocs/demo_auth_order_blocs.dart';
import '../data/demo_hive_store.dart';
import '../data/demo_order_engine.dart';
import '../repositories/demo_auth_api_repository.dart';
import '../repositories/demo_cg_api_repository.dart';
import '../repositories/demo_favourite_api_repository.dart';
import '../repositories/demo_orders_api_repository.dart';
import '../services/demo_session.dart';

class DemoBlocScope extends StatefulWidget {
  const DemoBlocScope({super.key, required this.child});

  final Widget child;

  @override
  State<DemoBlocScope> createState() => _DemoBlocScopeState();
}

class _DemoBlocScopeState extends State<DemoBlocScope> {
  final DemoHiveStore store = DemoHiveStore.instance;
  late final DemoOrderEngine orderEngine = DemoOrderEngine(store);
  late final DemoOrdersApiRepository ordersRepository = DemoOrdersApiRepository(store, orderEngine);
  late final DemoAuthApiRepository authRepository = DemoAuthApiRepository(store);
  late final DemoCGApiRepository cgRepository = DemoCGApiRepository(store);
  late final DemoFavouriteApiRepository favouriteRepository = DemoFavouriteApiRepository(store);
  late final Future<void> readyFuture = _prepareDemoScope();

  Future<void> _prepareDemoScope() async {
    // Always reset to seed on scope init — enforces per-session isolation
    // so no stale orders, balance, or bets carry over between demo sessions.
    await store.resetToSeed();
    DemoSession.activate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: readyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<CGApiRepository>.value(value: cgRepository),
            RepositoryProvider<AuthApiRepository>.value(value: authRepository),
            RepositoryProvider<OrdersApiRepository>.value(value: ordersRepository),
            RepositoryProvider<FavouriteApiRepository>.value(value: favouriteRepository),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<UserAuthChangesBloc>(create: (_) => DemoUserAuthChangesBloc(store)),
              BlocProvider<UserLogoutBloc>(create: (_) => DemoUserLogoutBloc()),
              BlocProvider<SignalRHubListenerBloc>(create: (_) => DemoSignalRHubListenerBloc(store)),
              BlocProvider<ChangePasswordBloc>(create: (_) => DemoChangePasswordBloc(authRepository)),
              BlocProvider<SendOrderBloc>(create: (_) => DemoSendOrderBloc(ordersRepository)),
              BlocProvider<FetchOpenOrdersBloc>(create: (_) => DemoFetchOpenOrdersBloc(ordersRepository)),
              BlocProvider<FetchCurrentBetsBloc>(create: (_) => DemoFetchCurrentBetsBloc(ordersRepository)),
              BlocProvider<FetchOrdersBloc>(create: (_) => DemoFetchOrdersBloc(ordersRepository)),
              BlocProvider<FetchPlByOrdersBloc>(create: (_) => DemoFetchPlByOrdersBloc(ordersRepository)),
              BlocProvider<FetchPlayerBetHistoryBloc>(create: (_) => DemoFetchPlayerBetHistoryBloc(ordersRepository)),
              BlocProvider<FetchPlayerProfitAndLossBloc>(create: (_) => DemoFetchPlayerProfitAndLossBloc(ordersRepository)),
              BlocProvider<FetchOddsRunnerPLBloc>(create: (_) => DemoFetchOddsRunnerPLBloc(ordersRepository)),
              BlocProvider<FetchBMRunnerPLBloc>(create: (_) => DemoFetchBMRunnerPLBloc(ordersRepository)),
              BlocProvider<FetchFancyRunnerPLBloc>(create: (_) => DemoFetchFancyRunnerPLBloc(ordersRepository)),
              BlocProvider<FetchFancyBookBloc>(create: (_) => DemoFetchFancyBookBloc(ordersRepository)),
              BlocProvider<FetchUserActivityLogsBloc>(create: (_) => DemoFetchUserActivityLogsBloc(authRepository)),
              BlocProvider<FetchUserAccountDetailsBloc>(create: (_) => FetchUserAccountDetailsBloc(authRepository)),
              BlocProvider<FetchCGBalanceBloc>(create: (_) => FetchCGBalanceBloc(cgRepository)),
              BlocProvider<FetchCGHistoryBloc>(create: (_) => FetchCGHistoryBloc(cgRepository)),
              BlocProvider<AddCGMoneyBloc>(create: (_) => DemoAddCGMoneyBloc(cgRepository)),
              BlocProvider<RecallCGBalanceBloc>(create: (_) => DemoRecallCGBalanceBloc(cgRepository)),
              BlocProvider<FetchFavouriteBloc>(create: (_) => DemoFetchFavouriteBloc(favouriteRepository)),
              BlocProvider<FetchFavStakeBloc>(create: (_) => DemoFetchFavStakeBloc(favouriteRepository)),
              BlocProvider<AddFavStakeBloc>(create: (_) => DemoAddFavStakeBloc(favouriteRepository)),
              BlocProvider<AddFavouriteEventsBloc>(create: (_) => DemoAddFavouriteEventsBloc(favouriteRepository)),
              BlocProvider<RemoveFavouriteEventsBloc>(create: (_) => DemoRemoveFavouriteEventsBloc(favouriteRepository)),
            ],
            // Wrap in a local Overlay so that Overlay.of(context) from within the
            // demo widget tree finds this overlay (which inherits demo BLoC providers)
            // instead of the shell navigator's overlay (which is above DemoBlocScope).
            child: Overlay(initialEntries: [OverlayEntry(opaque: true, maintainState: true, builder: (ctx) => widget.child)]),
          ),
        );
      },
    );
  }
}
