import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../../core/theme/linear_theme.dart';
import '../widgets/task_item_tile.dart';
import 'task_detail_bottom_sheet.dart';

class KanbanBoardView extends StatefulWidget {
  const KanbanBoardView({super.key});

  @override
  State<KanbanBoardView> createState() => _KanbanBoardViewState();
}

class _KanbanBoardViewState extends State<KanbanBoardView> {
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _activeColumnIndex = 0;

  final List<TaskStatus> _columns = [
    TaskStatus.backlog,
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.done,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();

        return Column(
          children: [
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _columns.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final status = _columns[index];
                  final isCurrent = _activeColumnIndex == index;
                  final count = provider.getTasksByStatus(status).length;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeColumnIndex = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF26282F) : LinearTheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCurrent ? LinearTheme.accent : LinearTheme.surfaceBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearTheme.buildStatusIcon(status, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            LinearTheme.getStatusLabel(status),
                            style: TextStyle(
                              color: isCurrent ? Colors.white : LinearTheme.textSecondary,
                              fontSize: 12.5,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isCurrent ? LinearTheme.accent.withValues(alpha: 0.3) : const Color(0xFF202227),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : LinearTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _columns.length,
                onPageChanged: (idx) {
                  setState(() => _activeColumnIndex = idx);
                },
                itemBuilder: (context, colIndex) {
                  final status = _columns[colIndex];
                  final tasksInCol = provider.getTasksByStatus(status);

                  return _buildKanbanColumn(status, tasksInCol, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKanbanColumn(TaskStatus status, List<TaskModel> tasks, TaskProvider provider) {
    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        provider.moveTask(details.data.id, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã chuyển "${details.data.id}" sang ${LinearTheme.getStatusLabel(status)}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1E2025),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isDropTarget ? const Color(0xFF1C1E26) : const Color(0xFF101115),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDropTarget ? LinearTheme.accent : LinearTheme.surfaceBorder,
              width: isDropTarget ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    LinearTheme.buildStatusIcon(status, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      LinearTheme.getStatusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22242B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: const TextStyle(
                          color: LinearTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Kéo thả task vào đây\nhoặc bấm + để tạo mới',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDropTarget ? LinearTheme.accentLight : LinearTheme.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return LongPressDraggable<TaskModel>(
                            data: task,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.78,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: TaskItemTile(
                                    task: task,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: TaskItemTile(
                                task: task,
                                onTap: () {},
                              ),
                            ),
                            child: TaskItemTile(
                              task: task,
                              onTap: () => TaskDetailBottomSheet.show(context, task: task),
                              onStatusChanged: (newStatus) {
                                provider.moveTask(task.id, newStatus);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
