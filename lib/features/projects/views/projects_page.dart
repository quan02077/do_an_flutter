import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

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
                Icons.folder_outlined,
                size: 48,
                color: LinearTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dự án & Nhóm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản lý danh sách dự án và các thành viên nhóm',
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
