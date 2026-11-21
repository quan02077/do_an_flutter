import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/state/task_provider.dart';
import '../../tasks/views/task_detail_bottom_sheet.dart';
import '../../tasks/widgets/linear_empty_state.dart';
import '../../tasks/widgets/task_item_tile.dart';
import '../models/project_model.dart';

class ProjectIssuesTab extends StatelessWidget {
  final ProjectModel project;
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;

  const ProjectIssuesTab({
    super.key,
    required this.project,
    this.statusFilter,
    this.priorityFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();
        final tasks = provider.tasks.where((task) {
          final isSameProject = task.projectId == project.id || task.project == project.name;
          final matchStatus = statusFilter == null || task.status == statusFilter;
          final matchPriority = priorityFilter == null || task.priority == priorityFilter;
          return isSameProject && matchStatus && matchPriority;
        }).toList();

        if (tasks.isEmpty) {
          return const LinearEmptyState(
            title: 'Chưa có công việc nào',
            subtitle: 'Bấm nút + ở góc trên để thêm công việc vào dự án này',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 30),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItemTile(
              task: task,
              onTap: () => TaskDetailBottomSheet.show(context, task: task),
              onStatusChanged: (newStatus) {
                provider.moveTask(task.id, newStatus);
              },
            );
          },
        );
      },
    );
  }
}

class ProjectFilterSheet extends StatelessWidget {
  final TaskStatus? currentStatus;
  final TaskPriority? currentPriority;
  final ValueChanged<TaskStatus?> onStatusChanged;
  final ValueChanged<TaskPriority?> onPriorityChanged;

  const ProjectFilterSheet({
    super.key,
    this.currentStatus,
    this.currentPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFF141519),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Text(
                  'Bộ lọc công việc',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    onStatusChanged(null);
                    onPriorityChanged(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Đặt lại', style: TextStyle(color: LinearTheme.accentLight, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Trạng thái', style: TextStyle(color: LinearTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((s) {
                final isSelected = currentStatus == s;
                return ChoiceChip(
                  label: Text(LinearTheme.getStatusLabel(s)),
                  selected: isSelected,
                  selectedColor: LinearTheme.surfaceHighlight,
                  backgroundColor: LinearTheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : LinearTheme.textSecondary,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? LinearTheme.accent : LinearTheme.surfaceBorder,
                  ),
                  onSelected: (_) {
                    onStatusChanged(isSelected ? null : s);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Mức độ ưu tiên', style: TextStyle(color: LinearTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((p) {
                final isSelected = currentPriority == p;
                return ChoiceChip(
                  label: Text(LinearTheme.getPriorityLabel(p)),
                  selected: isSelected,
                  selectedColor: LinearTheme.surfaceHighlight,
                  backgroundColor: LinearTheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : LinearTheme.textSecondary,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? LinearTheme.accent : LinearTheme.surfaceBorder,
                  ),
                  onSelected: (_) {
                    onPriorityChanged(isSelected ? null : p);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
