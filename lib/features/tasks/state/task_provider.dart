import 'package:flutter/material.dart';
import '../../auth/state/auth_provider.dart';
import '../../projects/state/project_provider.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  static final TaskProvider _instance = TaskProvider._internal();
  factory TaskProvider() => _instance;

  final TaskService _taskService = TaskService();

  TaskProvider._internal() {
    _listenToTasksRealtime();
    // Khi đổi tài khoản hoặc danh sách dự án tham gia thay đổi -> tự động lọc lại công việc
    AuthProvider().addListener(notifyListeners);
    ProjectProvider().addListener(notifyListeners);
  }

  final List<TaskModel> _allTasks = [];

  TaskStatus? _selectedStatusFilter;
  TaskPriority? _selectedPriorityFilter;
  String _searchQuery = '';
  DateTime _selectedCalendarDate = DateTime.now();

  /// Chỉ hiển thị các công việc giao cho user hiện tại HOẶC thuộc dự án mà user đang tham gia
  List<TaskModel> get tasks {
    final userId = AuthProvider().currentUser?.id;
    if (userId == null) return [];

    final myProjectIds = ProjectProvider().projects.map((p) => p.id).toSet();

    final visible = _allTasks.where((task) {
      final isAssignedToMe = task.assignedTo == userId;
      final isInMyProject = task.projectId != null && myProjectIds.contains(task.projectId);
      return isAssignedToMe || isInMyProject;
    }).toList();

    return List.unmodifiable(visible);
  }

  TaskStatus? get selectedStatusFilter => _selectedStatusFilter;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  String get searchQuery => _searchQuery;
  DateTime get selectedCalendarDate => _selectedCalendarDate;

  void setStatusFilter(TaskStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCalendarDate(DateTime date) {
    _selectedCalendarDate = date;
    notifyListeners();
  }

  List<TaskModel> get filteredTasks {
    final query = _searchQuery.trim().toLowerCase();

    return tasks.where((task) {
      final matchStatus = _selectedStatusFilter == null || task.status == _selectedStatusFilter;
      final matchPriority = _selectedPriorityFilter == null || task.priority == _selectedPriorityFilter;
      final matchSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.displayCode.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      return matchStatus && matchPriority && matchSearch;
    }).toList();
  }

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return tasks.where((task) => task.status == status).toList();
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  void _listenToTasksRealtime() {
    _taskService.getTasksStream().listen(
      (taskList) {
        _allTasks.clear();
        _allTasks.addAll(taskList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi Realtime Stream: $err');
      },
    );
  }

  /// Thêm công việc (Cập nhật tức thì + nhận UUID thật từ Supabase)
  Future<void> addTask(TaskModel task) async {
    _allTasks.insert(0, task);
    notifyListeners();
    try {
      final created = await _taskService.createTask(task);
      final idx = _allTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _allTasks[idx] = created;
        notifyListeners();
      }
    } catch (e) {
      _allTasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Sửa công việc (Cập nhật tức thì)
  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      notifyListeners();
    }
    await _taskService.updateTask(updatedTask);
  }

  /// Kéo thả đổi trạng thái công việc (Cập nhật tức thì)
  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final index = _allTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _allTasks[index] = _allTasks[index].copyWith(status: newStatus);
      notifyListeners();
    }
    await _taskService.updateTaskStatus(taskId, newStatus);
  }

  /// Xoá công việc (Xoá tức thì khỏi màn hình)
  Future<void> deleteTask(String taskId) async {
    _allTasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    await _taskService.deleteTask(taskId);
  }
}
