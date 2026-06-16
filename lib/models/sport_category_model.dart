class EventTypeResponse {
  final int status;
  final List<EventType> data;
  final String message;

  EventTypeResponse({required this.status, required this.data, required this.message});

  factory EventTypeResponse.fromJson(Map<dynamic, dynamic> json) {
    return EventTypeResponse(status: json['status'], data: ((json['data'] as List).map((item) => EventType.fromJson(item)).toList()), message: json['message']);
  }
}

class EventType {
  final String id;
  final int count;
  final String name;
  final String icon;
  EventType({required this.id, required this.name, required this.count, required this.icon});
  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(id: json['id'] ?? '', count: json['count'] ?? 0, name: json['name'] ?? '', icon: json['icon'] ?? '');
  }
}
