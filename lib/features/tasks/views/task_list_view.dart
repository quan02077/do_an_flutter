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
            // Thanh công cụ: Tìm kiếm & Lọc trạng thái (Tối giản)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Ô tìm kiếm co giãn mượt mà
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm công việc...',
                          hintStyle: const TextStyle(color: LinearTheme.textMuted, fontSize: 12.5),
                          prefixIcon: const Icon(Icons.search, color: LinearTheme.textSecondary, size: 16),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.clear, color: LinearTheme.textSecondary, size: 15),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: LinearTheme.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: LinearTheme.accent, width: 1),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                          provider.setSearchQuery(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dải lọc trạng thái (Status Chips) cuộn ngang nhẹ nhàng
            Container(
              height: 28,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(
                    label: 'Tất cả (${provider.tasks.length})',
                    isSelected: provider.selectedStatusFilter == null,
                    onTap: () => provider.setStatusFilter(null),
                  ),
                  const SizedBox(width: 6),
                  ...TaskStatus.values.map((status) {
                    final count = provider.getTasksByStatus(status).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildFilterChip(
                        icon: LinearTheme.buildStatusIcon(status, size: 11),
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

            const SizedBox(height: 2),

            // Danh sách Task
            Expanded(
              child: tasks.isEmpty
                  ? LinearEmptyState(
                      title: 'Chưa có công việc nào',
                      subtitle: provider.searchQuery.isNotEmpty
                          ? 'Không tìm thấy kết quả phù hợp với từ khóa'
                          : 'Bấm dấu + ở góc dưới để tạo công việc đầu tiên',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 2, bottom: 90),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: LinearTheme.priorityUrgent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Xoá',
                                  style: TextStyle(
                                    color: LinearTheme.priorityUrgent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.delete_outline, color: LinearTheme.priorityUrgent, size: 18),
                              ],
                            ),
                          ),
                          onDismissed: (_) {
                            final deletedTask = task;
                            provider.deleteTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xoá ${deletedTask.displayCode}'),
                                backgroundColor: const Color(0xFF1E2025),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'Hoàn tác',
                                  textColor: LinearTheme.accentLight,
                                  onPressed: () {
                                    provider.addTask(deletedTask);
                                  },
                                ),
                              ),
                            );
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

  Widget _buildFilterChip({
    Widget? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? LinearTheme.surfaceHighlight : LinearTheme.surface,
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
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : LinearTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
