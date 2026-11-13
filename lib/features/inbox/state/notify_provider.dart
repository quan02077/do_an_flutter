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

  /// Đếm tổng số thông báo
  int get notifyCount => _notifications.length;

  /// Đếm số thông báo CHƯA ĐỌC
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool _isNotificationEnabled = true;
  bool get isNotificationEnabled => _isNotificationEnabled;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setNotificationEnabled(bool value){
    _isNotificationEnabled = value;
    notifyListeners();
  }

  /// Danh sách thông báo sau khi lọc theo từ khóa tìm kiếm
  List<NotifyModel> get filteredNotifications {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _notifications;

    return _notifications.where((notify) {
      final matchTitle = notify.title.toLowerCase().contains(query);
      final matchBody = notify.body.toLowerCase().contains(query);
      return matchTitle || matchBody;
    }).toList();
  }

  /// Lắng nghe dữ liệu real-time từ Supabase
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

  /// Đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _notifyService.markAsRead(notificationId);
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    await _notifyService.markAllAsRead();
  }

  /// Xoá thông báo
  Future<void> deleteNotification(String notificationId) async {
    await _notifyService.deleteNotification(notificationId);
  }
}