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
  }

  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

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

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _authService.signIn(email, password);
      _currentUser = res.user;
      await loadUserProfile();
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
