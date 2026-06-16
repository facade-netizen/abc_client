class DeclarationsModel {
  bool active;
  String separator;
  List<Documents> documents;

  DeclarationsModel({
    required this.active,
    required this.documents,
    required this.separator,
  });

  factory DeclarationsModel.fromMap(Map<String, dynamic> map) {
    return DeclarationsModel(
      active: map['active'],
      documents: (map['documents'] as List<dynamic>).map((doc) => Documents.fromMap(doc)).toList(),
      separator: map['separator'],
    );
  }
}

class Documents {
  String url;
  int sequence;
  String name;

  Documents({
    required this.name,
    required this.url,
    required this.sequence,
  });
  factory Documents.fromMap(Map<String, dynamic> map) {
    return Documents(
      name: map['name'],
      url: map['url'],
      sequence: map['sequence'],
    );
  }
}
