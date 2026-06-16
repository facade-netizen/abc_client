class BMResponse {
  final int status;
  final BMData data;
  final String message;

  BMResponse({required this.status, required this.data, required this.message});

  factory BMResponse.fromJson(Map<String, dynamic> json) {
    return BMResponse(status: json['status'] ?? 0, data: BMData.fromJson(json['data'] ?? {}), message: json['message'] ?? '');
  }
}

class BMData {
  final String marketId;
  final String marketTime;
  final String marketType;
  final String bettingType;
  final String marketName;
  final String provider;
  final MarketCondition marketCondition;
  final String status;
  final bool inPlay;
  final bool closeByAlpha;
  final bool pauseByAlpha;
  final int sorting;
  final int sortPriority;
  final String competitionId;
  final String eventId;
  final String eventName;
  final String sid;
  final String competitionName;
  final String? createdBy;
  final List<BMRunner> runners;

  BMData({
    required this.marketId,
    required this.marketTime,
    required this.marketType,
    required this.bettingType,
    required this.marketName,
    required this.provider,
    required this.marketCondition,
    required this.status,
    required this.inPlay,
    required this.closeByAlpha,
    required this.pauseByAlpha,
    required this.sorting,
    required this.sortPriority,
    required this.runners,
    required this.competitionId,
    required this.eventId,
    required this.eventName,
    required this.sid,
    required this.competitionName,
    this.createdBy,
  });

  factory BMData.fromJson(Map<String, dynamic> json) {
    return BMData(
      marketId: json['marketId'] ?? '',
      marketTime: json['marketTime'] ?? '',
      marketType: json['marketType'] ?? '',
      bettingType: json['bettingType'] ?? '',
      marketName: json['marketName'] ?? '',
      provider: json['provider'] ?? '',
      marketCondition: MarketCondition.fromJson(json['marketCondition'] ?? {}),
      status: json['status'] ?? '',
      inPlay: json['inPlay'] ?? false,
      closeByAlpha: json['closeByAlpha'] ?? false,
      pauseByAlpha: json['pauseByAlpha'] ?? false,
      sorting: json['sorting'] is int ? json['sorting'] as int : int.tryParse(json['sorting']?.toString() ?? '') ?? 0,
      sortPriority: json['sortPriority'] is int ? json['sortPriority'] as int : int.tryParse(json['sortPriority']?.toString() ?? '') ?? 0,
      runners: (json['runners'] as List<dynamic>?)?.map((e) => BMRunner.fromJson(e)).toList() ?? [],
      competitionId: json['competitionId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName'] ?? '',
      sid: json['sid']?.toString() ?? '',
      competitionName: json['competitionName'] ?? '',
      createdBy: json['createdBy']?.toString(),
    );
  }
}

class MarketCondition {
  final String marketId;
  final bool betLock;
  final int minBet;
  final int maxBet;
  final int maxProfit;
  final int betDelay;
  final int mtp;
  final bool allowUnmatchBet;
  final int potLimit;
  final int volume;

  MarketCondition({
    required this.marketId,
    required this.betLock,
    required this.minBet,
    required this.maxBet,
    required this.maxProfit,
    required this.betDelay,
    required this.mtp,
    required this.allowUnmatchBet,
    required this.potLimit,
    required this.volume,
  });

  factory MarketCondition.fromJson(Map<String, dynamic> json) {
    return MarketCondition(
      marketId: json['marketId'] ?? json['MarketId'] ?? '',
      betLock: json['betLock'] ?? false,
     minBet: 100,//TODO:json['minBet'] ?? 0
      maxBet: 250000,//TODO:json['maxBet'] ?? 0
      maxProfit: json['maxProfit'] is int ? json['maxProfit'] as int : int.tryParse(json['maxProfit']?.toString() ?? '') ?? 0,
      betDelay: json['betDelay'] is int ? json['betDelay'] as int : int.tryParse(json['betDelay']?.toString() ?? '') ?? 0,
      mtp: json['mtp'] is int ? json['mtp'] as int : int.tryParse(json['mtp']?.toString() ?? '') ?? 0,
      allowUnmatchBet: json['allowUnmatchBet'] ?? false,
      potLimit: json['potLimit'] is int ? json['potLimit'] as int : int.tryParse(json['potLimit']?.toString() ?? '') ?? 0,
      volume: json['volume'] is int ? json['volume'] as int : int.tryParse(json['volume']?.toString() ?? '') ?? 0,
    );
  }
}

class BMRunner {
  final String id;
  final String name;
  final int sortPriority;
  final dynamic metadata;
  String backs;
  String backSize;
  String lays;
  String laySize;
  String status;
  BMRunner({
    required this.id,
    required this.name,
    required this.sortPriority,
    this.metadata,
    required this.backs,
    required this.backSize,
    required this.lays,
    required this.laySize,
    required this.status,
  });
  factory BMRunner.fromJson(Map<String, dynamic> json) {
    return BMRunner(
      id: json['id'] ?? json['Id']?.toString() ?? '0',
      name: json['name'] ?? '',
      sortPriority: json['sortPriority'] is int ? json['sortPriority'] as int : int.tryParse(json['sortPriority']?.toString() ?? '') ?? 0,
      metadata: json['metadata'],
      backs: '',
      backSize: '',
      lays: '',
      laySize: '',
      status: json['status'] ?? '',
    );
  }
}
