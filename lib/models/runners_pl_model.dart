class OddsRunnerPLResponse {
  final int status;
  final List<OddsRunnerPLData> data;
  final String message;

  OddsRunnerPLResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory OddsRunnerPLResponse.fromJson(Map<dynamic, dynamic> json) {
    return OddsRunnerPLResponse(
      status: json['status'] as int,
      data: (json['data'] as List<dynamic>?)?.map((e) => OddsRunnerPLData.fromJson(e)).toList() ?? [],
      message: json['message'] as String,
    );
  }
}

class OddsRunnerPLData {
  final String runnerId;
  final double net;
  final String bettingType;
  OddsRunnerPLData({
    required this.runnerId,
    required this.net,
    required this.bettingType,
  });

  factory OddsRunnerPLData.fromJson(Map<String, dynamic> json) {
    return OddsRunnerPLData(
      runnerId: json['runnerId'] ?? "",
      net: json['net'] ?? 0.0,
      bettingType: "",
    );
  }
}

class BMRunnerPLResponse {
  final int status;
  final List<BMRunnerPLData> data;
  final String message;

  BMRunnerPLResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BMRunnerPLResponse.fromJson(Map<dynamic, dynamic> json) {
    return BMRunnerPLResponse(
      status: json['status'] as int,
      data: (json['data'] as List<dynamic>?)?.map((e) => BMRunnerPLData.fromJson(e)).toList() ?? [],
      message: json['message'] as String,
    );
  }
}

class BMRunnerPLData {
  final String runnerId;
  final double net;
  final String bettingType;
  BMRunnerPLData({required this.runnerId, required this.net, required this.bettingType});

  factory BMRunnerPLData.fromJson(Map<String, dynamic> json) {
    return BMRunnerPLData(runnerId: json['runnerId'] ?? "", net: json['net'] ?? 0.0, bettingType: "");
  }
}

class FancyRunnerPLResponse {
  final int status;
  final List<FancyRunnerPLData> data;
  final String message;

  FancyRunnerPLResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory FancyRunnerPLResponse.fromJson(Map<dynamic, dynamic> json) {
    return FancyRunnerPLResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)?.map((e) => FancyRunnerPLData.fromJson(e)).toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class FancyRunnerPLData {
  final String runnerId;
  final double net;
  FancyRunnerPLData({
    required this.runnerId,
    required this.net,
  });

  factory FancyRunnerPLData.fromJson(Map<String, dynamic> json) {
    return FancyRunnerPLData(
      runnerId: json['runnerId'] ?? "",
      net: json['net'] ?? 0.0,
    );
  }
}

class FancyBookResponse {
  final int status;
  final List<RunData> data;
  final String message;

  FancyBookResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory FancyBookResponse.fromJson(Map<dynamic, dynamic> json) {
    return FancyBookResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>?)?.map((item) => RunData.fromJson(item)).toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class RunData {
  final int runs;
  final double amount;

  RunData({
    required this.runs,
    required this.amount,
  });

  factory RunData.fromJson(Map<String, dynamic> json) {
    return RunData(
      runs: json['runs'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
