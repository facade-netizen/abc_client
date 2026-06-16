import '../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';

class FancyMarketResponse {
  final int status;
  final List<FancyMarketData> data;

  FancyMarketResponse({required this.status, required this.data});

  factory FancyMarketResponse.fromJson(Map<String, dynamic> json) {
    return FancyMarketResponse(status: json['status'] ?? 0, data: (json['data'] as List<dynamic>?)?.map((e) => FancyMarketData.fromJson(e)).toList() ?? []);
  }
}

class FancyMarketData {
  final String marketId;
  final String marketTime;
  final String marketType;
  final String bettingType;
  final String marketName;
  final String provider;
  final MarketCondition? marketCondition;
  final String status;
  final bool inPlay;
  final bool sportingEvent;
  List<FancyRunner> runners;
  final String? competitionId;
  final String eventId;
  String? eventName;
  final String? sid;
  final int? sorting;
  final String? competitionName;

  FancyMarketData({
    required this.marketId,
    required this.marketTime,
    required this.marketType,
    required this.bettingType,
    required this.marketName,
    required this.provider,
    this.marketCondition,
    required this.status,
    required this.inPlay,
    required this.sportingEvent,
    required this.runners,
    this.competitionId,
    required this.eventId,
    this.eventName,
    this.sid,
    this.sorting,
    this.competitionName,
  });

  factory FancyMarketData.fromJson(Map<String, dynamic> json) {
    return FancyMarketData(
      marketId: json['marketId'] ?? '',
      marketTime: json['marketTime'] ?? '',
      marketType: json['marketType'] ?? '',
      bettingType: json['bettingType'] ?? '',
      marketName: json['marketName'] ?? '',
      provider: json['provider'] ?? '',
      marketCondition: MarketCondition.fromJson(json['marketCondition'] ?? {}),
      status: json['status'] ?? '',
      inPlay: json['inPlay'] ?? false,
      sportingEvent: json['sportingEvent'] ?? false,
      runners: (json['runners'] as List<dynamic>?)?.map((e) => FancyRunner.fromJson(e)).toList() ?? [],
      competitionId: json['competitionId'] ?? 0,
      eventId: json['eventId'] ?? 0,
      eventName: json['eventName'] ?? '',
      sid: json['sid'] ?? 0,
      sorting: json['sorting'] ?? 0,
      competitionName: json['competitionName'] ?? '',
    );
  }
  factory FancyMarketData.fromBuffer(ABCModel fancy) {
    return FancyMarketData(
      marketId: fancy.marketId,
      marketTime: fancy.marketTime,
      marketType: fancy.marketType,
      bettingType: fancy.bettingType.toString(),
      marketName: fancy.marketName,
      provider: '',
      marketCondition: MarketCondition(
        marketId: fancy.marketId,
        betLock: fancy.marketCondition.betLock,
        minBet: fancy.marketCondition.minBet.toDouble(),
        maxBet: fancy.marketCondition.maxBet.toDouble(),
        maxProfit: fancy.marketCondition.maxProfit.toDouble(),
        betDelay: fancy.marketCondition.betDelay.toDouble(),
        mtp: fancy.marketCondition.mtp.toDouble(),
        allowUnmatchBet: fancy.marketCondition.allowUnmatchBet,
        potLimit: fancy.marketCondition.potLimit.toDouble(),
        volume: fancy.marketCondition.volume.toDouble(),
      ),
      status: fancy.status.toString(),
      inPlay: fancy.inPlay,
      runners: fancy.runner
          .map((runner) => FancyRunner(
              id: runner.runnerId, name: runner.name, marketType: '', sortPriority: 0, metadata: null, backs: runner.backs, lays: runner.lays, status: runner.status.toString()))
          .toList(),
      eventId: fancy.eventId,
      sportingEvent: fancy.sportingEvent,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FancyMarketData && runtimeType == other.runtimeType && marketId == other.marketId && marketName == other.marketName;
  @override
  int get hashCode => marketId.hashCode;
}

class MarketCondition {
  final String marketId;
  final bool betLock;
  final double minBet;
  final double maxBet;
  final double maxProfit;
  final double betDelay;
  final double mtp;
  final bool allowUnmatchBet;
  final double potLimit;
  final double volume;

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
      marketId: json['marketId'] ?? '',
      betLock: json['betLock'] ?? false,
      minBet: json['minBet'] ?? 0,
      maxBet: json['maxBet'] ?? 0,
      maxProfit: json['maxProfit'] ?? 0,
      betDelay: json['betDelay'] ?? 0,
      mtp: json['mtp'] ?? 0,
      allowUnmatchBet: json['allowUnmatchBet'] ?? false,
      potLimit: json['potLimit'] ?? 0,
      volume: json['volume'] ?? 0,
    );
  }
}

class FancyRunner {
  final String id;
  final String name;
  final String marketType;
  final String status;
  final int sortPriority;
  final dynamic metadata;
  List<dynamic> backs;
  List<dynamic> lays;

  FancyRunner({
    required this.id,
    required this.name,
    required this.marketType,
    required this.sortPriority,
    required this.metadata,
    required this.backs,
    required this.lays,
    required this.status,
  });

  factory FancyRunner.fromJson(Map<String, dynamic> json) {
    return FancyRunner(
      id: json['id'] ?? '0',
      name: json['name'] ?? '',
      marketType: json['marketType'] ?? '',
      sortPriority: json['sortPriority'] ?? 0,
      metadata: json['metadata'],
      status: json['status'] ?? "",
      backs: [],
      lays: [],
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is FancyRunner && runtimeType == other.runtimeType && id == other.id && name == other.name;
  @override
  int get hashCode => id.hashCode;
}
