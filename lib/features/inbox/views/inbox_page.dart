import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: LinearTheme.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: LinearTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hộp thư thông báo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tất cả thông báo và cập nhật mới sẽ hiển thị tại đây',
              style: TextStyle(
                color: LinearTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
