class InplayCountsResponse {
  final int status;
  final List<InplayCountsSport> data;
  final String message;

  InplayCountsResponse({required this.status, required this.data, required this.message});

  factory InplayCountsResponse.fromJson(Map<String, dynamic> json) {
    return InplayCountsResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)?.map((e) => InplayCountsSport.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class InplayCountsSport {
  final String id;
  final String name;
  final List<InplayCountsEvent> event;

  InplayCountsSport({required this.id, required this.name, required this.event});

  factory InplayCountsSport.fromJson(Map<String, dynamic> json) {
    return InplayCountsSport(id: json['id'] ?? '', name: json['name'] ?? '', event: (json['event'] as List<dynamic>?)?.map((e) => InplayCountsEvent.fromJson(e as Map<String, dynamic>)).toList() ?? []);
  }
}

class InplayCountsEvent {
  final String id;
  final String name;
  final String countryCode;
  final String venue;
  final String openDate;
  final dynamic metaData;
  final bool inPlay;
  final bool premiumMatch;
  final bool oddsMarket;
  final bool eSportMarket;
  final bool bookMakerMarket;
  final bool fancyMarket;
  final bool closeByAlpha;
  final bool enabledByAlpha;
  final List<dynamic> catalogues;
  final String competitionId;
  final dynamic competition;
  final String sid;
  final bool enabledByAdmin;
  InplayCountsEvent({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.venue,
    required this.openDate,
    required this.metaData,
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
    required this.competition,
    required this.sid,
    required this.enabledByAdmin,
  });

  factory InplayCountsEvent.fromJson(Map<String, dynamic> json) {
    return InplayCountsEvent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      countryCode: json['countryCode'] ?? '',
      venue: json['venue'] ?? '',
      openDate: json['openDate'] ?? '',
      metaData: json['metaData'],
      inPlay: json['inPlay'] ?? false,
      premiumMatch: json['premiumMatch'] ?? false,
      oddsMarket: json['oddsMarket'] ?? false,
      eSportMarket: json['eSportMarket'] ?? false,
      bookMakerMarket: json['bookMakerMarket'] ?? false,
      fancyMarket: json['fancyMarket'] ?? false,
      closeByAlpha: json['closeByAlpha'] ?? false,
      enabledByAlpha: json['enabledByAlpha'] ?? false,
      catalogues: json['catalogues'] ?? [],
      competitionId: json['CompetitionId'] ?? '',
      competition: json['Competition'],
      sid: json['sid'] ?? '',
      enabledByAdmin: json['enabledByAdmin'] ?? false,
    );
  }
}
