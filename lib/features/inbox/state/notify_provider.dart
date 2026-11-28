import 'package:flutter/material.dart';
import '../../auth/state/auth_provider.dart';
import '../models/notify_model.dart';
import '../services/notify_service.dart';

class NotifyProvider extends ChangeNotifier {
  static final NotifyProvider _instance = NotifyProvider._internal();
  factory NotifyProvider() => _instance;

  final NotifyService _notifyService = NotifyService();

  NotifyProvider._internal() {
    _listenToNotificationRealTime();
    AuthProvider().addListener(notifyListeners);
  }

  final List<NotifyModel> _allNotifications = [];
  String _searchQuery = '';

  /// Chỉ lấy các thông báo dành riêng cho user đang đăng nhập (hoặc thông báo chung userId == null)
  List<NotifyModel> get notifications {
    final userId = AuthProvider().currentUser?.id;
    if (userId == null) return [];

    final visible = _allNotifications
        .where((n) => n.userId == null || n.userId == userId)
        .toList();
    return List.unmodifiable(visible);
  }

  String get searchQuery => _searchQuery;

  int get notifyCount => notifications.length;
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  bool _isNotificationEnabled = true;
  bool get isNotificationEnabled => _isNotificationEnabled;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setNotificationEnabled(bool value) {
    _isNotificationEnabled = value;
    notifyListeners();
  }

  List<NotifyModel> get filteredNotifications {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return notifications;

    return notifications.where((notify) {
      final matchTitle = notify.title.toLowerCase().contains(query);
      final matchBody = notify.body.toLowerCase().contains(query);
      return matchTitle || matchBody;
    }).toList();
  }

  void _listenToNotificationRealTime() {
    _notifyService.getNotificationsStream().listen(
      (notificationList) {
        _allNotifications.clear();
        _allNotifications.addAll(notificationList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi RealTime notifications: $err');
      },
    );
  }

  /// Đánh dấu đã đọc (Cập nhật ngay tức thì)
  Future<void> markAsRead(String notificationId) async {
    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
      notifyListeners();
    }
    await _notifyService.markAsRead(notificationId);
  }

  /// Đánh dấu tất cả thông báo của user hiện tại là đã đọc
  Future<void> markAllAsRead() async {
    final myUnread = notifications.where((n) => !n.isRead).toList();
    for (final item in myUnread) {
      final idx = _allNotifications.indexWhere((n) => n.id == item.id);
      if (idx != -1) {
        _allNotifications[idx] = _allNotifications[idx].copyWith(isRead: true);
      }
    }
    notifyListeners();
    for (final item in myUnread) {
      await _notifyService.markAsRead(item.id);
    }
  }

  /// Xoá thông báo (Cập nhật ngay tức thì)
  Future<void> deleteNotification(String notificationId) async {
    _allNotifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    await _notifyService.deleteNotification(notificationId);
  }
}
