class ProfitLossResponse {
  final int status;
  final List<ProfitLoss> data;
  final String message;

  ProfitLossResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ProfitLossResponse.fromJson(Map<dynamic, dynamic> json) {
    return ProfitLossResponse(
      status: json['status'] as int,
      data: (json['data'] as List<dynamic>).map((e) => ProfitLoss.fromJson(e)).toList(),
      message: json['message'] ?? "",
    );
  }
}

class ProfitLoss {
  final int id;
  final int transType;
  final double amount;
  final String date;
  final String comment;
  final String marketId;
  final String userId;
  final String accountId;
  final dynamic user;
  final dynamic account;

  ProfitLoss({
    required this.id,
    required this.transType,
    required this.amount,
    required this.date,
    required this.comment,
    required this.marketId,
    required this.userId,
    required this.accountId,
    this.user,
    this.account,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) {
    return ProfitLoss(
      id: json['id'] ?? 0,
      transType: json['transType'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? "",
      comment: json['comment'] ?? "",
      marketId: json['marketId'] ?? "",
      userId: json['userId'] ?? "",
      accountId: json['accountId'] ?? "",
      user: json['user'],
      account: json['account'],
    );
  }
}
