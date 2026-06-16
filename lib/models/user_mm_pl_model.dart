class UserMMFancyPlResponse {
  final int status;
  final List<UserMMPLFancyRunner> data;
  final String message;

  UserMMFancyPlResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory UserMMFancyPlResponse.fromJson(Map<dynamic, dynamic> json) {
    return UserMMFancyPlResponse(
      status: json['status'],
      data: (json['data'] as List).map((item) => UserMMPLFancyRunner.fromJson(item)).toList(),
      message: json['message'],
    );
  }
}

class UserMMPLFancyRunner {
  final String runnerId;
  final double net;

  UserMMPLFancyRunner({
    required this.runnerId,
    required this.net,
  });

  factory UserMMPLFancyRunner.fromJson(Map<String, dynamic> json) {
    return UserMMPLFancyRunner(
      runnerId: json['runnerId'],
      net: (json['net'] as num).toDouble(),
    );
  }
}

class UserMMOddBmPlResponse {
  final int status;
  final List<UserMMOddBMPlMarket> data;
  final String message;

  UserMMOddBmPlResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory UserMMOddBmPlResponse.fromJson(Map<dynamic, dynamic> json) {
    return UserMMOddBmPlResponse(
      status: json['status'],
      data: (json['data'] as List).map((e) => UserMMOddBMPlMarket.fromJson(e)).toList(),
      message: json['message'],
    );
  }
}

class UserMMOddBMPlMarket {
  final String marketId;
  final List<UserMMOddBMPlRunner> runners;

  UserMMOddBMPlMarket({
    required this.marketId,
    required this.runners,
  });

  factory UserMMOddBMPlMarket.fromJson(Map<String, dynamic> json) {
    return UserMMOddBMPlMarket(
      marketId: json['marketId'],
      runners: (json['runners'] as List).map((e) => UserMMOddBMPlRunner.fromJson(e)).toList(),
    );
  }
}

class UserMMOddBMPlRunner {
  final String runnerId;
  final double net;

  UserMMOddBMPlRunner({
    required this.runnerId,
    required this.net,
  });

  factory UserMMOddBMPlRunner.fromJson(Map<String, dynamic> json) {
    return UserMMOddBMPlRunner(
      runnerId: json['runnerId'],
      net: (json['net'] as num).toDouble(),
    );
  }
}
