import 'package:flutter/material.dart';
import 'package:do_an_flutter/features/tasks/models/task_model.dart';

class LinearTheme {
  static const Color background = Color(0xFF08090A);
  static const Color surface = Color(0xFF121316);
  static const Color surfaceRaised = Color(0xFF18191D);
  static const Color surfaceBorder = Color(0xFF26282E);
  static const Color surfaceHighlight = Color(0xFF2E3138);

  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFF8A8F98);
  static const Color textMuted = Color(0xFF5E626E);

  static const Color accent = Color(0xFF5E6AD2);
  static const Color accentLight = Color(0xFF717DE8);

  static const Color priorityUrgent = Color(0xFFEB5757);
  static const Color priorityHigh = Color(0xFFF2994A);
  static const Color priorityMedium = Color(0xFFF2C94C);
  static const Color priorityLow = Color(0xFF56CCF2);
  static const Color priorityNone = Color(0xFF6E7681);

  static const Color statusBacklog = Color(0xFF8A8F98);
  static const Color statusTodo = Color(0xFFE2E8F0);
  static const Color statusInProgress = Color(0xFFF2C94C);
  static const Color statusDone = Color(0xFF7C3AED);
  static const Color statusCanceled = Color(0xFF6E7681);

  static String getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.canceled:
        return 'Canceled';
    }
  }

  static String getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.none:
        return 'No priority';
    }
  }

  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return priorityUrgent;
      case TaskPriority.high:
        return priorityHigh;
      case TaskPriority.medium:
        return priorityMedium;
      case TaskPriority.low:
        return priorityLow;
      case TaskPriority.none:
        return priorityNone;
    }
  }

  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return statusBacklog;
      case TaskStatus.todo:
        return statusTodo;
      case TaskStatus.inProgress:
        return statusInProgress;
      case TaskStatus.done:
        return statusDone;
      case TaskStatus.canceled:
        return statusCanceled;
    }
  }

  static Widget buildPriorityIcon(TaskPriority priority, {double size = 16}) {
    switch (priority) {
      case TaskPriority.urgent:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: priorityUrgent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.error_outline_rounded, color: priorityUrgent, size: size * 0.85),
        );
      case TaskPriority.high:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(size * 0.4, priorityHigh),
            const SizedBox(width: 2),
            _buildBar(size * 0.7, priorityHigh),
            const SizedBox(width: 2),
            _buildBar(size, priorityHigh),
          ],
        );
      case TaskPriority.medium:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(size * 0.4, priorityMedium),
            const SizedBox(width: 2),
            _buildBar(size * 0.7, priorityMedium),
            const SizedBox(width: 2),
            _buildBar(size, Colors.white24),
          ],
        );
      case TaskPriority.low:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(size * 0.4, priorityLow),
            const SizedBox(width: 2),
            _buildBar(size * 0.7, Colors.white24),
            const SizedBox(width: 2),
            _buildBar(size, Colors.white24),
          ],
        );
      case TaskPriority.none:
        return Text(
          '---',
          style: TextStyle(
            color: priorityNone,
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  static Widget _buildBar(double height, Color color) {
    return Container(
      width: 2.5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  static Widget buildStatusIcon(TaskStatus status, {double size = 16}) {
    switch (status) {
      case TaskStatus.backlog:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: statusBacklog,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: statusBacklog,
              ),
            ),
          ),
        );
      case TaskStatus.todo:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 1.6),
          ),
        );
      case TaskStatus.inProgress:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: 0.5,
            strokeWidth: 2.2,
            backgroundColor: statusInProgress.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(statusInProgress),
          ),
        );
      case TaskStatus.done:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: statusDone,
          ),
          child: Icon(Icons.check, color: Colors.white, size: size * 0.75),
        );
      case TaskStatus.canceled:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: statusCanceled, width: 1.5),
          ),
          child: Icon(Icons.close, color: statusCanceled, size: size * 0.7),
        );
    }
  }
}
