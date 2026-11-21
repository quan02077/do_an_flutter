import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';
import '../../tasks/state/task_provider.dart';

class ProjectProvider extends ChangeNotifier {
  static final ProjectProvider _instance = ProjectProvider._internal();
  factory ProjectProvider() => _instance;

  final ProjectService _projectService = ProjectService();

  ProjectProvider._internal() {
    _listenToProjectsRealtime();
  }

  final List<ProjectModel> _projects = [];
  String _searchQuery = '';
  String? _selectedProjectId;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  String get searchQuery => _searchQuery;
  String? get selectedProjectId => _selectedProjectId;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectedProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  List<ProjectModel> get filteredProjects {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _projects;

    return _projects.where((project) {
      final matchName = project.name.toLowerCase().contains(query);
      final matchDesc = (project.description ?? '').toLowerCase().contains(query);
      return matchName || matchDesc;
    }).toList();
  }

  int getTaskCount(String projectId, String projectName) {
    final allTasks = TaskProvider().tasks;
    return allTasks.where((task) {
      return task.projectId == projectId || task.project == projectName;
    }).length;
  }

  int getCompleteTask(String projectId, String projectName) {
    final allTasks = TaskProvider().tasks;
    return allTasks.where((task) {
      final isProject = task.projectId == projectId || task.project == projectName;
      return isProject && task.status.name == 'done';
    }).length;
  }

  double getProgress(String projectId, String projectName) {
    final total = getTaskCount(projectId, projectName);
    if (total == 0) return 0.0;
    final completed = getCompleteTask(projectId, projectName);
    return completed / total;
  }

  void _listenToProjectsRealtime() {
    _projectService.getProjectsStream().listen(
      (projectList) {
        _projects.clear();
        _projects.addAll(projectList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi RealTime projects: $err');
      },
    );
  }

  /// Thêm dự án (Cập nhật ngay tức thì)
  Future<void> addProject(ProjectModel project) async {
    _projects.insert(0, project);
    notifyListeners();
    try {
      await _projectService.createdProject(project);
    } catch (e) {
      _projects.removeWhere((p) => p.id == project.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Sửa dự án (Cập nhật ngay tức thì)
  Future<void> updateProject(ProjectModel project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
    await _projectService.updateProject(project);
  }

  /// Xoá dự án (Xoá ngay tức thì)
  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
    await _projectService.deleteProject(projectId);
  }
}
