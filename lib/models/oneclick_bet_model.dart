class OneClickBetResponse {
  final int status;
  final OneClickBetData data;
  final String message;

  OneClickBetResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory OneClickBetResponse.fromJson(Map<dynamic, dynamic> json) {
    return OneClickBetResponse(
      status: json['status'] ?? 0,
      data: OneClickBetData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class OneClickBetData {
  final String userId;
  final double stakeOne;
  final double stakeTwo;
  final double stakeThree;
  final double stakeFour;
  final double defaultStake;
  final bool isClicked;

  OneClickBetData({
    required this.userId,
    required this.stakeOne,
    required this.stakeTwo,
    required this.stakeThree,
    required this.stakeFour,
    required this.defaultStake,
    required this.isClicked,
  });

  factory OneClickBetData.fromJson(Map<String, dynamic> json) {
    return OneClickBetData(
      userId: json['UserId'] ?? '',
      stakeOne: (json['StakeOne'] ?? 0).toDouble(),
      stakeTwo: (json['StakeTwo'] ?? 0).toDouble(),
      stakeThree: (json['StakeThree'] ?? 0).toDouble(),
      stakeFour: (json['StakeFour'] ?? 0).toDouble(),
      defaultStake: (json['DefaultStake'] ?? 0).toDouble(),
      isClicked: json['IsClicked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'StakeOne': stakeOne,
      'StakeTwo': stakeTwo,
      'StakeThree': stakeThree,
      'StakeFour': stakeFour,
      'DefaultStake': defaultStake,
      'IsClicked': isClicked,
    };
  }
}
