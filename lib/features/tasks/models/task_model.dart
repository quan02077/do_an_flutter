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
    if (id.startsWith('TASK-')) return id;
    if (id.length >= 6) return 'TASK-${id.substring(0, 4).toUpperCase()}';
    return id.isNotEmpty ? 'TASK-$id' : 'TASK-NEW';
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

    List<String> labelList = [];
    if (json['labels'] != null) {
      labelList = List<String>.from(json['labels']);
    }

    DateTime? taskDueDate;
    if (json['due_date'] != null) {
      taskDueDate = DateTime.tryParse(json['due_date'].toString());
    }

    DateTime taskCreatedAt = DateTime.now();
    if (json['created_at'] != null) {
      taskCreatedAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    String? resolvedAssignee = json['assignee_name'] as String?;
    if (resolvedAssignee == null && json['users'] != null) {
      resolvedAssignee = json['users']['full_name'] as String?;
    }

    String? resolvedProject = json['project_name'] as String?;
    if (resolvedProject == null && json['projects'] != null) {
      resolvedProject = json['projects']['name'] as String?;
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: taskStatus,
      priority: taskPriority,
      assignedTo: json['assigned_to'] as String?,
      projectId: json['project_id'] as String?,
      assignee: resolvedAssignee ?? 'Nguyen Nhat Minh Quan',
      project: resolvedProject ?? 'Lam do an flutter',
      labels: labelList,
      dueDate: taskDueDate,
      createdAt: taskCreatedAt,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'labels': labels,
      if (code != null) 'code': code,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (projectId != null) 'project_id': projectId,
      if (dueDate != null) 'due_date': dueDate?.toIso8601String(),
    };
  }
}