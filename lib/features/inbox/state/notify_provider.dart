import 'package:flutter/material.dart';
import '../models/notify_model.dart';
import '../services/notify_service.dart';

class NotifyProvider extends ChangeNotifier {
  static final NotifyProvider _instance = NotifyProvider._internal();
  factory NotifyProvider() => _instance;

  final NotifyService _notifyService = NotifyService();

  NotifyProvider._internal() {
    _listenToNotificationRealTime();
  }

  final List<NotifyModel> _notifications = [];
  String _searchQuery = '';

  List<NotifyModel> get notifications => List.unmodifiable(_notifications);
  String get searchQuery => _searchQuery;

  int get notifyCount => _notifications.length;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

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
    if (query.isEmpty) return _notifications;

    return _notifications.where((notify) {
      final matchTitle = notify.title.toLowerCase().contains(query);
      final matchBody = notify.body.toLowerCase().contains(query);
      return matchTitle || matchBody;
    }).toList();
  }

  void _listenToNotificationRealTime() {
    _notifyService.getNotificationsStream().listen(
      (notificationList) {
        _notifications.clear();
        _notifications.addAll(notificationList);
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Lỗi RealTime notifications: $err');
      },
    );
  }

  /// Đánh dấu đã đọc (Cập nhật ngay tức thì)
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
    await _notifyService.markAsRead(notificationId);
  }

  /// Đánh dấu tất cả đã đọc (Cập nhật ngay tức thì)
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    await _notifyService.markAllAsRead();
  }

  /// Xoá thông báo (Cập nhật ngay tức thì)
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    await _notifyService.deleteNotification(notificationId);
  }
}
