import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;

  final AuthService _authService = AuthService();

  AuthProvider._internal() {
    _currentUser = _authService.currentUser;
    _listenToAuthChanges();
    loadTeamMembers();
  }

  User? _currentUser;
  UserModel? _userProfile;
  final List<UserModel> _teamMembers = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  List<UserModel> get teamMembers => List.unmodifiable(allMembers);
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  /// Danh sách thành viên đồng nhất (gồm dữ liệu từ Supabase, user hiện tại và thành viên thêm tay)
  List<UserModel> get allMembers {
    final result = <UserModel>[..._teamMembers];
    if (_currentUser != null) {
      final exists = result.any(
        (m) => m.id == _currentUser!.id || m.email.toLowerCase() == email.toLowerCase(),
      );
      if (!exists) {
        result.insert(
          0,
          UserModel(
            id: _currentUser!.id,
            email: email,
            fullname: displayName,
          ),
        );
      }
    }
    return result;
  }

  /// Danh sách tên các thành viên để chọn nhanh khi giao việc (Task Assignee)
  List<String> get memberNames {
    final names = <String>{};
    for (final m in allMembers) {
      final name = m.fullname.isNotEmpty ? m.fullname : m.email.split('@').first;
      if (name.isNotEmpty) names.add(name);
    }
    if (names.isEmpty) {
      names.add('Nguyen Nhat Minh Quan');
    }
    return names.toList();
  }

  String get displayName {
    if (_userProfile?.fullname.isNotEmpty == true) return _userProfile!.fullname;
    final metaName = _currentUser?.userMetadata?['full_name'] as String?;
    if (metaName != null && metaName.isNotEmpty) return metaName;
    return _currentUser?.email?.split('@').first ?? 'Khách';
  }

  String get email => _currentUser?.email ?? 'Chưa đăng nhập';

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen(
      (data) async {
        _currentUser = data.session?.user;
        if (_currentUser != null) {
          await loadUserProfile();
          await loadTeamMembers();
        } else {
          _userProfile = null;
        }
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi Realtime Auth Stream: $err');
      },
    );
  }

  Future<void> loadUserProfile() async {
    if (_currentUser == null) return;
    final profile = await _authService.getUserProfile(_currentUser!.id);
    if (profile != null) {
      _userProfile = profile;
      notifyListeners();
    }
  }

  /// Tải danh sách thành viên nhóm từ bảng users trên Supabase (giữ lại thành viên thêm tay nếu có)
  Future<void> loadTeamMembers() async {
    final users = await _authService.getAllUsers();
    final localAdded = _teamMembers.where((m) => m.id.startsWith('mem-')).toList();
    if (users.isNotEmpty || localAdded.isNotEmpty) {
      _teamMembers.clear();
      _teamMembers.addAll(users);
      for (final local in localAdded) {
        final alreadyOnServer = _teamMembers.any(
          (u) => u.email.toLowerCase() == local.email.toLowerCase(),
        );
        if (!alreadyOnServer) {
          _teamMembers.add(local);
        }
      }
      notifyListeners();
    }
  }

  /// Thêm thành viên nhanh vào danh sách nhóm để phân công việc
  void addTeamMember({required String fullname, required String email}) {
    final newMember = UserModel(
      id: 'mem-${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      fullname: fullname.trim(),
    );
    _teamMembers.add(newMember);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _authService.signIn(email, password);
      _currentUser = res.user;
      await loadUserProfile();
      await loadTeamMembers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String fullname) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _authService.signUp(email, password, fullname);
      _currentUser = res.user;
      await loadTeamMembers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
