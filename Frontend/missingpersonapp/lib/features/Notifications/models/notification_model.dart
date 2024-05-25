class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String caseID;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.caseID,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      caseID: json['caseID'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
