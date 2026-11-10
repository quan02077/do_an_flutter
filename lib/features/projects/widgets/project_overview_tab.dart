import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/project_model.dart';

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
