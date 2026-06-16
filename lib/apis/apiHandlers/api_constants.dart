const String baseDomain = "dmxchge.com";
const String api = "api";
const String streamUrl1 = 'https://oddsdata.org/score/2bef785680b036112915136cca6d9d36621adb29/';
const String wlUrl = "https://abcuser.dmxchge.com/api/WL/get/a10542b4-6fb4-4da1-8f2b-16c19e3498b9";
const String loginSession = 'https://abcuser.dmxchge.com/userLoginSession';

class SportsApiConstants {
  static const String baseUrl = 'https://abcdata.$baseDomain/$api/';
  static const String eventTypes = '${baseUrl}eventTypes';
  static const String casino = '${baseUrl}casino';
  static const String sportsEvents = '${baseUrl}sportsEvents';
  static const String bookmaker = '${baseUrl}bookmaker';
  static const String odds = '${baseUrl}odds';
  static const String fancy = '${baseUrl}fancy';
  static const String resultMatch = 'resultMatch';
  static const String resultLine = 'resultLine';
  static const String competition = '${baseUrl}competition';
  static const String bmSignalRUrl = 'https://abcdata.dmxchge.com/broadcast';
  static const String eventHub = 'https://abcdata.dmxchge.com/eventhub';
  static const String inPlayEvents = '${baseUrl}inPlayEvents?evenTypeID=';
}

class AuthApiConstants {
  static const String baseUrl = 'https://abcuser.dmxchge.com/api/';
  static const String account = 'Account';
  static const String register = 'Auth/register';
  static const String login = '${baseUrl}Auth/login';
  static const String activityLog = '$account/activityLog';
  static const String changePassword = 'Auth/change-password';
  static const String resetPassword = '${baseUrl}Auth/change-password-1';
  static const String ip = 'https://api.ipify.org?format=json';
  static const String isp = 'https://ipapi.co/json/';
  static const String varifyToken = '${baseUrl}Auth/varifyToken/';
}

class OrdersApiConstants {
  static const String baseUrl = 'https://abcorder.dmxchge.com/';
  static const String order = 'order';
  static const String openOrder = 'openOrder';
  static const String matchBook = 'matchBook';
  static const String pnlHistory = 'pnlHistory';
  static const String matchProfitLoss = 'matchProfitLoss';
  static const String listener = '${baseUrl}listener';
  static const String orderReport = 'orderReport';
  static const String profitLoss = 'profitLoss';
  static const String userMatchProfitLossOdds = '${baseUrl}userMatchProfitLoss-Odds';
  static const String userMatchProfitLossLine = '${baseUrl}userMatchProfitLoss-Line';
}

class FavoriteApiConstants {
  static const String baseUrl = 'https://abcdata.dmxchge.com/api/';
  static const String baseUrlForOneClick = 'https://abcuser.dmxchge.com/api/';
  static const String stakeBaseUrl = 'https://abcuser.dmxchge.com/api/utility/';
  static const String favorite = 'favorites';
  static const String favStake = '${stakeBaseUrl}favStake';
  static const String mmFancy = '$favorite/Fancy';
  static const String detail = '$favorite/detail';
  static const String oneClick = '${baseUrlForOneClick}oneclick';
  static const String isClicked = '$oneClick/isClicked';
  static const String allStakes = '$oneClick/allStakes';
  static const String defaultStake = '$oneClick/defaultStake';
}

class CGApiConstants {
  static const String baseUrl = 'https://rgc.dmxchge.com/api/Casino/';
  static const String history = 'history';
  static const String addMoney = 'addMoney';
  static const String sportHistory = 'sportHistory';
  static const String fetchBalance = 'fetchBalance';
  static const String withDrawMoney = 'withDrawMoney';
  static const String cricket = '${baseUrl}cricket';
  static const String getGames = '${baseUrl}getGames';
  static const String baseUrlCasino = 'https://rgc.dmxchge.com/api/Casino';
}

class ScoringApiConstants {
  static const String criScore = "https://cricscore.devacms.com/api/scoreboard/fullscore?matchId=";
  static const String criScoreSignalr = "https://cricscore.devacms.com/scorehub";
}

class AppNewsStringConstants {
  static String newsApiEndpoint = 'https://news.dmxchge.com/api/News';
  static String newsSignalREndpoint = 'https://news.dmxchge.com/newsBroadcaster';
}
