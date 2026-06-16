class DemoGoToRoute {
  static String sport({required String sportId, required String name}) => '/demo/sport/${Uri.encodeComponent(sportId)}/${Uri.encodeComponent(name)}';

  static String sportEvent({required String sportId, required String name, required String eventId, required bool inPlay, required bool premium, bool fancyMarket = false}) =>
      '/demo/sport/${Uri.encodeComponent(sportId)}/${Uri.encodeComponent(name)}/event/${Uri.encodeComponent(eventId)}/$inPlay/$premium/$fancyMarket';

  static String result([String? tab]) => tab == null ? '/demo/result' : '/demo/result/$tab';

  static String inplay({String? type}) {
    if (type == 'today') return '/demo/inplay/today';
    if (type == 'tomorrow') return '/demo/inplay/tomorrow';
    return '/demo/inplay';
  }

  static String account([String? section]) => section == null ? '/demo/account' : '/demo/account/$section';

  static String accountMyBets(String tab) => '/demo/account/my-bets/$tab';

  static String multimarkets() => '/demo/multimarkets';
}
