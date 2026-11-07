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
