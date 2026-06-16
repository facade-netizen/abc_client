class ResultResponse {
  final int status;
  final ResultData data;
  final String message;

  ResultResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ResultResponse.fromJson(Map<dynamic, dynamic> json) {
    return ResultResponse(
      status: json['status'] ?? 0,
      data: ResultData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ResultData {
  final DayData today;
  final DayData yesterday;

  ResultData({
    required this.today,
    required this.yesterday,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      today: DayData.fromJson(json['Today'] ?? {}),
      yesterday: DayData.fromJson(json['Yesterday'] ?? {}),
    );
  }
}

class DayData {
  final List<CricketMatch> cricket;
  final List<OtherMatch> soccer;
  final List<OtherMatch> eSoccer;

  DayData({
    required this.cricket,
    required this.soccer,
    required this.eSoccer,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      cricket: (json['CRICKET'] as List).map((item) => CricketMatch.fromJson(item)).toList(),
      soccer: (json['SOCCER'] as List).map((item) => OtherMatch.fromJson(item)).toList(),
      eSoccer: (json['E_SOCCER'] as List).map((item) => OtherMatch.fromJson(item)).toList(),
    );
  }
}

class CricketMatch {
  final String eventDate;
  final String eventName;
  final String home;
  final String away;

  CricketMatch({
    required this.eventDate,
    required this.eventName,
    required this.home,
    required this.away,
  });

  factory CricketMatch.fromJson(Map<String, dynamic> json) {
    return CricketMatch(
      eventDate: json['event_date'] ?? "",
      eventName: json['event_name'] ?? "",
      home: json['home'] ?? "",
      away: json['away'] ?? "",
    );
  }
}

class OtherMatch {
  final String eventDate;
  final String eventName;
  final String ht; // Half Time
  final String ft; // Full Time

  OtherMatch({
    required this.eventDate,
    required this.eventName,
    required this.ht,
    required this.ft,
  });

  factory OtherMatch.fromJson(Map<String, dynamic> json) {
    return OtherMatch(
      eventDate: json['event_date'] ?? "",
      eventName: json['event_name'] ?? "",
      ht: json['HT'] ?? "",
      ft: json['FT'] ?? "",
    );
  }
}

////Result Line Match
class ResultLineResponse {
  final int status;
  final List<ResultLineData> data;
  final String message;

  ResultLineResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ResultLineResponse.fromJson(Map<dynamic, dynamic> json) {
    return ResultLineResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List).map((item) => ResultLineData.fromJson(item)).toList(),
      message: json['message'] ?? '',
    );
  }
}

class ResultLineData {
  final String eventId;
  final String eventName;
  final String openDate;
  final List<MarketLineModel> details;

  ResultLineData({
    required this.eventId,
    required this.eventName,
    required this.openDate,
    required this.details,
  });

  factory ResultLineData.fromJson(Map<String, dynamic> json) {
    return ResultLineData(
      eventId: json['eventId']?.toString() ?? "",
      eventName: json['eventName'] ?? "",
      openDate: json['openDate'] ?? "",
      details: (json['details'] as List).map((item) => MarketLineModel.fromJson(item)).toList(),
    );
  }
}

class MarketLineModel {
  final String marketId;
  final String marketName;
  final String result;
  final String source;
  final String marketType;

  MarketLineModel({
    required this.marketId,
    required this.marketName,
    required this.result,
    required this.source,
    required this.marketType,
  });

  factory MarketLineModel.fromJson(Map<String, dynamic> json) {
    return MarketLineModel(
      marketId: json['marketId']?.toString() ?? "",
      marketName: json['marketName'] ?? "",
      result: json['result']?.toString() ?? "",
      source: json['source'] ?? "",
      marketType: json['marketType'] ?? "",
    );
  }
}
