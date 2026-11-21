import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int totalTasks;
  final int doneTasks;
  final double progress;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.totalTasks,
    required this.doneTasks,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.04),
      highlightColor: Colors.white.withValues(alpha: 0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.view_in_ar_rounded,
                  color: Color(0xFFEB5757),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                  child: const Icon(
                    Icons.donut_large_rounded,
                    color: LinearTheme.textMuted,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: LinearTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          value: totalTasks == 0 ? 0.0 : progress,
                          strokeWidth: 1.8,
                          backgroundColor: const Color(0xFF3A3D46),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF2994A)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: LinearTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalTasks > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$doneTasks/$totalTasks việc',
                    style: const TextStyle(
                      color: LinearTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
