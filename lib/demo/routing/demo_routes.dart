class DemoRoutes {
  static const base = '/demo';

  static const home = '$base/home';

  static const inplay = '$base/inplay';
  static const inplayToday = '$base/inplay/today';
  static const inplayTomorrow = '$base/inplay/tomorrow';

  static const sport = '$base/sport/:sportId/:screenType';
  static const sportEvent = '$base/sport/:sportId/:screenType/event/:eventId/:inplay/:premium/:fancyMarket';

  static const result = '$base/result';
  static const resultTab = '$base/result/:tab';

  static const account = '$base/account';
  static const accountSection = '$base/account/:section';
  static const accountMyBets = '$base/account/my-bets/:tab';

  static const multimarkets = '$base/multimarkets';
}
