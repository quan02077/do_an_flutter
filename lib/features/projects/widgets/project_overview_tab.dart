import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/linear_theme.dart';
import '../../auth/state/auth_provider.dart';
import '../models/project_model.dart';
import '../state/project_provider.dart';
import '../views/project_members_page.dart';

class ProjectOverviewTab extends StatelessWidget {
  final ProjectModel project;
  final int totalTasks;
  final int doneTasks;
  final double progress;

  const ProjectOverviewTab({
    super.key,
    required this.project,
    required this.totalTasks,
    required this.doneTasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final description = (project.description ?? '').trim();
    final percent = (progress * 100).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description.isEmpty ? 'Chưa có mô tả cho dự án này.' : description,
            style: TextStyle(
              color: description.isEmpty ? LinearTheme.textMuted : LinearTheme.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: LinearTheme.surfaceBorder, height: 1),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.donut_large_rounded,
            label: 'Tiến độ',
            value: '$percent% ($doneTasks/$totalTasks việc)',
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Người tạo',
            value: project.ownerName ?? 'Admin',
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày tạo',
            value: DateFormat('dd/MM/yyyy').format(project.createdAt),
          ),
          const SizedBox(height: 24),
          const Divider(color: LinearTheme.surfaceBorder, height: 1),
          const SizedBox(height: 16),

          // Phần hiển thị thành viên nhóm tham gia
          Row(
            children: [
              const Text(
                'Thành viên nhóm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProjectMembersPage(project: project)),
                  );
                },
                child: const Text(
                  'Quản lý thành viên',
                  style: TextStyle(color: LinearTheme.accentLight, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: Listenable.merge([AuthProvider(), ProjectProvider()]),
            builder: (context, _) {
              final members = ProjectProvider().getUsersForProject(project.id);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: members.map((user) {
                  final name = user.fullname.isNotEmpty
                      ? user.fullname
                      : user.email.split('@').first;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: LinearTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: LinearTheme.accent,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: const TextStyle(color: LinearTheme.textPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: LinearTheme.textSecondary, size: 16),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
