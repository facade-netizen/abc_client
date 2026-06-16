class CGBalanceResponse {
  final int status;
  final List<CGBalanceData> data;
  final String message;

  CGBalanceResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory CGBalanceResponse.fromJson(Map<dynamic, dynamic> json) {
    return CGBalanceResponse(
      status: json['status'],
      data: (json['data'] as List<dynamic>? ?? []).map((e) => CGBalanceData.fromJson(e)).toList(),
      message: json['message'],
    );
  }
}

class CGBalanceData {
  final int id;
  final String name;
  final String displayName;
  final double openBalance;
  final double currentBalance;
  final String accountId;

  CGBalanceData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.openBalance,
    required this.currentBalance,
    required this.accountId,
  });

  factory CGBalanceData.fromJson(Map<String, dynamic> json) {
    return CGBalanceData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? "",
      openBalance: json['openBalance'] ?? 0.0,
      currentBalance: json['currentBalance'] ?? 0.0,
      accountId: json['accountId'] ?? '',
    );
  }
}
