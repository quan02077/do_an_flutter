import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../../../core/theme/linear_theme.dart';

class TaskItemTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus>? onStatusChanged;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1))) &&
        !isDone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: LinearTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (onStatusChanged != null) {
                      final next = isDone ? TaskStatus.todo : TaskStatus.done;
                      onStatusChanged!(next);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: LinearTheme.buildStatusIcon(task.status, size: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: LinearTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.id,
                    style: const TextStyle(
                      color: LinearTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: LinearTheme.buildPriorityIcon(task.priority, size: 14),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDone ? LinearTheme.textMuted : LinearTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: LinearTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LinearTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Row(
                children: [
                  ...task.labels.map(
                    (lbl) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: LinearTheme.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: LinearTheme.surfaceBorder, width: 0.5),
                      ),
                      child: Text(
                        '#$lbl',
                        style: const TextStyle(
                          color: LinearTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isOverdue ? LinearTheme.priorityUrgent : LinearTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM').format(task.dueDate!),
                      style: TextStyle(
                        color: isOverdue ? LinearTheme.priorityUrgent : LinearTheme.textMuted,
                        fontSize: 11,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFE5855D), Color(0xFFF2994A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        task.assignee.isNotEmpty ? task.assignee[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
