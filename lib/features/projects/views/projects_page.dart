import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../../tasks/state/task_provider.dart';
import '../../tasks/widgets/linear_empty_state.dart';
import '../state/project_provider.dart';
import '../widgets/project_card.dart';
import 'project_detail_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      body: ListenableBuilder(
        listenable: Listenable.merge([ProjectProvider(), TaskProvider()]),
        builder: (context, _) {
          final provider = ProjectProvider();
          final projects = provider.filteredProjects;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dự án...',
                      hintStyle: const TextStyle(color: LinearTheme.textMuted, fontSize: 12.5),
                      prefixIcon: const Icon(Icons.search, color: LinearTheme.textSecondary, size: 16),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.clear, color: LinearTheme.textSecondary, size: 15),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: LinearTheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: LinearTheme.accent, width: 1),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      provider.setSearchQuery(val);
                    },
                  ),
                ),
              ),
              if (projects.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 18, top: 14, bottom: 4),
                  child: Text(
                    'Đang thực hiện',
                    style: TextStyle(
                      color: LinearTheme.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: projects.isEmpty
                    ? LinearEmptyState(
                        title: 'Chưa có dự án nào',
                        subtitle: provider.searchQuery.isNotEmpty
                            ? 'Không tìm thấy kết quả phù hợp với từ khóa'
                            : 'Bấm dấu + ở góc dưới để tạo dự án đầu tiên',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 2, bottom: 90),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return Dismissible(
                            key: Key(project.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: LinearTheme.priorityUrgent.withValues(alpha: 0.2),
                              child: const Icon(Icons.delete_outline, color: LinearTheme.priorityUrgent, size: 18),
                            ),
                            onDismissed: (_) {
                              final deleted = project;
                              provider.deleteProject(project.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã xoá dự án "${deleted.name}"'),
                                  backgroundColor: const Color(0xFF1E2025),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: 'Hoàn tác',
                                    textColor: LinearTheme.accentLight,
                                    onPressed: () {
                                      provider.addProject(deleted);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ProjectCard(
                              project: project,
                              totalTasks: provider.getTaskCount(project.id, project.name),
                              doneTasks: provider.getCompleteTask(project.id, project.name),
                              progress: provider.getProgress(project.id, project.name),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailPage(project: project),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
