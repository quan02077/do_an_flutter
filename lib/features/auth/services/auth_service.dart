import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Đăng nhập bằng Email và Mật khẩu
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email.trim(), password: password);
      return response;
    } catch (e) {
      debugPrint('Lỗi Backend khi đăng nhập: $e');
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới và đồng bộ vào bảng users
  Future<AuthResponse> signUp(String email, String password, String fullname) async {
    try {
      final response = await _supabase.auth.signUp(email: email.trim(), password: password, data: {'full_name': fullname.trim()});

      // Đồng bộ thông tin người dùng vào bảng users để phục vụ Task và Project
      if (response.user != null) {
        try {
          await _supabase.from('users').upsert({
            'id': response.user!.id,
            'email': email.trim(),
            'full_name': fullname.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Lỗi Backend khi đồng bộ bảng users: $e');
        }
      }

      return response;
    } catch (e) {
      debugPrint('Lỗi Backend khi đăng ký: $e');
      rethrow;
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Lỗi Backend khi đăng xuất: $e');
      rethrow;
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      debugPrint('Lỗi Backend khi reset mật khẩu: $e');
      rethrow;
    }
  }

  /// Lấy thông tin chi tiết người dùng từ bảng users
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi Backend khi lấy profile user: $e');
      return null;
    }
  }
}
