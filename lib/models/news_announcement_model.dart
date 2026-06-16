class NewsAnnouncement {
  final String newsId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isDeleted;

  NewsAnnouncement({
    required this.isDeleted,
    required this.newsId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory NewsAnnouncement.fromJson(Map<String, dynamic> json) {
    return NewsAnnouncement(
      newsId: json['newsId']?.toString() ?? '',
      title: json["title"],
      description: json["description"],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  static List<NewsAnnouncement> listFromJson(List<dynamic>? jsonList) {
    return jsonList?.map((e) => NewsAnnouncement.fromJson(e)).toList() ?? [];
  }
}
