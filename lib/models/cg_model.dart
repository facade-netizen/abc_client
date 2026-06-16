class CGResponse {
  final int status;
  final List<CGData> data;
  final String message;
  final int count;

  CGResponse({required this.status, required this.data, required this.message, required this.count});

  factory CGResponse.fromJson(Map<String, dynamic> json) {
    return CGResponse(
        status: json['status'] ?? 0,
        data: (json['data'] as List<dynamic>?)?.map((e) => CGData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        message: json['message'] ?? '',
        count: json['count'] ?? 0);
  }
}

class CGData {
  final String gameId;
  final String gameName;
  final String category;
  final String providerName;
  final String subProviderName;
  final String status;
  final String urlThumb;
  final String gameCode;

  CGData({
    required this.gameId,
    required this.gameName,
    required this.category,
    required this.providerName,
    required this.subProviderName,
    required this.status,
    required this.urlThumb,
    required this.gameCode,
  });

  factory CGData.fromJson(Map<String, dynamic> json) {
    return CGData(
      gameId: json['gameId'] ?? '',
      gameName: json['gameName'] ?? '',
      category: json['category'] ?? '',
      providerName: json['providerName'] ?? '',
      subProviderName: json['subProviderName'] ?? '',
      status: json['status'] ?? '',
      urlThumb: json['urlThumb'] ?? '',
      gameCode: json['gameCode'] ?? '',
    );
  }
}