import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskProvider(),
      builder: (context, _) {
        final provider = TaskProvider();
        final tasks = provider.tasks;

        // Số liệu thống kê theo trạng thái
        final total = tasks.length;
        final doneCount = provider.getTasksByStatus(TaskStatus.done).length;
        final inProgressCount = provider.getTasksByStatus(TaskStatus.inProgress).length;
        final todoCount = provider.getTasksByStatus(TaskStatus.todo).length;
        final backlogCount = provider.getTasksByStatus(TaskStatus.backlog).length;

        // Số liệu thống kê theo độ ưu tiên
        final urgentCount = tasks.where((t) => t.priority == TaskPriority.urgent).length;
        final highCount = tasks.where((t) => t.priority == TaskPriority.high).length;
        final mediumCount = tasks.where((t) => t.priority == TaskPriority.medium).length;
        final lowCount = tasks.where((t) => t.priority == TaskPriority.low).length;

        // Tỷ lệ hoàn thành %
        final completionRate = total > 0 ? (doneCount / total * 100).toStringAsFixed(0) : '0';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bốn thẻ số liệu nhanh (Metrics)
              _buildMetricGrid(total, doneCount, inProgressCount, urgentCount + highCount, completionRate),

              const SizedBox(height: 20),

              // 2. Biểu đồ tròn: Phân bố trạng thái (PieChart)
              _buildStatusPieCard(total, doneCount, inProgressCount, todoCount, backlogCount, completionRate),

              const SizedBox(height: 20),

              // 3. Biểu đồ cột: Khối lượng theo mức độ ưu tiên (BarChart)
              _buildPriorityBarCard(urgentCount, highCount, mediumCount, lowCount),
            ],
          ),
        );
      },
    );
  }

  /// 1. Lưới 4 thẻ thống kê số liệu
  Widget _buildMetricGrid(int total, int done, int inProgress, int highPriority, String rate) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('Tổng số công việc', '$total', Icons.assignment_outlined, LinearTheme.accentLight)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard('Hoàn thành', '$done ($rate%)', Icons.check_circle_outline, const Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Đang làm', '$inProgress', Icons.pending_outlined, LinearTheme.statusInProgress)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard('Khẩn cấp / Cao', '$highPriority', Icons.local_fire_department_outlined, LinearTheme.priorityUrgent)),
          ],
        ),
      ],
    );
  }

  /// 2. Khung biểu đồ tròn trạng thái (PieChart)
  Widget _buildStatusPieCard(int total, int done, int inProgress, int todo, int backlog, String rate) {
    return Container(
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
              Text('Phân bố trạng thái công việc', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: total == 0
                ? const Center(child: Text('Chưa có dữ liệu công việc', style: TextStyle(color: Colors.grey)))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 48,
                          sections: [
                            if (done > 0) PieChartSectionData(color: LinearTheme.statusDone, value: done.toDouble(), title: '$done', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            if (inProgress > 0) PieChartSectionData(color: LinearTheme.statusInProgress, value: inProgress.toDouble(), title: '$inProgress', radius: 30, titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            if (todo > 0) PieChartSectionData(color: const Color(0xFF64748B), value: todo.toDouble(), title: '$todo', radius: 30, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            if (backlog > 0) PieChartSectionData(color: const Color(0xFF334155), value: backlog.toDouble(), title: '$backlog', radius: 30, titleStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$rate%', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Tiến độ', style: TextStyle(color: LinearTheme.textMuted, fontSize: 11)),
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
              _buildLegend('Hoàn thành', LinearTheme.statusDone, done),
              _buildLegend('Đang làm', LinearTheme.statusInProgress, inProgress),
              _buildLegend('Cần làm', const Color(0xFF64748B), todo),
              _buildLegend('Chờ xử lý', const Color(0xFF334155), backlog),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Khung biểu đồ cột độ ưu tiên (BarChart)
  Widget _buildPriorityBarCard(int urgent, int high, int medium, int low) {
    final maxVal = [urgent, high, medium, low].reduce((a, b) => a > b ? a : b).toDouble() + 2;

    return Container(
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
              Text('Khối lượng theo mức độ ưu tiên', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E2025),
                    getTooltipItem: (group, _, rod, __) {
                      final names = ['Khẩn cấp', 'Cao', 'Trung bình', 'Thấp'];
                      return BarTooltipItem('${names[group.x]}: ${rod.toY.toInt()}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, _) => val == 0 || val % 1 != 0 ? const SizedBox.shrink() : Text(val.toInt().toString(), style: const TextStyle(color: LinearTheme.textMuted, fontSize: 11)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        const labels = ['Khẩn', 'Cao', 'TB', 'Thấp'];
                        final idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[idx], style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, urgent.toDouble(), LinearTheme.priorityUrgent),
                  _makeBarGroup(1, high.toDouble(), LinearTheme.priorityHigh),
                  _makeBarGroup(2, medium.toDouble(), LinearTheme.priorityMedium),
                  _makeBarGroup(3, low.toDouble(), const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
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
            children: [
              Icon(icon, size: 16, color: color),
              const Spacer(),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}
