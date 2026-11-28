class ProjectMemberModel {
  final String id;
  final String projectId;
  final String userId;
  final String role; // 'leader' hoặc 'member'
  final DateTime joinedAt;

  ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    this.role = 'member',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['joined_at'] != null) {
      parsedDate = DateTime.tryParse(json['joined_at'].toString()) ?? DateTime.now();
    }

    return ProjectMemberModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      joinedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'user_id': userId,
      'role': role,
    };
  }
}
