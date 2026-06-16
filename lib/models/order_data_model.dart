class BettingResponse {
  final int status;
  final List<Order> data;

  BettingResponse({required this.status, required this.data});

  factory BettingResponse.fromJson(Map<dynamic, dynamic> json) {
    return BettingResponse(status: json['status'], data: List<Order>.from(json['data'].map((x) => Order.fromJson(x))));
  }
}

class Order {
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
  final String? timeStamp;
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
  final String? result;

  Order({
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
    required this.isDone,
    this.result,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      bettingType: json['bettingType'],
      marketId: json['marketId'],
      userId: json['userId'],
      competitionId: json['competitionId'],
      eventId: json['eventId'],
      runnerID: json['runnerID'],
      stake: (json['stake'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      side: json['side'],
      timeStamp: json['timeStamp'],
      status: json['status'],
      sid: json['sid'] ?? "",
      filledPrice: (json['filledPrice'] as num).toDouble(),
      rejectReason: json['rejectReason'],
      ip: json['ip'],
      eventName: json['eventName'],
      competitionName: json['competitionName'],
      runnerName: json['runnerName'],
      buildNumber: json['buildNumber'],
      version: json['version'],
      mode: json['mode'],
      platform: json['platform'],
      exposure: (json['exposure'] as num).toDouble(),
      mtm: (json['mtm'] as num).toDouble(),
      isDone: json['isDone'],
      result: json['result'],
    );
  }
}
