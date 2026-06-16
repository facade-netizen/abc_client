class OddsResponse {
  final int status;
  final ODDSData data;
  final String message;

  OddsResponse({required this.status, required this.data, required this.message});

  factory OddsResponse.fromJson(Map<String, dynamic> json) {
    return OddsResponse(status: json['status'] ?? 0, data: ODDSData.fromJson(json['data'] ?? {}), message: json['message'] ?? '');
  }
}

class ODDSData {
  final String marketId;
  final String marketTime;
  final String marketType;
  final String bettingType;
  final String marketName;
  final String provider;
  final ODDsMarketCondition marketCondition;
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
  final List<ODDSRunner> runners;

  ODDSData({
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

  factory ODDSData.fromJson(Map<String, dynamic> json) {
    return ODDSData(
      marketId: json['marketId'] ?? '',
      marketTime: json['marketTime'] ?? '',
      marketType: json['marketType'] ?? '',
      bettingType: json['bettingType'] ?? '',
      marketName: json['marketName'] ?? '',
      provider: json['provider'] ?? '',
      marketCondition: ODDsMarketCondition.fromJson(json['marketCondition'] ?? {}),
      status: json['status'] ?? '',
      inPlay: json['inPlay'] ?? false,
      closeByAlpha: json['closeByAlpha'] ?? false,
      pauseByAlpha: json['pauseByAlpha'] ?? false,
      sorting: json['sorting'] is int ? json['sorting'] as int : int.tryParse(json['sorting']?.toString() ?? '') ?? 0,
      sortPriority: json['sortPriority'] is int ? json['sortPriority'] as int : int.tryParse(json['sortPriority']?.toString() ?? '') ?? 0,
      runners: (json['runners'] as List<dynamic>?)?.map((e) => ODDSRunner.fromJson(e)).toList() ?? [],
      competitionId: json['competitionId'] ?? '',
      eventId: json['eventId'] ?? '',
      eventName: json['eventName'] ?? '',
      sid: json['sid'] ?? '',
      competitionName: json['competitionName'] ?? '',
      createdBy: json['createdBy']?.toString(),
    );
  }
}

class ODDsMarketCondition {
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

  ODDsMarketCondition({
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

  factory ODDsMarketCondition.fromJson(Map<String, dynamic> json) {
    return ODDsMarketCondition(
      marketId: json['marketId'] ?? json['MarketId'] ?? '',
      betLock: json['betLock'] ?? false,
      minBet: 100, //TODO:json['minBet'] ?? 0
      maxBet: 250000, //TODO:json['maxBet'] ?? 0
      maxProfit: json['maxProfit'] ?? 0,
      betDelay: json['betDelay'] ?? 0,
      mtp: json['mtp'] ?? 0,
      allowUnmatchBet: json['allowUnmatchBet'] ?? false,
      potLimit: json['potLimit'] ?? 0,
      volume: json['volume'] ?? 0,
    );
  }
}

class ODDSRunner {
  final String id;
  final String name;
  final int sortPriority;
  final RunnerMetadata metadata;
  String backs;
  String backSize;
  String lays;
  String laySize;
  String status;

  ODDSRunner({
    required this.id,
    required this.name,
    required this.sortPriority,
    required this.metadata,
    required this.backs,
    required this.backSize,
    required this.lays,
    required this.laySize,
    required this.status,
  });

  factory ODDSRunner.fromJson(Map<String, dynamic> json) {
    return ODDSRunner(
      id: json['id'] ?? json['Id']?.toString() ?? '0',
      name: json['name'] ?? '',
      sortPriority: json['sortPriority'] is int ? json['sortPriority'] as int : int.tryParse(json['sortPriority']?.toString() ?? '') ?? 0,
      metadata: RunnerMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
      backs: '',
      backSize: '',
      lays: '',
      laySize: '',
      status: json['status'] ?? '',
    );
  }
}

class RunnerMetadata {
  final String runners;
  final String runnerId;
  final String scoreUrl;
  final String tvUrl;
  final String hasTv;
  final String messages;
  final String inactiveMarkets;
  final String archivedMarkets;

  RunnerMetadata({
    required this.runners,
    required this.runnerId,
    required this.scoreUrl,
    required this.tvUrl,
    required this.hasTv,
    required this.messages,
    required this.inactiveMarkets,
    required this.archivedMarkets,
  });

  factory RunnerMetadata.fromJson(Map<String, dynamic> json) {
    return RunnerMetadata(
      runners: json['runners'] ?? '',
      runnerId: json['runnerId'] ?? '',
      scoreUrl: json['scoreUrl'] ?? '',
      tvUrl: json['tvUrl'] ?? '',
      hasTv: json['hasTv'] ?? '',
      messages: json['messages'] ?? '',
      inactiveMarkets: json['inactiveMarkets'] ?? '',
      archivedMarkets: json['archivedMarkets'] ?? '',
    );
  }
}
