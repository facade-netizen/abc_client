import 'event_with_type_model.dart';

class CompetitionResponse {
  final int status;
  final CompetitionData data;
  CompetitionResponse({required this.status, required this.data});
  factory CompetitionResponse.fromJson(Map<String, dynamic> json) {
    return CompetitionResponse(status: json['status'], data: CompetitionData.fromJson(json['data']));
  }
}

class CompetitionData {
  final String id;
  final String name;
  final List<Competition> competitions;
  CompetitionData({required this.id, required this.name, required this.competitions});
  factory CompetitionData.fromJson(Map<String, dynamic> json) {
    return CompetitionData(id: json['id'], name: json['name'], competitions: (json['competitions'] as List).map((e) => Competition.fromJson(e)).toList());
  }
}

class Competition {
  final String id;
  final String name;
  final List<Event> events;
  Competition({required this.id, required this.name, required this.events});
  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(id: json['id'], name: json['name'], events: (json['event'] as List).map((e) => Event.fromJson(e)).toList());
  }
}

