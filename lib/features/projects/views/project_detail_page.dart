import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/state/task_provider.dart';
import '../../tasks/views/task_detail_bottom_sheet.dart';
import '../models/project_model.dart';
import '../state/project_provider.dart';
import '../widgets/project_activity_tab.dart';
import '../widgets/project_form_sheet.dart';
import '../widgets/project_issues_tab.dart';
import '../widgets/project_overview_tab.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  int _selectedTab = 0; // 0: Tổng quan, 1: Hoạt động, 2: Công việc
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProjectFilterSheet(
        currentStatus: _statusFilter,
        currentPriority: _priorityFilter,
        onStatusChanged: (val) => setState(() => _statusFilter = val),
        onPriorityChanged: (val) => setState(() => _priorityFilter = val),
      ),
    );
  }

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16171B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xác nhận xoá', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Bạn có chắc muốn xoá dự án "${project.name}" không?',
          style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: LinearTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ProjectProvider().deleteProject(project.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LinearTheme.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([ProjectProvider(), TaskProvider()]),
          builder: (context, _) {
            final projectProvider = ProjectProvider();
            final currentProject = projectProvider.projects.firstWhere(
              (p) => p.id == widget.project.id,
              orElse: () => widget.project,
            );

            final totalTasks = projectProvider.getTaskCount(currentProject.id, currentProject.name);
            final doneTasks = projectProvider.getCompleteTask(currentProject.id, currentProject.name);
            final progress = projectProvider.getProgress(currentProject.id, currentProject.name);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Bar (Nút Back tròn + Viên thuốc hành động góc phải)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: LinearTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                          ),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: LinearTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                              icon: Icon(
                                _selectedTab == 2 ? Icons.add : Icons.edit_outlined,
                                color: Colors.white,
                                size: 19,
                              ),
                              onPressed: () {
                                if (_selectedTab == 2) {
                                  TaskDetailBottomSheet.show(
                                    context,
                                    initialProjectId: currentProject.id,
                                    initialProjectName: currentProject.name,
                                  );
                                } else {
                                  ProjectFormSheet.show(context, project: currentProject);
                                }
                              },
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 19),
                              color: const Color(0xFF1E2025),
                              onSelected: (value) {
                                if (value == 'add_task') {
                                  TaskDetailBottomSheet.show(
                                    context,
                                    initialProjectId: currentProject.id,
                                    initialProjectName: currentProject.name,
                                  );
                                } else if (value == 'edit') {
                                  ProjectFormSheet.show(context, project: currentProject);
                                } else if (value == 'delete') {
                                  _confirmDelete(currentProject);
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                  value: 'add_task',
                                  child: Text('Thêm công việc mới', style: TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Chỉnh sửa dự án', style: TextStyle(color: Colors.white, fontSize: 13)),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xoá dự án', style: TextStyle(color: LinearTheme.priorityUrgent, fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Mã dự án & Tên dự án
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentProject.displayCode,
                        style: const TextStyle(
                          color: LinearTheme.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.view_in_ar_rounded,
                            color: Color(0xFFEB5757),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              currentProject.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3 Tabs: Tổng quan | Hoạt động | Công việc
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildTabPill(index: 0, label: 'Tổng quan'),
                      const SizedBox(width: 8),
                      _buildTabPill(index: 1, label: 'Hoạt động'),
                      const SizedBox(width: 8),
                      _buildTabPill(index: 2, label: 'Công việc', showFilterIcon: true),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Nội dung theo từng Tab
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      ProjectOverviewTab(
                        project: currentProject,
                        totalTasks: totalTasks,
                        doneTasks: doneTasks,
                        progress: progress,
                      ),
                      ProjectActivityTab(project: currentProject),
                      ProjectIssuesTab(
                        project: currentProject,
                        statusFilter: _statusFilter,
                        priorityFilter: _priorityFilter,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    bool showFilterIcon = false,
  }) {
    final isSelected = _selectedTab == index;
    final hasActiveFilter = _statusFilter != null || _priorityFilter != null;

    return GestureDetector(
      onTap: () {
        if (_selectedTab == index && showFilterIcon) {
          _openFilterSheet();
        } else {
          setState(() => _selectedTab = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? LinearTheme.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? LinearTheme.surfaceBorder : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : LinearTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (showFilterIcon && isSelected) ...[
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: LinearTheme.surfaceBorder),
              const SizedBox(width: 8),
              Icon(
                Icons.filter_list_rounded,
                size: 15,
                color: hasActiveFilter ? LinearTheme.accentLight : LinearTheme.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
