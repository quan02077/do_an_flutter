import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../../core/theme/linear_theme.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();
        final tasks = provider.tasks;

        final total = tasks.length;
        final doneCount = provider.getTasksByStatus(TaskStatus.done).length;
        final inProgressCount = provider.getTasksByStatus(TaskStatus.inProgress).length;
        final todoCount = provider.getTasksByStatus(TaskStatus.todo).length;
        final backlogCount = provider.getTasksByStatus(TaskStatus.backlog).length;

        final urgentCount = tasks.where((t) => t.priority == TaskPriority.urgent).length;
        final highCount = tasks.where((t) => t.priority == TaskPriority.high).length;
        final mediumCount = tasks.where((t) => t.priority == TaskPriority.medium).length;
        final lowCount = tasks.where((t) => t.priority == TaskPriority.low).length;

        final completionRate = total > 0 ? (doneCount / total * 100).toStringAsFixed(0) : '0';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Tổng số Task',
                      value: '$total',
                      icon: Icons.assignment_outlined,
                      color: LinearTheme.accentLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Hoàn thành',
                      value: '$doneCount ($completionRate%)',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Đang làm',
                      value: '$inProgressCount',
                      icon: Icons.pending_outlined,
                      color: LinearTheme.statusInProgress,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Khẩn cấp / Cao',
                      value: '${urgentCount + highCount}',
                      icon: Icons.local_fire_department_outlined,
                      color: LinearTheme.priorityUrgent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LinearTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pie_chart_outline, color: LinearTheme.accentLight, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Phân bố trạng thái công việc',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: total == 0
                          ? const Center(
                              child: Text('Chưa có dữ liệu task', style: TextStyle(color: Colors.grey)),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 48,
                                    sections: [
                                      if (doneCount > 0)
                                        PieChartSectionData(
                                          color: LinearTheme.statusDone,
                                          value: doneCount.toDouble(),
                                          title: '$doneCount',
                                          radius: 30,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (inProgressCount > 0)
                                        PieChartSectionData(
                                          color: LinearTheme.statusInProgress,
                                          value: inProgressCount.toDouble(),
                                          title: '$inProgressCount',
                                          radius: 30,
                                          titleStyle: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (todoCount > 0)
                                        PieChartSectionData(
                                          color: const Color(0xFF64748B),
                                          value: todoCount.toDouble(),
                                          title: '$todoCount',
                                          radius: 30,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (backlogCount > 0)
                                        PieChartSectionData(
                                          color: const Color(0xFF334155),
                                          value: backlogCount.toDouble(),
                                          title: '$backlogCount',
                                          radius: 30,
                                          titleStyle: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$completionRate%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Tiến độ',
                                      style: TextStyle(
                                        color: LinearTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem('Done', LinearTheme.statusDone, doneCount),
                        _buildLegendItem('In Progress', LinearTheme.statusInProgress, inProgressCount),
                        _buildLegendItem('Todo', const Color(0xFF64748B), todoCount),
                        _buildLegendItem('Backlog', const Color(0xFF334155), backlogCount),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LinearTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, color: LinearTheme.accentLight, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Khối lượng công việc theo Priority',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: [urgentCount, highCount, mediumCount, lowCount]
                                  .reduce((a, b) => a > b ? a : b)
                                  .toDouble() +
                              2,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1E2025),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final priorities = ['Urgent', 'High', 'Medium', 'Low'];
                                return BarTooltipItem(
                                  '${priorities[group.x]}: ${rod.toY.toInt()}',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0 || value % 1 != 0) return const SizedBox.shrink();
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(color: LinearTheme.textMuted, fontSize: 11),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final titles = ['Urgent', 'High', 'Med', 'Low'];
                                  final idx = value.toInt();
                                  if (idx >= 0 && idx < titles.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        titles[idx],
                                        style: const TextStyle(
                                          color: LinearTheme.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => const FlLine(
                              color: LinearTheme.surfaceBorder,
                              strokeWidth: 0.6,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: urgentCount.toDouble(),
                                  color: LinearTheme.priorityUrgent,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: highCount.toDouble(),
                                  color: LinearTheme.priorityHigh,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: mediumCount.toDouble(),
                                  color: LinearTheme.priorityMedium,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: lowCount.toDouble(),
                                  color: LinearTheme.priorityLow,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LinearTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 12),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
