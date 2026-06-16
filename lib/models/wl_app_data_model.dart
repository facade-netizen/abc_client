class AppResponse {
  final int status;
  final AppData data;
  final String message;
  AppResponse({required this.status, required this.data, required this.message});
  factory AppResponse.fromJson(Map<String, dynamic> json) {
    return AppResponse(status: json['status'], data: AppData.fromJson(json['data']), message: json['message']);
  }
 
}

class AppData {
  final String id;
  final String appName;
  final String appColor;
  final String appId;
  final String appTrack;
  final String appVersion;
  final bool inMaintenance;
  final String platform;
  final String releasedOn;
  final String updateOn;
  final String adminDomainUrl;
  final String clientDomainUrl;
  final String favicon;
  final String logo;
  final String privacyPolicy;
  final bool isEnabled;
  final String remarks;
  final bool hasAdmin;
  final String adminLocalHost;
  final String clientLocalHost;

  AppData({
    required this.id,
    required this.appName,
    required this.appColor,
    required this.appId,
    required this.appTrack,
    required this.appVersion,
    required this.inMaintenance,
    required this.platform,
    required this.releasedOn,
    required this.updateOn,
    required this.adminDomainUrl,
    required this.clientDomainUrl,
    required this.favicon,
    required this.logo,
    required this.privacyPolicy,
    required this.isEnabled,
    required this.remarks,
    required this.hasAdmin,
    required this.adminLocalHost,
    required this.clientLocalHost,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      id: json['id'] ?? '',
      appName: json['appName'] ?? '',
      appColor: json['appColor'] ?? '',
      appId: json['appId'] ?? '',
      appTrack: json['appTrack'] ?? '',
      appVersion: json['appVersion'] ?? '',
      inMaintenance: json['inMaintenance'] ?? false,
      platform: json['platform'] ?? '',
      releasedOn: json['releasedOn'] ?? '',
      updateOn: json['updateOn'] ?? '',
      adminDomainUrl: json['adminDomainUrl'] ?? '',
      clientDomainUrl: json['clientDomainUrl'] ?? '',
      favicon: json['favicon'] ?? '',
      logo: json['logo'] ?? '',
      privacyPolicy: json['privacyPolicy'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      remarks: json['remarks'] ?? '',
      hasAdmin: json['hasAdmin'] ?? false,
      adminLocalHost: json['adminLocalHost'] ?? '',
      clientLocalHost: json['clientLocalHost'] ?? '',
    );
  }
}
