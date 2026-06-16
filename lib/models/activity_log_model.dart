class ActivityLogsResponse {
  final List<ActivityLogsData> data;
  final int page;
  final int pageSize;
  final int result;
  final String status;
  final int totalPages;
  final int totalRecords;

  ActivityLogsResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.result,
    required this.status,
    required this.totalPages,
    required this.totalRecords,
  });

  factory ActivityLogsResponse.fromJson(Map<dynamic, dynamic> json) {
    final data = (json['data'] as List? ?? []).map((e) => ActivityLogsData.fromJson(e)).toList();
    final String latestValidIp = data.lastWhere((row) => row.hasValidIp, orElse: () => ActivityLogsData.empty()).ip;
    final String latestValidIsp = data.lastWhere((row) => row.hasValidIsp, orElse: () => ActivityLogsData.empty()).isp;
    final String latestValidAddress = data.lastWhere((row) => row.hasValidAddress, orElse: () => ActivityLogsData.empty()).address;
    final String latestValidAgent = data.lastWhere((row) => row.hasValidAgent, orElse: () => ActivityLogsData.empty()).agent;

    final sanitizedData = data.map((row) {
      return row.copyWith(
        ip: row.hasValidIp ? row.ip : latestValidIp,
        isp: row.hasValidIsp ? row.isp : latestValidIsp,
        address: row.hasValidAddress ? row.address : latestValidAddress,
        agent: row.hasValidAgent ? row.agent : latestValidAgent,
      );
    }).toList();

    return ActivityLogsResponse(
      data: sanitizedData,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      result: json['result'] ?? 0,
      status: json['status'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
    );
  }
}

class ActivityLogsData {
  final int id;
  final String loginTime;
  final String loginStatus;
  final String ip;
  final String isp;
  final String address;
  final String agent;
  final String userId;
  final String site;

  ActivityLogsData({
    required this.id,
    required this.loginTime,
    required this.loginStatus,
    required this.ip,
    required this.isp,
    required this.address,
    required this.agent,
    required this.userId,
    required this.site,
  });

  factory ActivityLogsData.fromJson(Map<String, dynamic> json) {
    return ActivityLogsData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      loginTime: json['loginTime']?.toString() ?? '',
      loginStatus: json['loginStatus']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      isp: json['isp']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      agent: json['agent']?.toString() ?? '',
      userId: json['UserId']?.toString() ?? '',
      site: (json['wlName']?.toString() ?? '').toUpperCase(),
    );
  }

  ActivityLogsData copyWith({int? id, String? loginTime, String? loginStatus, String? ip, String? isp, String? address, String? agent, String? userId, String? site}) {
    return ActivityLogsData(
      id: id ?? this.id,
      loginTime: loginTime ?? this.loginTime,
      loginStatus: loginStatus ?? this.loginStatus,
      ip: ip ?? this.ip,
      isp: isp ?? this.isp,
      address: address ?? this.address,
      agent: agent ?? this.agent,
      userId: userId ?? this.userId,
      site: site ?? this.site,
    );
  }

  static ActivityLogsData empty() {
    return ActivityLogsData(id: 0, loginTime: '', loginStatus: '', ip: '', isp: '', address: '', agent: '', userId: '', site: '');
  }

  bool get hasValidIp {
    final cleaned = ip.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidIsp {
    final cleaned = isp.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidAddress {
    final cleaned = address.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }

  bool get hasValidAgent {
    final cleaned = agent.trim();
    return cleaned.isNotEmpty && cleaned.toLowerCase() != 'blocked';
  }
}