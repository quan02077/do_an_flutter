import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/linear_theme.dart';
import '../../auth/state/auth_provider.dart';
import '../../auth/views/forgot_password_page.dart';
import '../../auth/views/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: AuthProvider(),
        builder: (context, _) {
          final auth = AuthProvider();
          final currentUser = auth.currentUser;

          if (currentUser == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Bạn chưa đăng nhập',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đăng nhập để xem thông tin hồ sơ và đồng bộ công việc của bạn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Đăng nhập ngay'),
                    ),
                  ],
                ),
              ),
            );
          }

          final displayName = auth.displayName;
          final email = currentUser.email ?? '';
          final createdAt = currentUser.createdAt;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: LinearTheme.accent,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined, color: Colors.white70),
                title: const Text('Ngày tham gia', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(createdAt)),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset_outlined, color: Colors.white70),
                title: const Text('Đặt lại mật khẩu', style: TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),

              // Nút Đăng xuất
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text(
                  'Đăng xuất tài khoản',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                onTap: () => _confirmSignOut(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
