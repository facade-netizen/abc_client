import 'player_bet_history_model.dart';

class OpenBettingResponse {
  int status;
  List<OpenEventBettingData> data;

  OpenBettingResponse({required this.status, required this.data});

  factory OpenBettingResponse.fromJson(Map<dynamic, dynamic> json) {
    return OpenBettingResponse(status: json['status'], data: (json['data'] as List).map((e) => OpenEventBettingData.fromJson(e)).toList());
  }
}

class OpenEventBettingData {
  String name;
  List<OpenOrder> openOrders;
  OpenEventBettingData({required this.name, required this.openOrders});
  factory OpenEventBettingData.fromJson(Map<String, dynamic> json) {
    return OpenEventBettingData(name: json['name'], openOrders: (json['orders'] as List).map((e) => OpenOrder.fromJson(e)).toList());
  }
}

class OpenOrder {
  int orderId;
  int betType;
  BettingType bettingType;
  final String sportName;
  String marketId;
  String marketName;
  String userId;
  String competitionId;
  String eventId;
  String runnerID;
  double stake;
  double price;
  String side;
  dynamic timeStamp;
  String status;
  String sid;
  double filledPrice;
  dynamic rejectReason;
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
  double profit;
  bool isDone;
  dynamic result;
  String line;

  OpenOrder({
    required this.orderId,
    required this.sportName,
    required this.bettingType,
    required this.marketName,
    required this.marketId,
    required this.userId,
    required this.competitionId,
    required this.eventId,
    required this.runnerID,
    required this.stake,
    required this.price,
    required this.side,
    this.timeStamp,
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
    required this.profit,
    required this.isDone,
    this.result,
    required this.line,
    required this.betType,
  });

  factory OpenOrder.fromJson(Map<String, dynamic> json) {
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
    return OpenOrder(
      orderId: json['orderId'] ?? 0,
      sportName: getSportName(json["sid"] is int ? json["sid"] : int.tryParse("${json["sid"]}") ?? 0).toUpperCase(),
      marketName: json['marketName'] ?? "",
      bettingType: bettingTypeValue(json['bettingType'] ?? 0),
      betType: json['bettingType'] is int ? json['bettingType'] as int : int.tryParse('${json['bettingType']}') ?? 0,
      marketId: json['marketId'] ?? "",
      userId: json['userId'] ?? "",
      competitionId: json['competitionId'] ?? "",
      eventId: json['eventId'] ?? "",
      runnerID: json['runnerID'] ?? "",
      stake: (json['stake'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      side: json['side'] ?? "",
      timeStamp: json['timeStamp'],
      status: json['status'] ?? "",
      sid: json['sid'] ?? 0,
      filledPrice: (json['filledPrice'] as num?)?.toDouble() ?? 0.0,
      rejectReason: json['rejectReason'],
      ip: json['ip'] ?? "",
      eventName: json['eventName'] ?? "",
      competitionName: json['competitionName'] ?? "",
      runnerName: json['runnerName'] ?? "",
      buildNumber: json['buildNumber'] ?? 0,
      version: json['version'] ?? "",
      mode: json['mode'] ?? "",
      platform: json['platform'] ?? "",
      exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
      mtm: (json['mtm'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
      isDone: json['isDone'] ?? false,
      result: json['result'],
      line: parsedLine,
    );
  }
}

double calculateTotalMtm(List<OpenEventBettingData> data) {
  return data.expand((event) => event.openOrders).map((order) => order.mtm).fold(0.0, (prev, mtm) => prev + mtm);
}
