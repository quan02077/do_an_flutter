import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  static final TaskProvider _instance = TaskProvider._internal();
  factory TaskProvider() => _instance;

  final TaskService _taskService = TaskService();

  TaskProvider._internal() {
    _listenToTasksRealtime();
  }

  // Danh sách công việc lưu trong bộ nhớ
  final List<TaskModel> _tasks = [];

  // Bộ lọc hiện tại
  TaskStatus? _selectedStatusFilter;
  TaskPriority? _selectedPriorityFilter;
  String _searchQuery = '';
  DateTime _selectedCalendarDate = DateTime.now();

  // Getters
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  TaskStatus? get selectedStatusFilter => _selectedStatusFilter;
  TaskPriority? get selectedPriorityFilter => _selectedPriorityFilter;
  String get searchQuery => _searchQuery;
  DateTime get selectedCalendarDate => _selectedCalendarDate;

  // --- Các hàm cập nhật bộ lọc ---

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

  /// Danh sách công việc đã qua bộ lọc (tìm kiếm, trạng thái, ưu tiên)
  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      if (_selectedStatusFilter != null && task.status != _selectedStatusFilter) {
        return false;
      }
      if (_selectedPriorityFilter != null && task.priority != _selectedPriorityFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchId = task.id.toLowerCase().contains(query);
        final matchCode = (task.code ?? '').toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        if (!matchTitle && !matchId && !matchCode && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  /// Lấy danh sách công việc theo từng trạng thái (dùng cho Kanban & Chips)
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasks.where((t) => t.status == status).toList();
  }

  /// Lấy danh sách công việc theo ngày hạn chót (dùng cho Lịch)
  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }

  // --- Lắng nghe Real-time qua TaskService ---

  void _listenToTasksRealtime() {
    _taskService.getTasksStream().listen(
      (taskList) {
        _tasks.clear();
        _tasks.addAll(taskList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi Real-time Stream: $err');
      },
    );
  }

  // --- Các thao tác CRUD (gọi qua TaskService) ---

  Future<void> addTask(TaskModel task) async {
    await _taskService.createTask(task);
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    await _taskService.updateTask(updatedTask);
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    await _taskService.updateTaskStatus(taskId, newStatus);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }
}
