class SportsBookResponse {
  final List<SportsBookModel> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  SportsBookResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory SportsBookResponse.fromJson(Map<dynamic, dynamic> json) {
    return SportsBookResponse(
      data: (json['data'] as List? ?? []).map((e) => SportsBookModel.fromJson(e)).toList(),
      page: json['page'],
      pageSize: json['pageSize'],
      result: json['result'],
      status: json['status'],
      totalPages: json['totalPages'],
      totalRecords: json['totalRecords'],
    );
  }
}

class SportsBookModel {
  final int id;
  final String roundId;
  final String accountId;
  final String operatorId;
  final String operatorToken;
  final String createdDate;
  final String updatedDate;
  final String userId;
  final String betReqId;
  final String resultReqId;
  final String rollBackReqId;
  final String transactionId;
  final String gameId;
  final int rollbackAmount;
  final String betType;
  final String rollBackReason;
  final bool roundClosed;
  final String eventName;
  final String marketName;
  final String runnerName;
  final double exposure;
  final String marketId;
  final bool exposureEnabled;
  final double exposureTime;
  final String requestType;
  final String rollBackMessage;
  final double debitAmount;
  final String eventId;
  final double eventDate;
  final String eventStatus;
  final String competitionId;
  final String competitionName;
  final double odds;
  final String runnerType;
  final String selectionType;
  final String betfairEventId;
  final double creditAmount;

  SportsBookModel({
    required this.id,
    required this.roundId,
    required this.accountId,
    required this.operatorId,
    required this.operatorToken,
    required this.createdDate,
    required this.updatedDate,
    required this.userId,
    required this.betReqId,
    required this.resultReqId,
    required this.rollBackReqId,
    required this.transactionId,
    required this.gameId,
    required this.rollbackAmount,
    required this.betType,
    required this.rollBackReason,
    required this.roundClosed,
    required this.eventName,
    required this.marketName,
    required this.runnerName,
    required this.exposure,
    required this.marketId,
    required this.exposureEnabled,
    required this.exposureTime,
    required this.requestType,
    required this.rollBackMessage,
    required this.debitAmount,
    required this.eventId,
    required this.eventDate,
    required this.eventStatus,
    required this.competitionId,
    required this.competitionName,
    required this.odds,
    required this.runnerType,
    required this.selectionType,
    required this.betfairEventId,
    required this.creditAmount,
  });

  factory SportsBookModel.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> map = json ?? {};
    return SportsBookModel(
      id: _parseInt(map['id']),
      roundId: map['roundId']?.toString() ?? '',
      accountId: map['accountId']?.toString() ?? '',
      operatorId: map['operatorId']?.toString() ?? '',
      operatorToken: map['operatorToken']?.toString() ?? '',
      createdDate: map['createdDate']?.toString() ?? '',
      updatedDate: map['updatedDate']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      betReqId: map['betReqId']?.toString() ?? '',
      resultReqId: map['resultReqId']?.toString() ?? '',
      rollBackReqId: map['rollBackReqId']?.toString() ?? '',
      transactionId: map['transactionId']?.toString() ?? '',
      gameId: map['gameId']?.toString() ?? '',
      rollbackAmount: _parseInt(map['rollbackAmount']),
      betType: map['betType']?.toString() ?? '',
      rollBackReason: map['rollBackReason']?.toString() ?? '',
      roundClosed: map['roundClosed'] is bool ? map['roundClosed'] : map['roundClosed']?.toString().toLowerCase() == 'true',
      eventName: map['eventName']?.toString() ?? '',
      marketName: map['marketName']?.toString() ?? '',
      runnerName: map['runnerName']?.toString() ?? '',
      exposure: _parseDouble(map['exposure']),
      marketId: map['marketId']?.toString() ?? '',
      exposureEnabled: map['exposureEnabled'] is bool ? map['exposureEnabled'] : map['exposureEnabled']?.toString().toLowerCase() == 'true',
      exposureTime: _parseDouble(map['exposureTime']),
      requestType: map['requestType']?.toString() ?? '',
      rollBackMessage: map['rollBackMessage']?.toString() ?? '',
      debitAmount: _parseDouble(map['debitAmount']),
      eventId: map['eventId']?.toString() ?? '',
      eventDate: _parseDouble(map['eventDate']),
      eventStatus: map['eventStatus']?.toString() ?? '',
      competitionId: map['competitionId']?.toString() ?? '',
      competitionName: map['competitionName']?.toString() ?? '',
      odds: _parseDouble(map['odds']),
      runnerType: map['runnerType']?.toString() ?? '',
      selectionType: map['selectionType']?.toString() ?? '',
      betfairEventId: map['betfairEventId']?.toString() ?? '',
      creditAmount: _parseDouble(map['creditAmount']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
