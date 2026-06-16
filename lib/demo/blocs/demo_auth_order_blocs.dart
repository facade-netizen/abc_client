import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../blocs/addBloc/add_cg_money_bloc.dart';
import '../../blocs/addBloc/add_fav_stake_bloc.dart';
import '../../blocs/addBloc/add_favourite_event_bloc.dart';
import '../../blocs/addBloc/recall_cg_balance_bloc.dart';
import '../../blocs/addBloc/send_order_bloc.dart';
import '../../blocs/authBlocs/change_password_bloc.dart';
import '../../blocs/authBlocs/user_auth_change_bloc.dart';
import '../../blocs/authBlocs/user_logout_bloc.dart';
import '../../services/app_config.dart';
import '../../blocs/fetchBlocs/fetch_bm_runners_pl_bloc.dart';
import '../../blocs/fetchBlocs/fetch_current_bets_bloc.dart';
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
import '../../localDb/token/login_token_model.dart';
import '../../models/runners_pl_model.dart';
import '../../models/user_details_model.dart';
import '../data/demo_hive_store.dart';
import '../data/demo_seed_data.dart';
import '../repositories/demo_auth_api_repository.dart';
import '../repositories/demo_cg_api_repository.dart';
import '../repositories/demo_favourite_api_repository.dart';
import '../repositories/demo_orders_api_repository.dart';
import '../services/demo_session.dart';

class DemoUserAuthChangesBloc extends Bloc<UserAuthChangesEvent, UserAuthChangesState> implements UserAuthChangesBloc {
  DemoUserAuthChangesBloc(this.store) : super(UserAuthChangesInitial()) {
    on<StartUserChangeListener>((event, emit) async {
      emit(UserAuthChangesProgress());
      await store.ensureReady();
      final session = await store.map('session');
      if (session['active'] == false) {
        emit(UserAuthChangesFailure());
        return;
      }
      emit(
        UserAuthChangesSuccess(
          savedUserAuth: SaveLoginTokenModel(
            token: 'local-demo-token',
            refreshToken: 'local-demo-refresh',
            validTill: '31:12:2099 23:59:59',
            savedAt: DateTime.now(),
            userId: DemoSeedData.userId,
            role: 'client',
            userName: DemoSeedData.userName,
          ),
        ),
      );
    });
  }

  final DemoHiveStore store;
}

class DemoUserLogoutBloc extends Bloc<UserLogoutEvent, UserLogoutState> implements UserLogoutBloc {
  DemoUserLogoutBloc() : super(UserLogoutInitial()) {
    on<UserLogoutListener>((event, emit) async {
      emit(UserLogoutProgress());
      await DemoHiveStore.instance.endSession();
      DemoSession.deactivate();
      emit(UserLogoutSuccess());
    });
  }
}

class DemoSignalRHubListenerBloc extends Bloc<SignalRHubListenerEvent, SignalRHubListenerState> implements SignalRHubListenerBloc {
  DemoSignalRHubListenerBloc(this.store) : super(SignalRHubListenerInitial()) {
    on<SignalRHubListener>((event, emit) async {
      emit(SignalRHubListenerProgress());
      await _publishAccount();
      emit(SignalRHubListenerSuccess());
    });
    on<SignalRHubDisconnect>((event, emit) => emit(SignalRHubListenerSuccess()));
  }

  final DemoHiveStore store;
  @override
  late HubConnection hubConnection;

  Future<void> _publishAccount() async {
    connectionHubStateController.add('connected');
    final accountJson = await store.map('account');
    accountStreamController.add(UserAccountDetails.fromJson(accountJson));
  }

  @override
  Future<void> connect(String token) async {}

  @override
  Future<void> disconnect() async {}

  @override
  void parseProtoOrderToMessageModel(List<Object?>? message, String type) {}

  @override
  void parseProtoProfitLossToMessageModel(List<Object?>? message, String type) {}

  @override
  void parseProtoToAccountModel(List<Object?>? message, String type) {}

  @override
  void parseProtoToMessageModel(List<Object?>? message, String type) {}

  @override
  Future<void> send(String token) async {}
}

class DemoChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> implements ChangePasswordBloc {
  DemoChangePasswordBloc(this.repository) : super(ChangePasswordInitial()) {
    on<ChangePassword>((event, emit) async {
      emit(ChangePasswordProgress());
      await repository.changeNewPassword(body: event.changePassword);
      emit(ChangePasswordSuccess());
    });
  }

  final DemoAuthApiRepository repository;
}

