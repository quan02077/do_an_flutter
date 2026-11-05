import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../../core/theme/linear_theme.dart';
import '../widgets/linear_empty_state.dart';
import '../widgets/task_item_tile.dart';
import 'task_detail_bottom_sheet.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();
        final tasks = provider.filteredTasks;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm issue theo tên, mã (LIN-...), mô tả...',
                  hintStyle: const TextStyle(color: LinearTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: LinearTheme.textSecondary, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: LinearTheme.textSecondary, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: LinearTheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: LinearTheme.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: LinearTheme.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: LinearTheme.accent.withValues(alpha: 0.6)),
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  provider.setSearchQuery(val);
                },
              ),
            ),
            Container(
              height: 36,
              margin: const EdgeInsets.only(top: 4, bottom: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _buildStatusChip(
                    label: 'Tất cả (${provider.tasks.length})',
                    isSelected: provider.selectedStatusFilter == null,
                    onTap: () => provider.setStatusFilter(null),
                  ),
                  const SizedBox(width: 6),
                  ...TaskStatus.values.map((status) {
                    final count = provider.getTasksByStatus(status).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildStatusChip(
                        icon: LinearTheme.buildStatusIcon(status, size: 12),
                        label: '${LinearTheme.getStatusLabel(status)} ($count)',
                        isSelected: provider.selectedStatusFilter == status,
                        onTap: () => provider.setStatusFilter(
                          provider.selectedStatusFilter == status ? null : status,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? LinearEmptyState(
                      title: provider.activeTabFilter == 'Assigned'
                          ? 'No issues assigned to you'
                          : 'No issues in ${provider.activeTabFilter}',
                      subtitle: provider.searchQuery.isNotEmpty
                          ? 'Không tìm thấy kết quả phù hợp với từ khóa'
                          : 'Tất cả công việc đã được xử lý hoặc chưa được phân công',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 80),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: LinearTheme.priorityUrgent.withValues(alpha: 0.2),
                            child: const Icon(Icons.delete_outline, color: LinearTheme.priorityUrgent),
                          ),
                          onDismissed: (_) {
                            provider.deleteTask(task.id);
                          },
                          child: TaskItemTile(
                            task: task,
                            onTap: () {
                              TaskDetailBottomSheet.show(context, task: task);
                            },
                            onStatusChanged: (newStatus) {
                              provider.moveTask(task.id, newStatus);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip({
    Widget? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E313A) : const Color(0xFF141518),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? LinearTheme.accent : LinearTheme.surfaceBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : LinearTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
