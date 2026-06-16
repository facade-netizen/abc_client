class FavouriteStakeResponse {
  final int status;
  final FavStakeData data;
  final String message;

  FavouriteStakeResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory FavouriteStakeResponse.fromJson(Map<dynamic, dynamic> json) {
    return FavouriteStakeResponse(
      status: json['status'],
      data: FavStakeData.fromJson(json['data'] ?? {}),
      message: json['message'],
    );
  }
}

class FavStakeData {
  final String favStakes;
  final String commonStakes;
  final bool singleClick;
  final bool fancyBetAnyOdds;
  final bool sportsBookAnyOdds;
  final bool oddsAnyOdds;
  final bool enableForecastWithCommission;
  final double defaultStake;

  FavStakeData({
    required this.favStakes,
    required this.commonStakes,
    required this.singleClick,
    required this.fancyBetAnyOdds,
    required this.sportsBookAnyOdds,
    required this.oddsAnyOdds,
    required this.enableForecastWithCommission,
    required this.defaultStake,
  });

  factory FavStakeData.fromJson(Map<String, dynamic> json) {
    return FavStakeData(
      favStakes: json['FavStakes'] ?? "",
      commonStakes: json['CommonStakes'] ?? "",
      singleClick: json['SingleClick'] ?? false,
      fancyBetAnyOdds: json['FancyBetAnyOdds'] ?? false,
      sportsBookAnyOdds: json['SportsBookAnyOdds'] ?? false,
      oddsAnyOdds: json['OddsAnyOdds'] ?? false,
      enableForecastWithCommission: json['EnableForecastWithCommission'] ?? false,
      defaultStake: json['DefaultStake'] ?? 0,
    );
  }
}