class DemoSendOrderBloc extends Bloc<SendOrderEvent, SendOrderState> implements SendOrderBloc {
  DemoSendOrderBloc(this.repository) : super(SendOrderInitial()) {
    on<SendOrder>((event, emit) async {
      emit(SendOrderProgress(type: event.type));
      event.orderMap.addAll({
        'ip': '127.0.0.1',
        'isp': 'Local Demo',
        'userId': DemoSeedData.userId,
        'userName': DemoSeedData.userName,
        'buildNumber': appConfig.buildNumber,
        'version': appConfig.version,
        'mode': appConfig.debugMode,
        'platform': appConfig.operatingSystem,
      });

      final response = await repository.postOrder(body: event.orderMap);
      final decoded = jsonDecode(response.bodyString) as Map<String, dynamic>;
      if (response.statusCode == 200 && decoded['status'] == 200) {
        final accountJson = await repository.store.map('account');
        accountStreamController.add(UserAccountDetails.fromJson(accountJson));
        msgStreamController.add(jsonEncode({'status': 200, 'message': decoded['message'] ?? 'Demo order matched'}));
        // Push updated P&L data to the global stream controllers so runner tiles
        // refresh immediately — mirroring how live SignalR P&L updates work.
        await _pushUpdatedPL(event.orderMap);
        emit(SendOrderSuccess(message: decoded['message'] ?? 'Demo order matched'));
      } else {
        emit(SendOrderFailure(error: decoded['message'] ?? 'Demo order failed'));
      }
    });
  }

  final DemoOrdersApiRepository repository;

