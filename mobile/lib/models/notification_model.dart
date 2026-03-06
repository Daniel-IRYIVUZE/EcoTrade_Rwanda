class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'title': title, 'body': body,
    'type': type, 'data': data, 'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    title: json['title'],
    body: json['body'],
    type: json['type'],
    data: json['data'],
    isRead: json['is_read'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );
}
