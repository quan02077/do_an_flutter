import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
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
            // 1. Thanh nút chọn nhanh cột trên cùng
            _buildTopTabs(provider),

            // 2. Các cột Kanban vuốt ngang
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _columns.length,
                onPageChanged: (i) => setState(() => _activeColumnIndex = i),
                itemBuilder: (ctx, i) => _buildColumn(_columns[i], provider),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 1. Thanh tab nhỏ gọn trên cùng
  Widget _buildTopTabs(TaskProvider provider) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _columns.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final status = _columns[i];
          final isSelected = _activeColumnIndex == i;
          final count = provider.getTasksByStatus(status).length;

          return GestureDetector(
            onTap: () {
              setState(() => _activeColumnIndex = i);
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  LinearTheme.buildStatusIcon(status, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    LinearTheme.getStatusLabel(status),
                    style: TextStyle(
                      color: isSelected ? Colors.white : LinearTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : LinearTheme.textMuted,
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
    );
  }

  /// 2. Cột trạng thái (Vùng nhận diện thả DragTarget)
  Widget _buildColumn(TaskStatus status, TaskProvider provider) {
    final tasks = provider.getTasksByStatus(status);

    return DragTarget<TaskModel>(
      // Chỉ nhận khi kéo từ cột khác sang
      onWillAcceptWithDetails: (details) => details.data.status != status,

      // Khi thả tay: cập nhật trạng thái mới lên Supabase
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

      // Vẽ giao diện cột
      builder: (context, candidateData, _) {
        final isHovering = candidateData.isNotEmpty; // Đang có thẻ bay trên đầu cột

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            color: isHovering ? const Color(0xFF1A1C22) : const Color(0xFF0F1013),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? LinearTheme.accent : LinearTheme.surfaceBorder,
              width: isHovering ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              // Tiêu đề cột
              _buildColumnHeader(status, tasks.length),

              // Danh sách Task trong cột
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Kéo thả công việc vào đây',
                          style: TextStyle(
                            color: isHovering ? LinearTheme.accentLight : LinearTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 6, bottom: 90),
                        itemCount: tasks.length,
                        itemBuilder: (ctx, idx) => _buildDraggableTask(tasks[idx], provider),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tiêu đề của từng cột
  Widget _buildColumnHeader(TaskStatus status, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LinearTheme.surfaceBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          LinearTheme.buildStatusIcon(status, size: 14),
          const SizedBox(width: 8),
          Text(
            LinearTheme.getStatusLabel(status),
            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: LinearTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Thẻ Task có thể kéo thả (LongPressDraggable)
  Widget _buildDraggableTask(TaskModel task, TaskProvider provider) {
    return LongPressDraggable<TaskModel>(
      data: task,
      delay: const Duration(milliseconds: 200), // Nhấn giữ 200ms để nhấc lên

      // Hình ảnh bay theo ngón tay khi đang kéo
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.82,
          child: Opacity(
            opacity: 0.92,
            child: TaskItemTile(task: task, onTap: () {}),
          ),
        ),
      ),

      // Cái bóng mờ để lại ở vị trí cũ
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: TaskItemTile(task: task, onTap: () {}),
      ),

      // Thẻ bình thường lúc chưa kéo
      child: TaskItemTile(
        task: task,
        onTap: () => TaskDetailBottomSheet.show(context, task: task),
        onStatusChanged: (newStatus) => provider.moveTask(task.id, newStatus),
      ),
    );
  }
}
