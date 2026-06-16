class AppConfig {
  String appName;
  String packageName;
  String version;
  int buildNumber;
  String dated;
  String debugMode;
  String operatingSystem;
  AppConfig(
      {required this.appName,
      required this.packageName,
      required this.version,
      required this.buildNumber,
      required this.dated,
      required this.debugMode,
      required this.operatingSystem});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'dated': dated,
      'debugMode': debugMode,
      'operatingSystem': operatingSystem,
      'url': Uri.base.toString(),
    };
  }
}

late AppConfig appConfig;
