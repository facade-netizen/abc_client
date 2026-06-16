import '../blocs/signalRBloc/protoUsage/receive/receive.pb.dart';

class MMFancyMarketResponse {
  final int status;
  final List<List<MMFancyMarketData>> data;
  final String message;

  MMFancyMarketResponse({required this.status, required this.data, required this.message});

  factory MMFancyMarketResponse.fromJson(Map<dynamic, dynamic> json) {
    return MMFancyMarketResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List).map((outer) => (outer as List).map((inner) => MMFancyMarketData.fromJson(inner)).toList()).toList(),
    );
  }
}

class MMFancyMarketData {
  final String marketId;
  final String marketTime;
  final String marketType;
  final String bettingType;
  final String marketName;
  final String provider;
  final MarketCondition? marketCondition;
  final String status;
  final bool inPlay;
  bool? premium;
  bool? fancyMarket;
  bool? bookMakerMarket;
  bool? oddsMarket;
  final bool sportingEvent;
  List<MMFancyRunner> runners;
  final String? competitionId;
  final String eventId;
  String? eventName;
  final String? sid;
  final int? sorting;
  final String? competitionName;

  MMFancyMarketData({
    required this.marketId,
    required this.marketTime,
    required this.marketType,
    required this.bettingType,
    required this.marketName,
    required this.provider,
    this.marketCondition,
    required this.status,
    required this.inPlay,
    this.premium,
    this.fancyMarket,
    this.oddsMarket,
    this.bookMakerMarket,
    required this.sportingEvent,
    required this.runners,
    this.competitionId,
    required this.eventId,
    this.eventName,
    this.sid,
    this.sorting,
    this.competitionName,
  });

  factory MMFancyMarketData.fromJson(Map<String, dynamic> json) {
    return MMFancyMarketData(
      marketId: json['marketId']?.toString() ?? '',
      marketTime: json['marketTime']?.toString() ?? '',
      marketType: json['marketType']?.toString() ?? '',
      bettingType: json['bettingType']?.toString() ?? '',
      marketName: json['marketName']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      marketCondition: MarketCondition.fromJson(json['marketCondition']),
      status: json['status']?.toString() ?? '',
      inPlay: json['inPlay'] ?? false,
      premium: json['premium'] ?? false,
      fancyMarket: json['fancyMarket'] ?? false,
      oddsMarket: json['oddsMarket'] ?? false,
      bookMakerMarket: json['bookMakerMarket'] ?? false,
      sportingEvent: json['sportingEvent'] ?? false,
      runners: (json['runners'] as List<dynamic>?)?.map((e) => MMFancyRunner.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      competitionId: json['competitionId']?.toString(),
      eventId: json['eventId']?.toString() ?? '',
      eventName: json['eventName']?.toString(),
      sid: json['sid']?.toString(),
      sorting: json['sorting'] is int ? json['sorting'] as int : int.tryParse('${json['sorting']}') ?? 0,
      competitionName: json['competitionName']?.toString(),
    );
  }
  factory MMFancyMarketData.fromBuffer(ABCModel fancy) {
    return MMFancyMarketData(
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
          .map(
            (runner) => MMFancyRunner(
              id: runner.runnerId,
              name: runner.name,
              marketType: '',
              sortPriority: 0,
              metadata: null,
              backs: runner.backs,
              lays: runner.lays,
              status: runner.status.toString(),
            ),
          )
          .toList(),
      eventId: fancy.eventId,
      sportingEvent: fancy.sportingEvent,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MMFancyMarketData && runtimeType == other.runtimeType && marketId == other.marketId && marketName == other.marketName;
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

  factory MarketCondition.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return MarketCondition(
        marketId: json['marketId']?.toString() ?? '',
        betLock: json['betLock'] ?? false,
        minBet: (json['minBet'] is num ? (json['minBet'] as num).toDouble() : double.tryParse('${json['minBet']}') ?? 0),
        maxBet: (json['maxBet'] is num ? (json['maxBet'] as num).toDouble() : double.tryParse('${json['maxBet']}') ?? 0),
        maxProfit: (json['maxProfit'] is num ? (json['maxProfit'] as num).toDouble() : double.tryParse('${json['maxProfit']}') ?? 0),
        betDelay: (json['betDelay'] is num ? (json['betDelay'] as num).toDouble() : double.tryParse('${json['betDelay']}') ?? 0),
        mtp: (json['mtp'] is num ? (json['mtp'] as num).toDouble() : double.tryParse('${json['mtp']}') ?? 0),
        allowUnmatchBet: json['allowUnmatchBet'] ?? false,
        potLimit: (json['potLimit'] is num ? (json['potLimit'] as num).toDouble() : double.tryParse('${json['potLimit']}') ?? 0),
        volume: (json['volume'] is num ? (json['volume'] as num).toDouble() : double.tryParse('${json['volume']}') ?? 0),
      );
    }

    return MarketCondition(marketId: '', betLock: false, minBet: 0, maxBet: 0, maxProfit: 0, betDelay: 0, mtp: 0, allowUnmatchBet: false, potLimit: 0, volume: 0);
  }
}

class MMFancyRunner {
  final String id;
  final String name;
  final String marketType;
  final String status;
  final int sortPriority;
  final dynamic metadata;
  List<dynamic> backs;
  List<dynamic> lays;

  MMFancyRunner({
    required this.id,
    required this.name,
    required this.marketType,
    required this.sortPriority,
    required this.metadata,
    required this.backs,
    required this.lays,
    required this.status,
  });

  factory MMFancyRunner.fromJson(Map<String, dynamic> json) {
    return MMFancyRunner(
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
  bool operator ==(Object other) => identical(this, other) || other is MMFancyRunner && runtimeType == other.runtimeType && id == other.id && name == other.name;
  @override
  int get hashCode => id.hashCode;
}
