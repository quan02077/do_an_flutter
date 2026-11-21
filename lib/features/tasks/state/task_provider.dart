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

  final List<TaskModel> _tasks = [];

  TaskStatus? _selectedStatusFilter;
  TaskPriority? _selectedPriorityFilter;
  String _searchQuery = '';
  DateTime _selectedCalendarDate = DateTime.now();

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
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

    return _tasks.where((task) {
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
    return _tasks.where((task) => task.status == status).toList();
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  void _listenToTasksRealtime() {
    _taskService.getTasksStream().listen(
      (taskList) {
        _tasks.clear();
        _tasks.addAll(taskList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi Realtime Stream: $err');
      },
    );
  }

  /// Thêm công việc (Cập nhật lạc quan ngay tức thì trên UI + Lưu vào Supabase)
  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
    notifyListeners(); // UI vẽ lại ngay lập tức!
    try {
      await _taskService.createTask(task);
    } catch (e) {
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Sửa công việc (Cập nhật tức thì)
  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners(); // UI cập nhật ngay lập tức!
    }
    await _taskService.updateTask(updatedTask);
  }

  /// Kéo thả đổi trạng thái công việc (Cập nhật tức thì 0 giây)
  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
      notifyListeners(); // Thẻ nhảy sang cột mới ngay lập tức!
    }
    await _taskService.updateTaskStatus(taskId, newStatus);
  }

  /// Xoá công việc (Xoá tức thì khỏi màn hình)
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners(); // Biến mất khỏi danh sách ngay!
    await _taskService.deleteTask(taskId);
  }
}
