import 'package:flutter/material.dart';
import 'views/calendar_view.dart';
import 'views/dashboard_view.dart';
import 'views/kanban_board_view.dart';
import 'views/task_list_view.dart';
import '../../core/theme/linear_theme.dart';

enum TaskSubView {
  list,
  kanban,
  calendar,
  dashboard,
}

class TaskMainPage extends StatefulWidget {
  const TaskMainPage({super.key});

  @override
  State<TaskMainPage> createState() => _TaskMainPageState();
}

class _TaskMainPageState extends State<TaskMainPage> {
  TaskSubView _currentSubView = TaskSubView.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      body: Column(
        children: [
          // Sub-view Switcher (Gọn nhẹ, thanh lịch chuẩn Linear)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: LinearTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
              ),
              child: Row(
                children: [
                  _buildTab(TaskSubView.list, 'Danh sách', Icons.format_list_bulleted_rounded),
                  _buildTab(TaskSubView.kanban, 'Bảng Kanban', Icons.view_kanban_outlined),
                  _buildTab(TaskSubView.calendar, 'Lịch', Icons.calendar_today_outlined),
                  _buildTab(TaskSubView.dashboard, 'Thống kê', Icons.insights_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(TaskSubView view, String title, IconData icon) {
    final isSelected = _currentSubView == view;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentSubView != view) {
            setState(() => _currentSubView = view);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? LinearTheme.surfaceHighlight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : LinearTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : LinearTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentSubView) {
      case TaskSubView.list:
        return const TaskListView();
      case TaskSubView.kanban:
        return const KanbanBoardView();
      case TaskSubView.calendar:
        return const CalendarView();
      case TaskSubView.dashboard:
        return const DashboardView();
    }
  }
}
