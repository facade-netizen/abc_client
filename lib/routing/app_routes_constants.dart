class AppRoutes {
  // Base
  static const home = '/home';

  // Inplay
  static const inplay = '/inplay';
  static const inplayToday = '/inplay/today';
  static const inplayTomorrow = '/inplay/tomorrow';

  // Sports
  static const sport = '/sport/:sportId/:screenType';
  static const sportEvent = '/sport/:sportId/:screenType/event/:eventId/:inplay/:premium/:fancyMarket';

  // Result
  static const result = '/result';
  static const resultTab = '/result/:tab';

  // Account
  static const account = '/account';
  static const accountSection = '/account/:section';
  static const accountMyBets = '/account/my-bets/:tab';

  // Others
  static const multimarkets = '/multimarkets';
  // Maintenance
  static const maintenance = '/maintenance';
}
