import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/notify_model.dart';

class NotifyService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Lắng nghe dữ liệu Thông báo Real-time từ bảng notifications
  Stream<List<NotifyModel>> getNotificationsStream() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((dataList) => dataList.map((json) => NotifyModel.fromJson(json)).toList());
  }

  /// Đánh dấu một thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Lỗi đánh dấu đã đọc: $e');
      rethrow;
    }
  }

  /// Đánh dấu tất cả thông báo là đã đọc
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Lỗi đánh dấu tất cả đã đọc: $e');
      rethrow;
    }
  }

  /// Xoá thông báo theo ID
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Lỗi xoá thông báo: $e');
      rethrow;
    }
  }

  /// Tạo thông báo mới (ví dụ khi được giao việc hoặc có dự án mới)
  Future<void> createNotification({required String title, required String body, String? userId}) async {
    try {
      await _supabase.from('notifications').insert({
        'title': title,
        'body': body,
        if (userId != null) 'user_id': userId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Lỗi tạo thông báo: $e');
      rethrow;
    }
  }
}
