import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../../core/theme/linear_theme.dart';
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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: LinearTheme.surface,
                borderRadius: BorderRadius.circular(16),
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
                  setState(() {
                    _focusedDay = newFocusedDay;
                  });
                  provider.setSelectedCalendarDate(newSelectedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  formatButtonDecoration: BoxDecoration(
                    color: const Color(0xFF26282E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: LinearTheme.textSecondary),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: LinearTheme.textSecondary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: LinearTheme.textSecondary, fontSize: 12),
                  weekendStyle: TextStyle(color: Color(0xFFF2994A), fontSize: 12),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                  weekendTextStyle: const TextStyle(color: Color(0xFFD6D9E0), fontSize: 13),
                  outsideTextStyle: const TextStyle(color: Color(0xFF484B55), fontSize: 13),
                  todayDecoration: BoxDecoration(
                    color: LinearTheme.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: LinearTheme.accent, width: 1.2),
                  ),
                  todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  selectedDecoration: const BoxDecoration(
                    color: LinearTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFFF2994A),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_note, color: LinearTheme.accentLight, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline ngày ${DateFormat('dd/MM/yyyy').format(selectedDay)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202227),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${tasksForDay.length} task',
                      style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasksForDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 40, color: Colors.grey.shade700),
                          const SizedBox(height: 10),
                          Text(
                            'Không có deadline nào trong ngày ${DateFormat('dd/MM').format(selectedDay)}',
                            style: const TextStyle(color: LinearTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: tasksForDay.length,
                      itemBuilder: (context, index) {
                        final task = tasksForDay[index];
                        return TaskItemTile(
                          task: task,
                          onTap: () => TaskDetailBottomSheet.show(context, task: task),
                          onStatusChanged: (newStatus) {
                            provider.moveTask(task.id, newStatus);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
