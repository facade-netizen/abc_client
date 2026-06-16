class SportsMTMModelList {
  SportsMTMModelList({required this.sportsMtmData});
  final List<SportsMTMModel> sportsMtmData;
  factory SportsMTMModelList.fromList(List<dynamic> sportsOrderMap) {
    return SportsMTMModelList(
      sportsMtmData: sportsOrderMap.map((mtm) => SportsMTMModel.fromMap(mtm)).toList(),
    );
  }
}

class SportsMTMModel {
  final double mtm;
  final String side;
  final int orderId;
  final double stake;
  final String eventName;
  final String runnerStatus;

  SportsMTMModel({
    required this.mtm,
    required this.side,
    required this.stake,
    required this.orderId,
    required this.eventName,
    required this.runnerStatus,
  });

  factory SportsMTMModel.fromMap(Map<String, dynamic> map) {
    return SportsMTMModel(
      mtm: map["MTM"],
      side: map['side'],
      stake: map['stake'],
      orderId: map['orderId'],
      eventName: map['eventName'],
      runnerStatus: map['runnerStatus']??"",
    );
  }
}
