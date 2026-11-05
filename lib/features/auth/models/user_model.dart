class UserModel {
  final String id;
  final String email;
  final String fullname;
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullname,
    this.avatar,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? email,
    String? fullname,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel.fromJson(m);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime userCreatedAt = DateTime.now();
    if (json['created_at'] != null) {
      userCreatedAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullname: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String?, // Đã bổ sung avatar
      createdAt: userCreatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullname, // Đã sửa thành full_name chuẩn database
      if (avatar != null) 'avatar': avatar,
      'created_at': createdAt.toIso8601String(), // Đã thêm toIso8601String
    };
  }
}
