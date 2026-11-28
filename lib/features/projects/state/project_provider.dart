import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../auth/state/auth_provider.dart';
import '../../inbox/services/notify_service.dart';
import '../../tasks/state/task_provider.dart';
import '../models/project_member_model.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  static final ProjectProvider _instance = ProjectProvider._internal();
  factory ProjectProvider() => _instance;

  final ProjectService _projectService = ProjectService();

  ProjectProvider._internal() {
    _listenToProjectsRealtime();
    _listenToMembersRealtime();
    // Khi đổi tài khoản đăng nhập thì tự động lọc lại danh sách dự án
    AuthProvider().addListener(notifyListeners);
  }

  final List<ProjectModel> _allProjects = [];
  final List<ProjectMemberModel> _allMembers = [];
  String _searchQuery = '';
  String? _selectedProjectId;

  /// Chỉ lấy các dự án mà tài khoản hiện tại tạo hoặc là thành viên (qua bảng project_members)
  List<ProjectModel> get projects {
    final userId = AuthProvider().currentUser?.id;
    if (userId == null) return [];

    final visible = _allProjects.where((p) {
      final isOwner = p.ownerId == userId;
      final isMember = _allMembers.any((m) => m.projectId == p.id && m.userId == userId);
      return isOwner || isMember;
    }).toList();

    return List.unmodifiable(visible);
  }

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
    if (query.isEmpty) return projects;

    return projects.where((project) {
      final matchName = project.name.toLowerCase().contains(query);
      final matchDesc = (project.description ?? '').toLowerCase().contains(query);
      return matchName || matchDesc;
    }).toList();
  }

  /// Lấy danh sách bản ghi thành viên của 1 dự án cụ thể
  List<ProjectMemberModel> getMembersForProject(String projectId) {
    return _allMembers.where((m) => m.projectId == projectId).toList();
  }

  /// Lấy danh sách UserModel thực tế tham gia vào dự án này
  List<UserModel> getUsersForProject(String projectId) {
    final allUsers = AuthProvider().allMembers;
    final memberIds = <String>{};

    // Thêm ID chủ dự án (nếu có)
    final proj = _allProjects.where((p) => p.id == projectId).firstOrNull;
    if (proj?.ownerId != null && proj!.ownerId!.isNotEmpty) {
      memberIds.add(proj.ownerId!);
    }

    // Thêm ID các thành viên trong bảng project_members
    for (final m in _allMembers) {
      if (m.projectId == projectId) {
        memberIds.add(m.userId);
      }
    }

    return allUsers.where((u) => memberIds.contains(u.id)).toList();
  }

  int getTaskCount(String projectId, String projectName) {
    final allTasks = TaskProvider().tasks;
    return allTasks.where((task) {
      return task.projectId == projectId || (task.projectId == null && task.project == projectName);
    }).length;
  }

  int getCompleteTask(String projectId, String projectName) {
    final allTasks = TaskProvider().tasks;
    return allTasks.where((task) {
      final isProject = task.projectId == projectId || (task.projectId == null && task.project == projectName);
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
        _allProjects.clear();
        _allProjects.addAll(projectList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi RealTime projects: $err');
      },
    );
  }

  void _listenToMembersRealtime() {
    _projectService.getProjectMembersStream().listen(
      (memberList) {
        _allMembers.clear();
        _allMembers.addAll(memberList);

        // Nếu có thành viên mới chưa nằm trong cache users -> tải lại danh sách users
        final knownIds = AuthProvider().allMembers.map((u) => u.id).toSet();
        if (memberList.any((m) => !knownIds.contains(m.userId))) {
          AuthProvider().loadTeamMembers();
        }

        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi RealTime project_members: $err');
      },
    );
  }

  /// Thêm dự án mới (lưu server + lấy UUID thật + gắn creator vào project_members)
  Future<void> addProject(ProjectModel project) async {
    _allProjects.insert(0, project);
    notifyListeners();
    try {
      final created = await _projectService.createdProject(project);
      final idx = _allProjects.indexWhere((p) => p.id == project.id);
      if (idx != -1) {
        _allProjects[idx] = created;
      }
      if (created.ownerId != null &&
          !_allMembers.any((m) => m.projectId == created.id && m.userId == created.ownerId)) {
        _allMembers.add(
          ProjectMemberModel(
            id: 'local-${DateTime.now().millisecondsSinceEpoch}',
            projectId: created.id,
            userId: created.ownerId!,
            role: 'leader',
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      _allProjects.removeWhere((p) => p.id == project.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Mời thêm thành viên vào dự án (lưu Supabase project_members + gửi thông báo)
  Future<void> addMember({
    required String projectId,
    required UserModel user,
    required String projectName,
  }) async {
    final alreadyExists = _allMembers.any(
      (m) => m.projectId == projectId && m.userId == user.id,
    );
    if (alreadyExists) return;

    final tempMember = ProjectMemberModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      userId: user.id,
      role: 'member',
    );
    _allMembers.add(tempMember);
    notifyListeners();

    try {
      await _projectService.addMember(
        projectId: projectId,
        userId: user.id,
        role: 'member',
      );
      // Gửi thông báo realtime cho thành viên vừa được mời
      await NotifyService().createNotification(
        title: 'Bạn được mời vào dự án mới',
        body: '${AuthProvider().displayName} đã thêm bạn vào dự án "$projectName".',
        userId: user.id,
      );
    } catch (e) {
      _allMembers.removeWhere((m) => m.id == tempMember.id);
      notifyListeners();
      rethrow;
    }
  }

  /// Xoá thành viên khỏi dự án
  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    _allMembers.removeWhere((m) => m.projectId == projectId && m.userId == userId);
    notifyListeners();
    await _projectService.removeMember(projectId: projectId, userId: userId);
  }

  /// Sửa dự án
  Future<void> updateProject(ProjectModel project) async {
    final index = _allProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _allProjects[index] = project;
      notifyListeners();
    }
    await _projectService.updateProject(project);
  }

  /// Xoá dự án
  Future<void> deleteProject(String projectId) async {
    _allProjects.removeWhere((p) => p.id == projectId);
    _allMembers.removeWhere((m) => m.projectId == projectId);
    notifyListeners();
    await _projectService.deleteProject(projectId);
  }
}
