enum TaskPriority {
  urgent,
  high,
  medium,
  low,
  none,
}

enum TaskStatus {
  backlog,
  todo,
  inProgress,
  done,
  canceled,
}

class TaskModel {
  final String id;
  String? code;
  String title;
  String description;
  TaskStatus status;
  TaskPriority priority;
  String? assignedTo;
  String? projectId;
  String assignee;
  String project;
  List<String> labels;
  DateTime? dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    this.code,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assignedTo,
    this.projectId,
    this.assignee = 'Nguyen Nhat Minh Quan',
    this.labels = const [],
    this.project = 'Lam do an flutter',
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayCode {
    if (code != null && code!.isNotEmpty) return code!;
    if (id.startsWith('LIN-') || id.startsWith('TASK-')) return id;
    if (id.length >= 6) return 'LIN-${id.substring(0, 4).toUpperCase()}';
    return id.isNotEmpty ? 'LIN-$id' : 'LIN-NEW';
  }

  TaskModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
    String? projectId,
    String? assignee,
    List<String>? labels,
    String? project,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      projectId: projectId ?? this.projectId,
      assignee: assignee ?? this.assignee,
      labels: labels ?? this.labels,
      project: project ?? this.project,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel.fromJson(map);

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    TaskStatus taskStatus = TaskStatus.todo;
    for (var s in TaskStatus.values) {
      if (s.name == json['status']) {
        taskStatus = s;
        break;
      }
    }

    TaskPriority taskPriority = TaskPriority.medium;
    for (var p in TaskPriority.values) {
      if (p.name == json['priority']) {
        taskPriority = p;
        break;
      }
    }

    DateTime? parsedDueDate;
    if (json['due_date'] != null) {
      parsedDueDate = DateTime.tryParse(json['due_date'].toString());
    }

    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    List<String> parsedLabels = [];
    if (json['labels'] != null) {
      if (json['labels'] is List) {
        parsedLabels = (json['labels'] as List).map((e) => e.toString()).toList();
      }
    }

    String userName = 'Nguyen Nhat Minh Quan';
    if (json['users'] != null && json['users'] is Map) {
      userName = json['users']['name'] ?? json['users']['email'] ?? userName;
    } else if (json['assignee'] != null) {
      userName = json['assignee'].toString();
    }

    String projName = 'Lam do an flutter';
    if (json['projects'] != null && json['projects'] is Map) {
      projName = json['projects']['name'] ?? projName;
    } else if (json['project'] != null) {
      projName = json['project'].toString();
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString(),
      title: json['title']?.toString() ?? 'Chưa có tiêu đề',
      description: json['description']?.toString() ?? '',
      status: taskStatus,
      priority: taskPriority,
      assignedTo: json['assigned_to']?.toString(),
      projectId: json['project_id']?.toString(),
      assignee: userName,
      labels: parsedLabels,
      project: projName,
      dueDate: parsedDueDate,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
    };

    if (code != null) map['code'] = code;
    if (assignedTo != null) map['assigned_to'] = assignedTo;
    if (projectId != null) map['project_id'] = projectId;
    if (dueDate != null) map['due_date'] = dueDate!.toIso8601String();
    if (labels.isNotEmpty) map['labels'] = labels;

    return map;
  }
}
