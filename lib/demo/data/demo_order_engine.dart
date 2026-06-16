import 'demo_hive_store.dart';
import 'demo_seed_data.dart';

class DemoOrderEngine {
  DemoOrderEngine(this.store);

  final DemoHiveStore store;

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body) async {
    await store.ensureReady();

    final eventId = '${body['eventId'] ?? ''}';
    final marketId = '${body['marketId'] ?? ''}';
    final runnerId = '${body['runnerID'] ?? body['runnerId'] ?? ''}';
    final side = '${body['side'] ?? 'back'}'.toLowerCase();
    final bettingType = int.tryParse('${body['bettingType'] ?? 0}') ?? 0;
    final stake = _toDouble(body['stake']);
    final price = _toDouble(body['price'] ?? body['odds']);
    final line = '${body['line'] ?? ''}';

    if (eventId.isEmpty || marketId.isEmpty || runnerId.isEmpty || stake <= 0 || price <= 0) {
      return {'status': 400, 'message': 'Invalid demo order'};
    }

    // Cache runner IDs supplied by the UI so cross-runner P&L can be computed later.
    if (body['allRunnerIds'] is List) {
      final ids = (body['allRunnerIds'] as List).map((e) => '$e').where((id) => id.isNotEmpty).toList();
      if (ids.isNotEmpty) await _cacheRunnerIds(marketId, bettingType, ids);
    }

    // Liability / profit depend on market type.
    //   bettingType 0 – Match Odds (decimal odds, e.g. 2.34)
    //   bettingType 1 – Fancy     (percentage-style, e.g. 37; liability = stake for both sides)
    //   bettingType 2 – Bookmaker (percentage odds, e.g. 72 → win = 72% of stake)
    final double liability;
    final double profit;
    final isLay = side.contains('lay');
    if (bettingType == 2) {
      liability = isLay ? (price / 100) * stake : stake;
      profit = isLay ? stake : (price / 100) * stake;
    } else if (bettingType == 1) {
      liability = stake;
      profit = (price / 100) * stake;
    } else {
      liability = isLay ? stake * (price - 1) : stake;
      profit = isLay ? stake : stake * (price - 1);
    }

    final account = await store.map('account');
    final market = await store.marketForEvent(eventId, bettingType);
    final runner = _runnerFor(market, runnerId);
    final orderId = await store.takeNextOrderId();
    final openBalance = _toDouble(account['balancePoint']);
    final closeBalance = openBalance - liability;
    final now = DateTime.now().toIso8601String();

    final sidString = '${market['sid'] ?? body['sid'] ?? 4}';
    final order = <String, dynamic>{
      'orderId': orderId,
      'bettingType': bettingType,
      'marketId': marketId,
      'marketName': market['marketName'] ?? _marketName(bettingType),
      'userId': DemoSeedData.userId,
      'userName': DemoSeedData.userName,
      'competitionId': '${market['competitionId'] ?? body['competitionId'] ?? ''}',
      'eventId': eventId,
      'runnerID': runnerId,
      'stake': stake,
      'price': price,
      'side': side,
      'timeStamp': now,
      'status': 'Matched',
      'sid': sidString,
      'filledPrice': price,
      'rejectReason': '',
      'ip': '127.0.0.1',
      'eventName': '${market['eventName'] ?? body['eventName'] ?? ''}',
      'competitionName': '${market['competitionName'] ?? body['competitionName'] ?? ''}',
      'runnerName': '${runner['name'] ?? body['runnerName'] ?? runnerId}',
      'buildNumber': 13,
      'version': '0.0.1',
      'mode': 'demo',
      'platform': 'web',
      'exposure': liability,
      'mtm': 0.0,
      'liability': liability,
      'profit': profit,
      'loss': liability,
      'openBalance': openBalance,
      'closeBalance': closeBalance,
      'isDone': false,
      'result': '',
      'line': line,
    };

    final orders = await store.list('orders');
    orders.insert(0, order);
    await store.putList('orders', orders);

    account['balancePoint'] = closeBalance;
    account['netPoint'] = closeBalance;
    account['exposure'] = _toDouble(account['exposure']) + liability;
    final history = (account['history'] as List<dynamic>? ?? <dynamic>[]).map((item) => Map<String, dynamic>.from(item as Map)).toList();
    history.insert(0, {'id': orderId, 'transType': 'Withdraw', 'amount': liability, 'date': now, 'comment': 'Demo order exposure reserved', 'UserId': DemoSeedData.userId});
    account['history'] = history;
    await store.putMap('account', account);

    final activityLogs = await store.list('activityLogs');
    activityLogs.insert(0, {
      'id': orderId,
      'loginTime': now,
      'loginStatus': 'Success',
      'ip': '127.0.0.1',
      'isp': 'Local Demo',
      'address': 'Placed ${_marketName(bettingType)} order',
      'agent': 'Try Demo',
      'UserId': DemoSeedData.userId,
    });
    await store.putList('activityLogs', activityLogs);

    return {'status': 200, 'message': 'Demo order matched', 'data': order};
  }

  Future<Map<String, dynamic>> openOrdersResponse() async {
    final orders = (await store.list('orders')).map(_normalizeOrder).where((order) => order['isDone'] != true).toList();
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final order in orders) {
      final eventName = '${order['eventName'] ?? ''}';
      final marketName = '${order['marketName'] ?? ''}';
      final name = marketName.isNotEmpty ? '$eventName $marketName' : eventName;
      grouped.putIfAbsent(name, () => <Map<String, dynamic>>[]).add(order);
    }
    return {
      'status': 200,
      'data': grouped.entries.map((entry) => {'name': entry.key, 'orders': entry.value}).toList(),
    };
  }

  Future<Map<String, dynamic>> currentBetsResponse() async {
    return {'status': 200, 'data': (await store.list('orders')).map(_normalizeOrder).toList()};
  }

  Future<Map<String, dynamic>> allOrdersResponse() async {
    return {'status': 200, 'message': 'success', 'data': await store.allOrders()};
  }

  Future<Map<String, dynamic>> playerBetHistoryResponse() async => allOrdersResponse();

  Future<Map<String, dynamic>> profitLossResponse() async {
    return {'status': 200, 'message': 'success', 'data': await store.list('profitLossRows')};
  }

  Future<Map<String, dynamic>> playerProfitLossResponse() async {
    return {'status': 200, 'message': 'success', 'data': await store.list('playerProfitLoss')};
  }

  Future<Map<String, dynamic>> runnerPlResponse({required String marketId, required int bettingType}) async {
    final orders = await store.list('orders');
    final relevantOrders = orders.where((o) => '${o['marketId']}' == marketId && (int.tryParse('${o['bettingType']}') ?? 0) == bettingType).toList();

    if (relevantOrders.isEmpty) {
      return {'status': 200, 'message': 'success', 'data': <dynamic>[]};
    }

    final totals = <String, double>{};

    // Resolve the full runner list for cross-runner P&L (Match Odds and Bookmaker).
    // Fancy markets are independent per-runner; no cross-runner logic needed.
    List<String> allRunnerIds = [];
    if (bettingType != 1) {
      allRunnerIds = await _getCachedRunnerIds(marketId, bettingType);
      if (allRunnerIds.isEmpty) {
        // Fallback: derive from placed orders if cache is missing.
        allRunnerIds = relevantOrders.map((o) => '${o['runnerID'] ?? ''}').where((id) => id.isNotEmpty).toSet().toList();
      }
    }

    for (final order in relevantOrders) {
      final runnerId = '${order['runnerID'] ?? ''}';
      final side = '${order['side'] ?? ''}'.toLowerCase();
      final stake = _toDouble(order['stake']);
      final price = _toDouble(order['price']);
      final isLay = side.contains('lay');

      if (bettingType == 2) {
        // Bookmaker: percentage odds (e.g. 72 → 72% of stake).
        final pct = price / 100;
        if (isLay) {
          totals[runnerId] = (totals[runnerId] ?? 0) - pct * stake;
          for (final id in allRunnerIds) {
            if (id != runnerId) totals[id] = (totals[id] ?? 0) + stake;
          }
        } else {
          totals[runnerId] = (totals[runnerId] ?? 0) + pct * stake;
          for (final id in allRunnerIds) {
            if (id != runnerId) totals[id] = (totals[id] ?? 0) - stake;
          }
        }
      } else if (bettingType == 1) {
        // Fancy: percentage-style odds, per-runner only.
        if (isLay) {
          totals[runnerId] = (totals[runnerId] ?? 0) - stake;
        } else {
          totals[runnerId] = (totals[runnerId] ?? 0) + (price / 100) * stake;
        }
      } else {
        // Match Odds: decimal odds (e.g. 2.34).
        if (isLay) {
          totals[runnerId] = (totals[runnerId] ?? 0) - (price - 1) * stake;
          for (final id in allRunnerIds) {
            if (id != runnerId) totals[id] = (totals[id] ?? 0) + stake;
          }
        } else {
          totals[runnerId] = (totals[runnerId] ?? 0) + (price - 1) * stake;
          for (final id in allRunnerIds) {
            if (id != runnerId) totals[id] = (totals[id] ?? 0) - stake;
          }
        }
      }
    }

    return {
      'status': 200,
      'message': 'success',
      'data': totals.entries.map((entry) => {'runnerId': entry.key, 'net': entry.value}).toList(),
    };
  }

  Future<void> _cacheRunnerIds(String marketId, int bettingType, List<String> ids) async {
    final key = 'marketRunners_${marketId}_$bettingType';
    await store.putList(key, ids.map((id) => <String, dynamic>{'id': id}).toList());
  }

  Future<List<String>> _getCachedRunnerIds(String marketId, int bettingType) async {
    final key = 'marketRunners_${marketId}_$bettingType';
    final cached = await store.list(key);
    return cached.map((e) => '${e['id'] ?? ''}').where((id) => id.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> fancyBookResponse(String marketId) async {
    final books = await store.map('fancyBook');
    return {'status': 200, 'message': 'success', 'data': books[marketId] ?? <Map<String, dynamic>>[]};
  }

  static Map<String, dynamic> _runnerFor(Map<String, dynamic> market, String runnerId) {
    final runners = market['runners'];
    if (runners is List) {
      for (final runner in runners) {
        if (runner is Map && '${runner['id'] ?? runner['runnerId']}' == runnerId) return Map<String, dynamic>.from(runner);
      }
    }
    return {'id': runnerId, 'name': runnerId};
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static Map<String, dynamic> _normalizeOrder(Map<String, dynamic> order) {
    return {
      ...order,
      'orderId': int.tryParse('${order['orderId'] ?? 0}') ?? 0,
      'bettingType': int.tryParse('${order['bettingType'] ?? 0}') ?? 0,
      'betType': int.tryParse('${order['betType'] ?? order['bettingType'] ?? 0}') ?? 0,
      'marketId': '${order['marketId'] ?? ''}',
      'marketName': '${order['marketName'] ?? ''}',
      'userId': '${order['userId'] ?? ''}',
      'competitionId': '${order['competitionId'] ?? ''}',
      'eventId': '${order['eventId'] ?? ''}',
      'runnerID': '${order['runnerID'] ?? ''}',
      'side': '${order['side'] ?? ''}',
      'status': '${order['status'] ?? ''}',
      'sid': '${order['sid'] ?? ''}',
      'ip': '${order['ip'] ?? ''}',
      'eventName': '${order['eventName'] ?? ''}',
      'competitionName': '${order['competitionName'] ?? ''}',
      'runnerName': '${order['runnerName'] ?? ''}',
      'version': '${order['version'] ?? ''}',
      'mode': '${order['mode'] ?? ''}',
      'platform': '${order['platform'] ?? ''}',
      'line': '${order['line'] ?? ''}',
      'buildNumber': int.tryParse('${order['buildNumber'] ?? 0}') ?? 0,
      'stake': _toDouble(order['stake']),
      'price': _toDouble(order['price']),
      'filledPrice': _toDouble(order['filledPrice']),
      'exposure': _toDouble(order['exposure']),
      'mtm': _toDouble(order['mtm']),
      'profit': _toDouble(order['profit']),
    };
  }

  static String _marketName(int bettingType) {
    if (bettingType == 2) return 'Bookmaker';
    if (bettingType == 1) return 'Fancy';
    return 'Match Odds';
  }
}
