import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/notify_model.dart';
import '../services/notify_service.dart';
import '../state/notify_provider.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  void _showNotificationDetail(BuildContext context, NotifyModel notify) {
    if (!notify.isRead) {
      NotifyProvider().markAsRead(notify.id);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2025),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_outlined, color: LinearTheme.accentLight, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notify.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: LinearTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(notify.createdAt),
              style: const TextStyle(color: LinearTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Divider(color: LinearTheme.surfaceBorder, height: 1),
            const SizedBox(height: 16),
            Text(
              notify.body.isNotEmpty ? notify.body : 'Không có nội dung chi tiết.',
              style: const TextStyle(color: LinearTheme.textPrimary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotifyProvider(),
      builder: (context, _) {
        final notifyProvider = NotifyProvider();
        final isEnabled = notifyProvider.isNotificationEnabled;

        return Container(
          color: LinearTheme.background,
          child: Column(
            children: [
              // Thanh cảnh báo tinh tế khi người dùng đã TẮT thông báo trong Cài đặt
              if (!isEnabled)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2025),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_off_outlined, color: Colors.orangeAccent, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Thông báo đang tắt trong Cài đặt',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () => notifyProvider.setNotificationEnabled(true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 30),
                        ),
                        child: const Text(
                          'Bật lại',
                          style: TextStyle(color: LinearTheme.accentLight, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // Danh sách thông báo
              Expanded(
                child: StreamBuilder<List<NotifyModel>>(
                  stream: NotifyService().getNotificationsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: LinearTheme.accent),
                        ),
                      );
                    }

                    final notifications = snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: LinearTheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                                ),
                                child: const Icon(Icons.inbox_outlined, size: 30, color: LinearTheme.textMuted),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Hộp thư thông báo trống',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tất cả thông báo về công việc, tiến độ dự án hoặc cập nhật nhóm sẽ hiển thị tại đây.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: LinearTheme.textSecondary, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: LinearTheme.surfaceBorder,
                        height: 1,
                        indent: 64,
                      ),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: LinearTheme.priorityUrgent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            notifyProvider.deleteNotification(item.id);
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: LinearTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                                  ),
                                  child: Icon(
                                    item.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                                    color: item.isRead ? LinearTheme.textMuted : LinearTheme.accentLight,
                                    size: 20,
                                  ),
                                ),
                                if (!item.isRead)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: LinearTheme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item.isRead ? Colors.white70 : Colors.white,
                                fontSize: 14,
                                fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.body} · ${DateFormat('dd/MM HH:mm').format(item.createdAt)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 12),
                            ),
                            onTap: () => _showNotificationDetail(context, item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
