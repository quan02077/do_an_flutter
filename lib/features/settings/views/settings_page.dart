import 'package:flutter/material.dart';
import 'package:do_an_flutter/features/settings/views/profile_page.dart';
import 'package:do_an_flutter/features/auth/views/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text(
            'Hồ sơ cá nhân',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'Xem và chỉnh sửa thông tin',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
        ),

        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(
            Icons.login,
            color: Colors.white,
          ),
          title: const Text(
            'Đăng nhập',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
        ),

        const ListTile(
          leading: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          title: Text(
            'Thông báo',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),

        const ListTile(
          leading: Icon(
            Icons.dark_mode_outlined,
            color: Colors.white,
          ),
          title: Text(
            'Giao diện',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),

        const ListTile(
          leading: Icon(
            Icons.lock_outline,
            color: Colors.white,
          ),
          title: Text(
            'Bảo mật & Quyền riêng tư',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),

        const Divider(color: Colors.white24),

        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.redAccent),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
