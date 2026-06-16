class DemoSeedData {
  DemoSeedData._();

  static const String userId = 'demo-user-001';
  static const String accountId = 'demo-account-001';
  static const String userName = 'demo_client';
  static const String password = 'demo@1234';

  static Map<String, dynamic> initialState() {
    final now = DateTime.now();

    return {
      'session': {'active': true, 'userName': userName, 'password': password},
      'nextOrderId': 9000002,
      'account': _account(now),
      // All activity/history starts empty — per-session isolation
      'activityLogs': <Map<String, dynamic>>[],
      'favStake': _favStake(),
      'favourites': <Map<String, dynamic>>[],
      'cgBalance': _cgBalance(),
      'cgHistory': <Map<String, dynamic>>[],
      // Market lookup maps are empty — live events won't be found here;
      // DemoOrderEngine falls back to values passed in the order body.
      'oddsByEvent': <String, dynamic>{},
      'bookmakerByEvent': <String, dynamic>{},
      'fancyByEvent': <String, dynamic>{},
      // Orders start empty — only bets placed this session appear
      'orders': <Map<String, dynamic>>[],
      'settledOrders': <Map<String, dynamic>>[],
      'profitLossRows': <Map<String, dynamic>>[],
      'playerProfitLoss': <Map<String, dynamic>>[],
      'fancyBook': <String, dynamic>{},
    };
  }

  static Map<String, dynamic> _account(DateTime now) => {
    'accountId': accountId,
    'userId': userId,
    'wlId': 'demo-wl',
    'wlName': 'Demo White Label',
    'userName': userName,
    'firstName': 'Demo',
    'lastName': 'Client',
    'role': 'client',
    'distributedPoint': 0.0,
    'receivedPoint': 0.0,
    'depositPoint': 100000.0,
    'withdrawalPoint': 0.0,
    'exposure': 0.0,
    'creditRef': 100000.0,
    'pnl': 0.0,
    'commissionRate': 2.0,
    'childCount': 0.0,
    'commission': 0.0,
    'pointValue': 1.0,
    'soldPoint': 0.0,
    'netPoint': 100000.0,
    'balancePoint': 100000.0,
    'users': [
      {
        'firstName': 'Demo',
        'lastName': 'Client',
        'timezone': 'India Standard Time (GMT+05:30)',
        'enabled': true,
        'role': 'client',
        'childCount': 0,
        'accountId': accountId,
        'Id': userId,
        'UserName': userName,
        'NormalizedUserName': userName.toUpperCase(),
        'Email': null,
        'EmailConfirmed': false,
        'PasswordHash': 'local-demo-password',
        'SecurityStamp': 'demo-security-stamp',
        'ConcurrencyStamp': 'demo-concurrency-stamp',
        'PhoneNumber': null,
        'PhoneNumberConfirmed': false,
        'TwoFactorEnabled': false,
        'LockoutEnabled': false,
        'AccessFailedCount': 0,
      },
    ],
    'history': [
      {'id': 1, 'transType': 'Deposit', 'amount': 100000.0, 'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'comment': 'Demo opening balance', 'UserId': userId},
    ],
    'casinoAccount': _cgBalance(),
  };

  static Map<String, dynamic> _favStake() => {
    'FavStakes': '100,500,1000,5000,10000',
    'CommonStakes': '100,500,1000,5000,10000,25000',
    'SingleClick': false,
    'FancyBetAnyOdds': true,
    'SportsBookAnyOdds': true,
    'OddsAnyOdds': true,
    'EnableForecastWithCommission': false,
    'DefaultStake': 100.0,
  };

  static List<Map<String, dynamic>> _cgBalance() => [
    {'id': 1, 'name': 'RG', 'displayName': 'Royal Gaming', 'openBalance': 0.0, 'currentBalance': 0.0, 'accountId': accountId},
  ];
}
