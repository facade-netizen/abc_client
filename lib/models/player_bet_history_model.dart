class PlayerBetHistoryResponse {
  final String status;
  final List<PlayerBetHistory> data;
  final String message;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalRecords;

  PlayerBetHistoryResponse({
    required this.status,
    required this.data,
    required this.message,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
  });

  factory PlayerBetHistoryResponse.fromJson(Map<dynamic, dynamic> json) {
    final dynamic dataJson = json['data'];
    final List<PlayerBetHistory> parsedData;
    if (dataJson is List<dynamic>) {
      parsedData = dataJson.map((e) => PlayerBetHistory.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedData = [];
    }

    return PlayerBetHistoryResponse(
      data: parsedData,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class PlayerBetHistory {
  int orderId;
  BettingType bettingType;
  final String sportName;
  String marketId;
  String userId;
  String competitionId;
  String eventId;
  String runnerID;
  double stake;
  double price;
  String side;
  String timeStamp;
  String updatedTime;
  String status;
  String sid;
  double filledPrice;
  String rejectReason;
  String ip;
  String eventName;
  String competitionName;
  String runnerName;
  int buildNumber;
  String version;
  String mode;
  String platform;
  double exposure;
  double mtm;
  double liability;
  double profit;
  double loss;
  double openBalance;
  double closeBalance;
  bool isDone;
  String result;
  String userName;
  String line;
  final String marketName;

  PlayerBetHistory({
    required this.orderId,
    required this.sportName,
    required this.liability,
    required this.bettingType,
    required this.marketId,
    required this.userId,
    required this.competitionId,
    required this.eventId,
    required this.runnerID,
    required this.stake,
    required this.price,
    required this.side,
    required this.timeStamp,
    required this.updatedTime,
    required this.status,
    required this.sid,
    required this.filledPrice,
    required this.rejectReason,
    required this.ip,
    required this.eventName,
    required this.competitionName,
    required this.runnerName,
    required this.buildNumber,
    required this.version,
    required this.mode,
    required this.platform,
    required this.exposure,
    required this.mtm,
    required this.profit,
    required this.loss,
    required this.openBalance,
    required this.closeBalance,
    required this.isDone,
    required this.result,
    required this.userName,
    required this.line,
    required this.marketName,
  });

  factory PlayerBetHistory.fromJson(Map<String, dynamic> json) {
    final bool isBack = json['side']?.toLowerCase().contains('back') ?? false;

    // Parse the line value based on isBack flag
    String parsedLine = '';
    final dynamic lineValue = json['line'];

    if (lineValue != null && lineValue.toString().isNotEmpty) {
      if (isBack) {
        // If isBack is true, take the first value before comma
        parsedLine = lineValue.toString().split(',').first;
      } else {
        // If isBack is false (lay bet), take the last value after comma
        final List<String> parts = lineValue.toString().split(',');
        parsedLine = parts.length > 1 ? parts.last : parts.first;
      }
    }
    return PlayerBetHistory(
      orderId: json['orderId'] ?? 0,
      liability: json['liability'] ?? 0,
      sportName: getSportName(json["sid"] is int ? json["sid"] : int.tryParse("${json["sid"]}") ?? 0).toUpperCase(),
      bettingType: bettingTypeValue(json['bettingType'] ?? 0),
      marketId: json['marketId'] ?? "",
      userId: json['userId'] ?? "",
      competitionId: json['competitionId'] ?? "",
      eventId: json['eventId'] ?? "",
      runnerID: json['runnerID'] ?? "",
      stake: (json['stake'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      side: json['side'] ?? "",
      timeStamp: json['timeStamp'] ?? "",
      updatedTime: json['updatedTime'] ?? "",
      status: json['status'] ?? "",
      sid: json['sid'] ?? 0,
      filledPrice: (json['filledPrice'] as num?)?.toDouble() ?? 0.0,
      rejectReason: json['rejectReason'] ?? "",
      ip: json['ip'] ?? "",
      eventName: json['eventName'] ?? "",
      competitionName: json['competitionName'] ?? "",
      runnerName: json['runnerName'] ?? "",
      buildNumber: json['buildNumber'] ?? 0,
      version: json['version'] ?? "",
      mode: json['mode'] ?? "",
      platform: json['platform'] ?? "",
      marketName: json['marketName'] ?? '',
      exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
      mtm: (json['mtm'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      loss: (json['loss'] as num?)?.toDouble() ?? 0.0,
      openBalance: (json['openBalance'] as num?)?.toDouble() ?? 0.0,
      closeBalance: (json['closeBalance'] as num?)?.toDouble() ?? 0.0,
      isDone: json['isDone'] ?? false,
      result: json['result'] ?? "",
      userName: json['userName'] ?? "",
      line: parsedLine,
    );
  }
}

enum BettingType { odds, line, bookmaker }

BettingType bettingTypeValue(int value) {
  switch (value) {
    case 0:
      return BettingType.odds;
    case 1:
      return BettingType.line;
    case 2:
      return BettingType.bookmaker;
    default:
      return BettingType.odds;
  }
}

String bettingTypeName(BettingType type) {
  switch (type) {
    case BettingType.odds:
      return 'Match Odds';
    case BettingType.line:
      return 'FANCY_BET';
    case BettingType.bookmaker:
      return 'Bookmaker';
  }
}

String getSportName(int id) {
  switch (id) {
    case 4:
      return "Cricket";
    case 1:
      return "Soccer";
    case 2:
      return "Tennis";
    case 7:
      return "Horse Racing";
    case 4339:
      return "Greyhound Racing";
    case 2378961:
      return "Politics";
    default:
      return "Unknown";
  }
}
