class PlayerProfitAndLossResponse {
  final List<PlayerProfitAndLossResponseResult> data;
  final int page;
  final int pageSize;
  final double totalPnl;
  final String status;
  final int totalPages;
  final int totalRecords;

  PlayerProfitAndLossResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalPnl,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory PlayerProfitAndLossResponse.fromJson(Map<dynamic, dynamic> json) {
    return PlayerProfitAndLossResponse(
      data: (json['data'] as List? ?? []).map((e) => PlayerProfitAndLossResponseResult.fromJson(e)).toList(),
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPnl: (json['result'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}


class PlayerProfitAndLossResponseResult {
  final int categoryType;
  final String eventTypeName;
  final String eventName;
  final String eventID;
  final String marketName;
  final int marketLive;
  final String marketID;
  final String startTime;
  final String settledDate;
  final double pl;
  final double marketTotal;
  final double commission;
  final double netTotal;
  final double totalPL;
  final String marketType;
  final ResultDetails? details;

  PlayerProfitAndLossResponseResult({
    required this.categoryType,
    required this.eventTypeName,
    required this.eventName,
    required this.eventID,
    required this.marketName,
    required this.marketLive,
    required this.marketID,
    required this.startTime,
    required this.settledDate,
    required this.pl,
    required this.marketTotal,
    required this.commission,
    required this.netTotal,
    required this.totalPL,
    required this.marketType,
    this.details,
  });

  factory PlayerProfitAndLossResponseResult.fromJson(Map<String, dynamic> json) {
    return PlayerProfitAndLossResponseResult(
      categoryType: json['categoryType'] as int? ?? 0,
      eventTypeName: json['eventTypeName'] ?? '',
      eventName: json['eventName'] ?? '',
      eventID: json['eventID'] ?? '',
      marketName: json['marketName'] ?? '',
      marketLive: json['marketLive'] as int? ?? 0,
      marketID: json['marketID'] ?? '',
      startTime: json['startTime'] ?? '',
      settledDate: json['settledDate'] ?? '',
      pl: (json['pl'] as num?)?.toDouble() ?? 0.0,
      marketTotal: (json['marketTotal'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['netTotal'] as num?)?.toDouble() ?? 0.0,
      totalPL: (json['totalPL'] as num?)?.toDouble() ?? 0.0,
      marketType: json['marketType'] ?? '',
      details: json['details'] != null ? ResultDetails.fromJson(json['details'] as Map<String, dynamic>) : null,
    );
  }
}

class ResultDetails {
  final List<ResultBets> orders;
  final double totalBack;
  final double totalLay;
  final double total;
  final double totalStack;
  final double totalCommission;

  ResultDetails({
    required this.orders,
    required this.totalBack,
    required this.totalLay,
    required this.total,
    required this.totalStack,
    required this.totalCommission,
  });

  factory ResultDetails.fromJson(Map<String, dynamic> json) {
    return ResultDetails(
      orders: (json['orders'] as List<dynamic>?)?.map((e) => ResultBets.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      totalBack: (json['totalBack'] as num?)?.toDouble() ?? 0.0,
      totalLay: (json['totalLay'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      totalStack: (json['totalStack'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ResultBets {
  final int orderId;
  final int bettingType;
  final String marketId;
  final String userId;
  final String competitionId;
  final String eventId;
  final String runnerID;
  final double stake;
  final double price;
  final String side;
  final String timeStamp;
  final String status;
  final String sid;
  final double filledPrice;
  final String? rejectReason;
  final String ip;
  final String eventName;
  final String competitionName;
  final String runnerName;
  final int buildNumber;
  final String version;
  final String mode;
  final String platform;
  final double exposure;
  final double mtm;
  final bool isDone;
  final String result;
  final String line;

  ResultBets({
    required this.orderId,
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
    required this.status,
    required this.sid,
    required this.filledPrice,
    this.rejectReason,
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
    required this.isDone,
    required this.result,
    required this.line,
  });

  factory ResultBets.fromJson(Map<String, dynamic> json) {
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

    return ResultBets(
      orderId: json['orderId'] as int? ?? 0,
      bettingType: json['bettingType'] as int? ?? 0,
      marketId: json['marketId'] ?? '',
      userId: json['userId'] ?? '',
      competitionId: json['competitionId'] ?? '',
      eventId: json['eventId'] ?? '',
      runnerID: json['runnerID'] ?? '',
      stake: (json['stake'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      side: json['side'] ?? '',
      timeStamp: json['timeStamp'] ?? '',
      status: json['status'] ?? '',
      sid: json['sid'] ?? '',
      filledPrice: (json['filledPrice'] as num?)?.toDouble() ?? 0.0,
      rejectReason: json['rejectReason'],
      ip: json['ip'] ?? '',
      eventName: json['eventName'] ?? '',
      competitionName: json['competitionName'] ?? '',
      runnerName: json['runnerName'] ?? '',
      buildNumber: json['buildNumber'] as int? ?? 0,
      version: json['version'] ?? '',
      mode: json['mode'] ?? '',
      platform: json['platform'] ?? '',
      exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
      mtm: (json['mtm'] as num?)?.toDouble() ?? 0.0,
      isDone: json['isDone'] as bool? ?? false,
      result: json['result'] ?? '',
      line: parsedLine,
    );
  }
}