  Future<void> _pushUpdatedPL(Map<String, dynamic> orderMap) async {
    try {
      final marketId = '${orderMap['marketId'] ?? ''}';
      final bettingType = int.tryParse('${orderMap['bettingType'] ?? 0}') ?? 0;
      final plJson = await repository.engine.runnerPlResponse(marketId: marketId, bettingType: bettingType);
      final data = (plJson['data'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (bettingType == 1) {
        fancyPLController.add(data.map((e) => FancyRunnerPLData.fromJson(e)).toList());
      } else if (bettingType == 2) {
        bmPLController.add(data.map((e) => BMRunnerPLData.fromJson(e)).toList());
      } else {
        oddsPLController.add(data.map((e) => OddsRunnerPLData.fromJson(e)).toList());
      }
    } catch (_) {
      // Ignore — tiles fall back to cached P&L from the last HTTP fetch.
    }
  }
}

class DemoFetchOpenOrdersBloc extends Bloc<FetchOpenOrdersEvent, FetchOpenOrdersState> implements FetchOpenOrdersBloc {
  DemoFetchOpenOrdersBloc(this.repository) : super(FetchOpenOrdersInitial()) {
    on<FetchOpenOrders>((event, emit) async {
      emit(FetchOpenOrdersProgress());
      final response = await repository.getOpenOrders();
      emit(FetchOpenOrdersSuccess(openOrderData: response.body!.data));
    });
    on<FetchOpenOrdersInt>((event, emit) => emit(FetchOpenOrdersInitial()));
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchCurrentBetsBloc extends Bloc<FetchCurrentBetsEvent, FetchCurrentBetsState> implements FetchCurrentBetsBloc {
  DemoFetchCurrentBetsBloc(this.repository) : super(FetchCurrentBetsInitial()) {
    on<FetchCurrentBets>((event, emit) async {
      emit(FetchCurrentBetsProgress());
      if (event.betType == null) {
        emit(FetchCurrentBetsSuccess(openOrder: []));
        return;
      }
      final response = await repository.getOpenOrders();
      final orders = response.body!.data.expand((group) => group.openOrders).where((order) => order.betType == event.betType).toList();
      emit(FetchCurrentBetsSuccess(openOrder: orders));
    });
    on<FetchCurrentBetsInt>((event, emit) => emit(FetchCurrentBetsInitial()));
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchOrdersBloc extends Bloc<FetchOrdersEvent, FetchOrdersState> implements FetchOrdersBloc {
  DemoFetchOrdersBloc(this.repository) : super(FetchOrdersInitial()) {
    on<FetchOrders>((event, emit) async {
      emit(FetchOrdersProgress());
      final response = await repository.getOrders();
      emit(FetchOrdersSuccess(orderData: response.body!.data));
    });
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchPlByOrdersBloc extends Bloc<FetchPlByOrdersEvent, FetchPlByOrdersState> implements FetchPlByOrdersBloc {
  DemoFetchPlByOrdersBloc(this.repository) : super(FetchPlByOrdersInitial()) {
    on<FetchPlByOrders>((event, emit) async {
      emit(FetchPlByOrdersProgress());
      final response = await repository.getPlByOrders(page: event.page, limit: event.pagelimit);
      emit(FetchPlByOrdersSuccess(plByorders: response.body!.data));
    });
  }

  final DemoOrdersApiRepository repository;
}


class DemoFetchPlayerBetHistoryBloc extends Bloc<FetchPlayerBetHistoryEvent, FetchPlayerBetHistoryState> implements FetchPlayerBetHistoryBloc {
  DemoFetchPlayerBetHistoryBloc(this.repository) : super(FetchPlayerBetHistoryInitial()) {
    on<FetchPlayerBetHistory>((event, emit) async {
      emit(FetchPlayerBetHistoryProgress());
      final response = await repository.getPlayerBetHistory(body: event.getPlayerData);
      emit(
        FetchPlayerBetHistorySuccess(
          playerBets: response.data,
          page: response.page,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
          totalRecords: response.totalRecords,
        ),
      );
    });
    on<FetchPlayerBetInt>((event, emit) => emit(FetchPlayerBetHistoryInitial()));
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchPlayerProfitAndLossBloc extends Bloc<FetchPlayerProfitAndLossEvent, FetchPlayerProfitAndLossState> implements FetchPlayerProfitAndLossBloc {
  DemoFetchPlayerProfitAndLossBloc(this.repository) : super(FetchPlayerProfitAndLossInitial()) {
    on<FetchPlayerProfitAndLoss>((event, emit) async {
      emit(FetchPlayerProfitAndLossProgress());
      final response = await repository.getPlayerProfitAndLoss(body: event.getPlayerPl);
      if (response.data.isEmpty) {
        emit(FetchPlayerProfitAndLossFailure('You have no bets in this time period.'));
        return;
      }
      emit(FetchPlayerProfitAndLossSuccess(resultList: response.data, response: response));
    });
    on<FetchPlayerProfitAndLossInt>((event, emit) => emit(FetchPlayerProfitAndLossInitial()));
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchOddsRunnerPLBloc extends Bloc<FetchOddsRunnerPLEvent, FetchOddsRunnerPLState> implements FetchOddsRunnerPLBloc {
  DemoFetchOddsRunnerPLBloc(this.repository) : super(FetchOddsRunnerPLInitial()) {
    on<FetchOddsRunnerPL>((event, emit) async {
      emit(FetchOddsRunnerPLProgress());
      final response = await repository.getOddsRunnerPl(body: {'marketId': event.marketId, 'eventId': event.eventId});
      emit(FetchOddsRunnerPLSuccess(runnerPl: response.data, eventId: event.eventId, marketId: event.marketId));
    });
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchBMRunnerPLBloc extends Bloc<FetchBMRunnerPLEvent, FetchBMRunnerPLState> implements FetchBMRunnerPLBloc {
  DemoFetchBMRunnerPLBloc(this.repository) : super(FetchBMRunnerPLInitial()) {
    on<FetchBMRunnerPL>((event, emit) async {
      emit(FetchBMRunnerPLProgress());
      final response = await repository.getBMRunnerPl(body: {'marketId': event.marketId, 'eventId': event.eventId});
      emit(FetchBMRunnerPLSuccess(runnerPl: response.data));
    });
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchFancyRunnerPLBloc extends Bloc<FetchFancyRunnerPLEvent, FetchFancyRunnerPLState> implements FetchFancyRunnerPLBloc {
  DemoFetchFancyRunnerPLBloc(this.repository) : super(FetchFancyRunnerPLInitial()) {
    on<FetchFancyRunnerPL>((event, emit) async {
      emit(FetchFancyRunnerPLProgress());
      final response = await repository.getFancyRunnerPl(body: {'marketId': event.marketId, 'eventId': event.eventId});
      emit(FetchFancyRunnerPLSuccess(runnerPl: response.data));
    });
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchFancyBookBloc extends Bloc<FetchFancyBookEvent, FetchFancyBookState> implements FetchFancyBookBloc {
  DemoFetchFancyBookBloc(this.repository) : super(FetchFancyBookInitial()) {
    on<FetchFancyBook>((event, emit) async {
      emit(FetchFancyBookProgress());
      final response = await repository.getFancyBook(body: {'marketId': event.marketId});
      emit(FetchFancyBookSuccess(fancyBook: response.data));
    });
  }

  final DemoOrdersApiRepository repository;
}

class DemoFetchUserActivityLogsBloc extends Bloc<FetchUserActivityLogsEvent, FetchUserActivityLogsState> implements FetchUserActivityLogsBloc {
  DemoFetchUserActivityLogsBloc(this.repository) : super(FetchUserActivityLogsInitial()) {
    on<FetchUserActivityLogs>((event, emit) async {
      emit(FetchUserActivityLogsProgress());
      final response = await repository.getUserActivityLogs(body: {'userId': event.userId ?? DemoSeedData.userId, 'page': event.page ?? 1, 'limit': event.limit ?? 25});
      emit(FetchUserActivityLogsSuccess(activityLogsResponse: response));
    });
  }

  final DemoAuthApiRepository repository;
}

class DemoFetchFavouriteBloc extends Bloc<FetchFavouriteEvent, FetchFavouriteState> implements FetchFavouriteBloc {
  DemoFetchFavouriteBloc(this.repository) : super(FetchFavouriteInitial()) {
    on<FetchFavourite>((event, emit) async {
      emit(FetchFavouriteProgress());
      final response = await repository.fetchFavEvent();
      emit(FetchFavouriteSuccess(favEvents: response.body!.data));
    });
  }

  final DemoFavouriteApiRepository repository;
}

class DemoFetchFavStakeBloc extends Bloc<FetchFavStakeEvent, FetchFavStakeState> implements FetchFavStakeBloc {
  DemoFetchFavStakeBloc(this.repository) : super(FetchFavStakeInitial()) {
    on<FetchFavStake>((event, emit) async {
      emit(FetchFavStakeProgress());
      final response = await repository.getFavStake();
      emit(FetchFavStakeSuccess(favStakeData: response.body!.data));
    });
    on<SetToInitialFetchFavStake>((event, emit) => emit(FetchFavStakeInitial()));
  }

  final DemoFavouriteApiRepository repository;
}

class DemoAddFavStakeBloc extends Bloc<AddFavStakeEvent, AddFavStakeState> implements AddFavStakeBloc {
  DemoAddFavStakeBloc(this.repository) : super(AddFavStakeInitial()) {
    on<AddFavStake>((event, emit) async {
      emit(AddFavStakeProgress());
      await repository.addFavStake(body: event.body);
      emit(AddFavStakeSuccess());
    });
  }

  final DemoFavouriteApiRepository repository;
}

class DemoAddFavouriteEventsBloc extends Bloc<AddFavouriteEventsEvent, AddFavouriteEventsState> implements AddFavouriteEventsBloc {
  DemoAddFavouriteEventsBloc(this.repository) : super(AddFavouriteEventsInitial()) {
    on<AddFavouriteEvents>((event, emit) async {
      emit(AddFavouriteEventsProgress());
      final body = <String, dynamic>{'eventId': event.eventId};
      if (event.marketId != null) body['marketId'] = event.marketId;
      final response = await repository.addFavouriteEvents(body: body);
      final decoded = jsonDecode(response.bodyString) as Map<String, dynamic>;
      emit(AddFavouriteEventsSuccess(message: decoded['message'] ?? 'Added to demo favourites'));
    });
  }

  final DemoFavouriteApiRepository repository;
}

class DemoRemoveFavouriteEventsBloc extends Bloc<RemoveFavouriteEventsEvent, RemoveFavouriteEventsState> implements RemoveFavouriteEventsBloc {
  DemoRemoveFavouriteEventsBloc(this.repository) : super(RemoveFavouriteEventsInitial()) {
    on<RemoveFavouriteEvents>((event, emit) async {
      emit(RemoveFavouriteEventsProgress());
      final response = await repository.removeFavouriteEvents(body: {'matchId': event.eventId});
      final decoded = jsonDecode(response.bodyString) as Map<String, dynamic>;
      emit(RemoveFavouriteEventsSuccess(message: decoded['message'] ?? 'Removed from demo favourites'));
    });
  }

  final DemoFavouriteApiRepository repository;
}

class DemoAddCGMoneyBloc extends Bloc<AddCGMoneyEvent, AddCGMoneyState> implements AddCGMoneyBloc {
  DemoAddCGMoneyBloc(this.repository) : super(AddCGMoneyInitial()) {
    on<AddCGMoney>((event, emit) async {
      emit(AddCGMoneyProgress());
      final response = await repository.addCGMoney(body: event.addCGMoneyMap);
      final decoded = jsonDecode(response.bodyString) as Map<String, dynamic>;
      emit(AddCGMoneySuccess(message: decoded['message'] ?? 'Demo deposit completed', url: ''));
    });
  }

  final DemoCGApiRepository repository;
}

class DemoRecallCGBalanceBloc extends Bloc<RecallCGBalanceEvent, RecallCGBalanceState> implements RecallCGBalanceBloc {
  DemoRecallCGBalanceBloc(this.repository) : super(RecallCGBalanceInitial()) {
    on<RecallCGBalance>((event, emit) async {
      emit(RecallCGBalanceProgress());
      await repository.withCGDrawMoney(body: event.recallCGBalanceMap);
      emit(RecallCGBalanceSuccess());
    });
  }

  final DemoCGApiRepository repository;
}
