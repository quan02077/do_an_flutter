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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
      child: Material(
        color: LinearTheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.02),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: LinearTheme.surfaceBorder.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Icon trạng thái (bấm vào để chuyển nhanh Done / Todo)
                GestureDetector(
                  onTap: () {
                    if (onStatusChanged != null) {
                      final next = isDone ? TaskStatus.todo : TaskStatus.done;
                      onStatusChanged!(next);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: LinearTheme.buildStatusIcon(task.status, size: 17),
                  ),
                ),

                // 2. Nội dung chính: Mã task ngắn gọn + Icon priority + Tiêu đề
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dùng displayCode (LIN-98A6) thay vì full UUID 36 ký tự
                          Text(
                            task.displayCode,
                            style: const TextStyle(
                              color: LinearTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Icon mức độ ưu tiên
                          if (task.priority != TaskPriority.none)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: LinearTheme.buildPriorityIcon(task.priority, size: 12),
                            ),
                          // Labels nhỏ gọn (tối đa 2 nhãn)
                          if (task.labels.isNotEmpty)
                            Flexible(
                              child: Text(
                                task.labels.take(2).map((l) => '#$l').join(' '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF707684),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDone ? LinearTheme.textMuted : LinearTheme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          decorationColor: LinearTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // 3. Deadline hạn chót (nếu có)
                if (task.dueDate != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? LinearTheme.priorityUrgent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: isOverdue ? LinearTheme.priorityUrgent : LinearTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('dd/MM').format(task.dueDate!),
                          style: TextStyle(
                            color: isOverdue ? LinearTheme.priorityUrgent : LinearTheme.textMuted,
                            fontSize: 10,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // 4. Avatar người phụ trách (gọn nhỏ 20px)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF5E6AD2), Color(0xFF717DE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      task.assignee.isNotEmpty ? task.assignee[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
