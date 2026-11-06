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
  final PageController _pageController = PageController(viewportFraction: 0.88);
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
            // Thanh chuyển cột trạng thái (gọn nhẹ)
            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _columns.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final status = _columns[index];
                  final isCurrent = _activeColumnIndex == index;
                  final count = provider.getTasksByStatus(status).length;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeColumnIndex = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent ? LinearTheme.surfaceHighlight : LinearTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent ? LinearTheme.accent : LinearTheme.surfaceBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearTheme.buildStatusIcon(status, size: 12),
                          const SizedBox(width: 5),
                          Text(
                            LinearTheme.getStatusLabel(status),
                            style: TextStyle(
                              color: isCurrent ? Colors.white : LinearTheme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$count',
                            style: TextStyle(
                              color: isCurrent ? Colors.white70 : LinearTheme.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 2),

            // Các cột Kanban (vuốt ngang bằng PageView)
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
              'Đã chuyển ${details.data.displayCode} sang ${LinearTheme.getStatusLabel(status)}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
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
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            color: isDropTarget ? const Color(0xFF1A1C22) : const Color(0xFF0F1013),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDropTarget ? LinearTheme.accent : LinearTheme.surfaceBorder,
              width: isDropTarget ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    LinearTheme.buildStatusIcon(status, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      LinearTheme.getStatusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: LinearTheme.surfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: const TextStyle(
                          color: LinearTheme.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách Task trong cột
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Kéo thả công việc vào đây',
                          style: TextStyle(
                            color: isDropTarget ? LinearTheme.accentLight : LinearTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 6, bottom: 90),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return LongPressDraggable<TaskModel>(
                            data: task,
                            delay: const Duration(milliseconds: 200),
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.82,
                                child: Opacity(
                                  opacity: 0.92,
                                  child: TaskItemTile(
                                    task: task,
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.2,
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
