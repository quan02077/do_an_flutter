import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../widgets/task_item_tile.dart';
import 'task_detail_bottom_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();
        final selectedDay = provider.selectedCalendarDate;
        final tasksForDay = provider.getTasksForDate(selectedDay);

        return Column(
          children: [
            // 1. Lịch TableCalendar tháng / tuần
            _buildCalendar(provider, selectedDay),

            // 2. Tiêu đề ngày được chọn
            _buildDateHeader(selectedDay, tasksForDay.length),

            // 3. Danh sách công việc có deadline vào ngày được chọn
            Expanded(
              child: tasksForDay.isEmpty
                  ? _buildEmptyDay(selectedDay)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 95),
                      itemCount: tasksForDay.length,
                      itemBuilder: (ctx, i) => TaskItemTile(
                        task: tasksForDay[i],
                        onTap: () => TaskDetailBottomSheet.show(context, task: tasksForDay[i]),
                        onStatusChanged: (newStatus) => provider.moveTask(tasksForDay[i].id, newStatus),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// 1. Widget Lịch tháng
  Widget _buildCalendar(TaskProvider provider, DateTime selectedDay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: LinearTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
      ),
      child: TableCalendar<TaskModel>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: (day) => provider.getTasksForDate(day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          setState(() => _focusedDay = newFocusedDay);
          provider.setSelectedCalendarDate(newSelectedDay);
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 10.5),
          formatButtonDecoration: BoxDecoration(
            color: LinearTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LinearTheme.surfaceBorder, width: 0.6),
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: LinearTheme.textSecondary, size: 20),
          rightChevronIcon: const Icon(Icons.chevron_right, color: LinearTheme.textSecondary, size: 20),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: LinearTheme.textSecondary, fontSize: 11.5),
          weekendStyle: TextStyle(color: Color(0xFFF2994A), fontSize: 11.5),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 12.5),
          weekendTextStyle: const TextStyle(color: Color(0xFFD6D9E0), fontSize: 12.5),
          outsideTextStyle: const TextStyle(color: Color(0xFF484B55), fontSize: 12.5),
          todayDecoration: BoxDecoration(
            color: LinearTheme.surfaceHighlight,
            shape: BoxShape.circle,
            border: Border.all(color: LinearTheme.accent, width: 1.2),
          ),
          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(color: LinearTheme.accent, shape: BoxShape.circle),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          markerDecoration: const BoxDecoration(color: Color(0xFFF2994A), shape: BoxShape.circle),
          markersMaxCount: 3,
        ),
      ),
    );
  }

  /// 2. Tiêu đề hiển thị ngày đang chọn
  Widget _buildDateHeader(DateTime selectedDay, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.event_note, color: LinearTheme.accentLight, size: 16),
          const SizedBox(width: 8),
          Text(
            'Hạn chót ngày ${DateFormat('dd/MM/yyyy').format(selectedDay)}',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: LinearTheme.surfaceRaised, borderRadius: BorderRadius.circular(8)),
            child: Text('$count việc', style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// 3. Khi không có task nào trong ngày
  Widget _buildEmptyDay(DateTime selectedDay) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 36, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text(
            'Không có hạn chót nào trong ngày ${DateFormat('dd/MM').format(selectedDay)}',
            style: const TextStyle(color: LinearTheme.textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
