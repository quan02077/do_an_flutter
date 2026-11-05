import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LinearTheme.background,
      child: Column(
        children: [
          const SizedBox(height: 12),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF252525),
              child: Icon(
                Icons.layers_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: LinearTheme.accent,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome to your workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(left: 16, top: 5),
              child: Text(
                'Chào mừng bạn đến với không gian làm việc nhóm · Vừa xong',
                style: TextStyle(
                  color: LinearTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
