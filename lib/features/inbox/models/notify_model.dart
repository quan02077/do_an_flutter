class NotifyModel {
  final String id;
  final String? userId;
  final String? userName;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotifyModel({
    required this.id,
    this.userId,
    this.userName = 'Nguyen Nhat Minh Quan',
    required this.title,
    required this.body,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotifyModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotifyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotifyModel.fromMap(Map<String, dynamic> m) => NotifyModel.fromJson(m);

  factory NotifyModel.fromJson(Map<String, dynamic> json) {
    DateTime notifyCreatedAt = DateTime.now();
    if (json['created_at'] != null) {
      notifyCreatedAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    String? resolvedUserName = json['user_name'] as String?;
    if (resolvedUserName == null && json['users'] != null) {
      resolvedUserName = json['users']['full_name'] as String?;
    }

    return NotifyModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String?,
      userName: resolvedUserName ?? 'Nguyen Nhat Minh Quan',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: notifyCreatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'title': title,
      'body': body,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
