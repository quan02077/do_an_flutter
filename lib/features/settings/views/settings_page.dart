import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';
import 'package:do_an_flutter/features/auth/state/auth_provider.dart';
import 'package:do_an_flutter/features/auth/views/login_page.dart';
import 'package:do_an_flutter/features/settings/views/profile_page.dart';

import '../../inbox/state/notify_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2025),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xác nhận đăng xuất', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
          style: TextStyle(color: LinearTheme.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: LinearTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthProvider().signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất thành công'),
                    backgroundColor: Colors.white12,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LinearTheme.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthProvider(), NotifyProvider()]),
      builder: (context, _) {
        final auth = AuthProvider();
        final isLoggedIn = auth.isAuthenticated;
        final displayName = auth.displayName;
        final email = auth.email;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Thẻ Profile Header
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: isLoggedIn ? LinearTheme.accent : const Color(0xFF2A2B30),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Text(
                isLoggedIn ? displayName : 'Khách',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                if (isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
            ),

            const Divider(color: Colors.white12, height: 1),

            // Nút Đăng nhập (chỉ hiện khi chưa đăng nhập)
            if (!isLoggedIn) ...[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.login_rounded, color: LinearTheme.accentLight),
                title: const Text(
                  'Đăng nhập tài khoản',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Đồng bộ dữ liệu dự án và công việc',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              const Divider(color: Colors.white12, height: 1),
            ],

            // Mục Thông báo với nút gạt (Switch)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(
                NotifyProvider().isNotificationEnabled
                    ? Icons.notifications_outlined
                    : Icons.notifications_off_outlined,
                color: NotifyProvider().isNotificationEnabled ? Colors.white : Colors.grey,
              ),
              title: const Text('Thông báo', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                NotifyProvider().isNotificationEnabled ? 'Đang nhận thông báo' : 'Đã tạm dừng thông báo',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: Switch.adaptive(
                value: NotifyProvider().isNotificationEnabled,
                activeColor: LinearTheme.accent,
                activeTrackColor: LinearTheme.accent.withValues(alpha: 0.4),
                onChanged: (bool value) {
                  // 1. Cập nhật vào NotifyProvider
                  NotifyProvider().setNotificationEnabled(value);

                  // 2. Hiện thông báo ngắn cho người dùng
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Đã bật nhận thông báo' : 'Đã tạm dừng thông báo'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFFfcfcfc),
                    ),
                  );
                },
              ),
            ),

            const ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(Icons.dark_mode_outlined, color: Colors.white),
              title: Text('Giao diện', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),

            // Nút Đăng xuất (chỉ hiện khi đã đăng nhập)
            if (isLoggedIn) ...[
              const Divider(color: Colors.white12, height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ],
        );
      },
    );
  }
}
