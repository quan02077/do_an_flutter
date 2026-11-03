
import 'package:flutter/material.dart';
import 'package:do_an_flutter/Settings/profile_page.dart';
import 'package:do_an_flutter/Auth/login_page.dart';
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
            'My Profile',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'View your profile',
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
            'Log in',
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
            'Notifications',
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
            'Appearance',
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
            'Privacy',
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
            'Log out',
            style: TextStyle(color: Colors.redAccent),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
