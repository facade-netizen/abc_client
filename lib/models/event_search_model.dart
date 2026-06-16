

class SearchCompetitionResponse {
  final int status;
  final SearchCompetitionData data;
  SearchCompetitionResponse({required this.status, required this.data});
  factory SearchCompetitionResponse.fromJson(Map<String, dynamic> json) {
    return SearchCompetitionResponse(status: json['status'], data: SearchCompetitionData.fromJson(json['data']));
  }
}

class SearchCompetitionData {
  final String id;
  final String name;
  final List<SearchCompetition> competitions;
  SearchCompetitionData({required this.id, required this.name, required this.competitions});
  factory SearchCompetitionData.fromJson(Map<String, dynamic> json) {
    return SearchCompetitionData(id: json['id'], name: json['name'], competitions: (json['competitions'] as List).map((e) => SearchCompetition.fromJson(e)).toList());
  }
}

class SearchCompetition {
  final String id;
  final String name;
  final List<SearchEvent> events;
  SearchCompetition({required this.id, required this.name, required this.events});
  factory SearchCompetition.fromJson(Map<String, dynamic> json) {
    return SearchCompetition(id: json['id'], name: json['name'], events: (json['event'] as List).map((e) => SearchEvent.fromJson(e)).toList());
  }
}

class SearchEvent {
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
  final String competition;
  final String sid;
  final bool enabledByAdmin;
  SearchEvent({
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

  factory SearchEvent.fromJson(Map<String, dynamic> json) {
    return SearchEvent(
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
      competitionId: json['CompetitionId'] ?? "",
      competition: json['Competition']?.toString() ?? '',
      sid: json['sid']?.toString() ?? '',
      enabledByAdmin: json['enabledByAdmin'] ?? false,
    );
  }
}
