import '../../apis/apiRepositories/cgRepo/cg_api_repository.dart';
import 'package:chopper/chopper.dart';
import '../../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../../models/casion_history_model.dart';
import '../../models/cg_balance_model.dart';
import '../../models/user_details_model.dart';
import '../data/demo_hive_store.dart';
import 'demo_response.dart';

class DemoCGApiRepository extends CGApiRepository {
  DemoCGApiRepository(this.store) : super();

  final DemoHiveStore store;

  @override
  Future<Response<CGBalanceResponse>> getCGBalance(String provider) async {
    final balances = await store.list('cgBalance');
    final json = {'status': 200, 'message': 'success', 'data': balances};
    return DemoResponse.typed(json, CGBalanceResponse.fromJson(json));
  }

  @override
  Future<Response> addCGMoney({required Map<String, dynamic> body}) async {
    return _transfer(body, true);
  }

  @override
  Future<Response> withCGDrawMoney({required Map<String, dynamic> body}) async {
    return _transfer(body, false);
  }

  @override
  Future<Response<CasinoHistoryResponse>> getCGHistory(String fromDate, String toDate, int limit, int page) async {
    final history = await store.list('cgHistory');
    final json = {'status': 200.0, 'message': 'success', 'data': history};
    return DemoResponse.typed(json, CasinoHistoryResponse.fromJson(json));
  }

  @override
  Future<Response> fetchPremium({required Map<String, dynamic> body}) async {
    final json = {
      'status': 200,
      'message': 'success',
      'data': {'url': 'about:blank'},
    };
    return DemoResponse.raw(json);
  }

  Future<Response> _transfer(Map<String, dynamic> body, bool intoCasino) async {
    final amount = body['amount'] is num ? (body['amount'] as num).toDouble() : double.tryParse('${body['amount']}') ?? 0;
    final balances = await store.list('cgBalance');
    final account = await store.map('account');
    if (balances.isNotEmpty && amount > 0) {
      final first = balances.first;
      first['currentBalance'] = (first['currentBalance'] as num? ?? 0).toDouble() + (intoCasino ? amount : -amount);
      account['balancePoint'] = (account['balancePoint'] as num? ?? 0).toDouble() + (intoCasino ? -amount : amount);
      account['netPoint'] = account['balancePoint'];
      account['casinoAccount'] = balances;
      await store.putList('cgBalance', balances);
      await store.putMap('account', account);
      accountStreamController.add(UserAccountDetails.fromJson(account));
    }
    return DemoResponse.raw({'status': 200, 'message': intoCasino ? 'Demo deposit completed' : 'Demo recall completed'});
  }
}
