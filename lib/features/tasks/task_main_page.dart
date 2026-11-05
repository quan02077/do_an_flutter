import 'package:flutter/material.dart';
import 'views/calendar_view.dart';
import 'views/dashboard_view.dart';
import 'views/kanban_board_view.dart';
import 'views/task_detail_bottom_sheet.dart';
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
              ),
              child: Row(
                children: [
                  _buildSubViewTab(TaskSubView.list, 'List', Icons.format_list_bulleted_rounded),
                  _buildSubViewTab(TaskSubView.kanban, 'Kanban', Icons.view_kanban_outlined),
                  _buildSubViewTab(TaskSubView.calendar, 'Calendar', Icons.calendar_month_outlined),
                  _buildSubViewTab(TaskSubView.dashboard, 'Stats', Icons.analytics_outlined),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubViewTab(TaskSubView view, String title, IconData icon) {
    final isSelected = _currentSubView == view;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentSubView = view;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF26282E) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : LinearTheme.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : LinearTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
