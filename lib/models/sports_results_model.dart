
class SportResultsModel {
  String runnerName;
  String runnerId;
  String status;

  SportResultsModel({
    required this.runnerName,
    required this.runnerId,
    required this.status,
  });

  factory SportResultsModel.fromMap(Map<String, dynamic> map) {
    return SportResultsModel(
      runnerName: map['runnerName'],
      runnerId: map['runnerId'],
      status: map['status'],
    );
  }
}
