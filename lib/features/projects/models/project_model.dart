class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? ownerId;
  final String? ownerName;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.ownerId,
    this.ownerName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProjectModel.fromMap(Map<String, dynamic> m) => ProjectModel.fromJson(m);

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    DateTime projectCreatedAt = DateTime.now();
    if (json['created_at'] != null) {
      projectCreatedAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    String? resolvedOwnerName = json['owner_name'] as String?;
    if (resolvedOwnerName == null && json['users'] != null) {
      resolvedOwnerName = json['users']['full_name'] as String?;
    }

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String?,
      ownerName: resolvedOwnerName ?? 'Admin',
      createdAt: projectCreatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (ownerId != null) 'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
