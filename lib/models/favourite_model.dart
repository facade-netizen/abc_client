import '../blocs/addBloc/add_favourite_event_bloc.dart';

class FavouriteModelResponse {
  final int status;
  final List<FavouriteEventData> data;
  final String message;

  FavouriteModelResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory FavouriteModelResponse.fromJson(Map<dynamic, dynamic> json) {
    return FavouriteModelResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? []).map((e) => FavouriteEventData.fromJson(e)).toList(),
    );
  }
}

class FavouriteEventData {
  final String id;
  final String sid;
  final String name;
  final String marketId;
  final String marketName;
  final String status;
  final FavType favType;
  final bool inPlay;
  final List<FavRunner> runners;
  final List<FavFancyRunner> fancyRunners;
  final String countryCode;
  final String venue;
  final String openDate;
  final bool premiumMatch;
  final bool oddsMarket;
  final bool eSportMarket;
  final bool bookMakerMarket;
  final bool fancyMarket;
  final bool closeByAlpha;
  final bool enabledByAlpha;
  final List<dynamic> catalogues;
  final String competitionId;
  final String marketType;
  final dynamic competition;
  final bool enabledByAdmin;
  final int? sorting;

  FavouriteEventData({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.venue,
    required this.openDate,
    required this.inPlay,
    required this.premiumMatch,
    required this.oddsMarket,
    required this.eSportMarket,
    required this.bookMakerMarket,
    required this.fancyMarket,
    required this.closeByAlpha,
    required this.enabledByAlpha,
    required this.catalogues,
    required this.competitionId,
    this.competition,
    required this.sid,
    required this.enabledByAdmin,
    required this.marketId,
    required this.marketName,
    required this.status,
    required this.favType,
    required this.runners,
    required this.fancyRunners,
    required this.marketType,
    this.sorting,
  });

  factory FavouriteEventData.fromJson(Map<String, dynamic> json) {
    return FavouriteEventData(
      id: json['eventId'] ?? '',
      sid: json['sid'] ?? '',
      name: json['eventName'] ?? '',
      inPlay: json['inPlay'] ?? false,
      countryCode: json['countryCode'] ?? '',
      venue: json['venue'] ?? '',
      openDate: json['openDate'] ?? '',
      premiumMatch: json['premium'] ?? false,
      oddsMarket: json['oddsMarket'] ?? false,
      eSportMarket: json['eSportMarket'] ?? false,
      bookMakerMarket: json['bookMakerMarket'] ?? false,
      fancyMarket: json['fancyMarket'] ?? false,
      closeByAlpha: json['closeByAlpha'] ?? false,
      enabledByAlpha: json['enabledByAlpha'] ?? false,
      catalogues: json['catalogues'] ?? [],
      competitionId: json['CompetitionId']?.toString() ?? '',
      competition: json['Competition'],
      enabledByAdmin: json['enabledByAdmin'] ?? false,
      marketId: json['marketId'] ?? '',
      marketName: json['marketName'] ?? '',
      status: json['status'] ?? '',
      favType: favTypeValue(json['bettingType'] ?? ''),
      marketType: json['marketType'] ?? '',
      sorting: json['sorting'] is int ? json['sorting'] as int : int.tryParse(json['sorting']?.toString() ?? '') ?? 0,
      runners: (json['runners'] as List? ?? []).map((e) => FavRunner.fromJson(e)).toList(),
      fancyRunners: (json['runners'] as List? ?? []).map((e) => FavFancyRunner.fromJson(e)).toList(),
    );
  }
}

FavType favTypeValue(String value) {
  switch (value.toLowerCase()) {
    case 'odds':
      return FavType.odds;
    case 'line':
      return FavType.line;
    case 'lines':
      return FavType.lines;
    case 'bookmaker':
      return FavType.bookmaker;
    default:
      return FavType.odds;
  }
}

class FavRunner {
  final String id;
  final String name;
  final int sortPriority;
  String backs;
  String backSize;
  String lays;
  String laySize;
  String status;

  FavRunner({
    required this.id,
    required this.name,
    required this.sortPriority,
    required this.backs,
    required this.backSize,
    required this.lays,
    required this.laySize,
    required this.status,
  });

  factory FavRunner.fromJson(Map<String, dynamic> json) {
    return FavRunner(
      id: json['id'] ?? json['Id']?.toString() ?? '0',
      name: json['name'] ?? '',
      sortPriority: json['sortPriority'] is int ? json['sortPriority'] as int : int.tryParse(json['sortPriority']?.toString() ?? '') ?? 0,
      backs: '',
      backSize: '',
      lays: '',
      laySize: '',
      status: json['status'] ?? '',
    );
  }
}

class FavFancyRunner {
  final String id;
  final String name;
  final String marketType;
  final String status;
  final int sortPriority;
  final dynamic metadata;
  List<dynamic> backs;
  List<dynamic> lays;

  FavFancyRunner({
    required this.id,
    required this.name,
    required this.marketType,
    required this.sortPriority,
    required this.metadata,
    required this.backs,
    required this.lays,
    required this.status,
  });

  factory FavFancyRunner.fromJson(Map<String, dynamic> json) {
    return FavFancyRunner(
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
  bool operator ==(Object other) => identical(this, other) || other is FavFancyRunner && runtimeType == other.runtimeType && id == other.id && name == other.name;
  @override
  int get hashCode => id.hashCode;
}
