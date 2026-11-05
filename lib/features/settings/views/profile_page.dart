
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 45),
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              'User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'user@example.com',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 30),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.person_outline, color: Colors.white),
            title: Text(
              'Personal information',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.white),
            title: Text(
              'Change password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
