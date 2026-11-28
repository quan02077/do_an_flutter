import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../../auth/models/user_model.dart';
import '../../auth/state/auth_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/state/task_provider.dart';
import '../models/project_model.dart';
import '../state/project_provider.dart';

/// Màn hình Quản lý Thành viên Nhóm bên trong Chi tiết Dự án (đọc/ghi bảng project_members)
class ProjectMembersPage extends StatelessWidget {
  final ProjectModel project;

  const ProjectMembersPage({super.key, required this.project});

  /// Mở hộp thoại tìm kiếm tài khoản theo Email (giống GitHub) để mời vào dự án
  Future<void> _showInviteMemberDialog(BuildContext context) async {
    await AuthProvider().loadTeamMembers();
    if (!context.mounted) return;

    final addedName = await showDialog<String>(
      context: context,
      builder: (_) => _InviteMemberDialog(project: project),
    );

    if (addedName != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "$addedName" vào dự án "${project.name}"'),
          backgroundColor: LinearTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      appBar: AppBar(
        backgroundColor: LinearTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thành viên • ${project.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: LinearTheme.textSecondary),
            tooltip: 'Tải lại từ server',
            onPressed: () => AuthProvider().loadTeamMembers(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: LinearTheme.accentLight),
            tooltip: 'Mời thành viên',
            onPressed: () => _showInviteMemberDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AuthProvider(), ProjectProvider(), TaskProvider()]),
        builder: (context, _) {
          final auth = AuthProvider();
          final projectProvider = ProjectProvider();
          final List<UserModel> members = projectProvider.getUsersForProject(project.id);

          // Chỉ lọc các công việc thuộc về dự án hiện tại
          final projectTasks = TaskProvider().tasks.where((t) {
            return t.projectId == project.id ||
                (t.projectId == null && t.project == project.name);
          }).toList();
          final doneCount = projectTasks.where((t) => t.status == TaskStatus.done).length;

          return Column(
            children: [
              // 1. Thẻ tóm tắt thành viên & tiến độ trong dự án này
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: LinearTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    _buildSummaryStat('Thành viên', '${members.length}', Icons.group_outlined),
                    _buildSummaryStat('Việc dự án', '${projectTasks.length}', Icons.assignment_outlined),
                    _buildSummaryStat('Hoàn thành', '$doneCount', Icons.check_circle_outline),
                  ],
                ),
              ),

              // 2. Danh sách thành viên của riêng dự án này
              Expanded(
                child: members.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có thành viên nào trong dự án',
                          style: TextStyle(color: LinearTheme.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          final name = member.fullname.isNotEmpty
                              ? member.fullname
                              : member.email.split('@').first;

                          final isLeader = project.ownerId == member.id ||
                              (project.ownerId == null && index == 0);
                          final isMe = auth.currentUser?.id == member.id;
                          final roleLabel =
                              isLeader ? 'Trưởng nhóm' : (isMe ? 'Bạn' : 'Thành viên');
                          final highlight = isLeader || isMe;

                          // Đếm số công việc của dự án được giao cho thành viên này
                          final memberTasks = projectTasks.where((t) {
                            return t.assignedTo == member.id ||
                                (t.assignedTo == null &&
                                    t.assignee.toLowerCase() == name.toLowerCase());
                          }).toList();
                          final memberDone =
                              memberTasks.where((t) => t.status == TaskStatus.done).length;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: LinearTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: highlight
                                      ? LinearTheme.accent
                                      : const Color(0xFF2D313B),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: highlight
                                                  ? LinearTheme.accent.withValues(alpha: 0.2)
                                                  : LinearTheme.surfaceRaised,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              roleLabel,
                                              style: TextStyle(
                                                color: highlight
                                                    ? LinearTheme.accentLight
                                                    : LinearTheme.textSecondary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        member.email,
                                        style: const TextStyle(
                                          color: LinearTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${memberTasks.length} việc',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$memberDone xong',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                // Cho phép trưởng nhóm gỡ thành viên khác khỏi dự án
                                if (!isLeader && project.ownerId == auth.currentUser?.id) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: LinearTheme.textMuted, size: 18),
                                    tooltip: 'Gỡ khỏi dự án',
                                    onPressed: () => projectProvider.removeMember(
                                      projectId: project.id,
                                      userId: member.id,
                                    ),
                                  ),
                                ],
                              ],
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

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: LinearTheme.accentLight, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: LinearTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Widget hộp thoại tìm kiếm tài khoản theo Email để mời vào dự án
class _InviteMemberDialog extends StatefulWidget {
  final ProjectModel project;

  const _InviteMemberDialog({required this.project});

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMemberIds = ProjectProvider()
        .getUsersForProject(widget.project.id)
        .map((u) => u.id)
        .toSet();
    final allUsers = AuthProvider().allMembers;
    final query = _searchController.text.trim().toLowerCase();

    final results = query.isEmpty
        ? <UserModel>[]
        : allUsers.where((u) {
            return u.email.toLowerCase().contains(query) ||
                u.fullname.toLowerCase().contains(query);
          }).toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF1E2025),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Mời thành viên vào dự án',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Nhập email để tìm tài khoản...',
                hintStyle: const TextStyle(color: LinearTheme.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: LinearTheme.textSecondary, size: 18),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: LinearTheme.textMuted, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: LinearTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: LinearTheme.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: LinearTheme.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: LinearTheme.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: query.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_outlined, color: LinearTheme.textMuted, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Tìm kiếm theo email thành viên đã đăng ký để mời vào dự án.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: LinearTheme.textSecondary, fontSize: 12.5),
                          ),
                        ],
                      ),
                    )
                  : results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Không tìm thấy tài khoản nào khớp với "$query"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: LinearTheme.textMuted, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (_, index) {
                            final user = results[index];
                            final name = user.fullname.isNotEmpty
                                ? user.fullname
                                : user.email.split('@').first;
                            final isAlreadyIn = currentMemberIds.contains(user.id);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    isAlreadyIn ? const Color(0xFF2D313B) : LinearTheme.accent,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(name,
                                  style: const TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: Text(
                                user.email,
                                style: const TextStyle(color: LinearTheme.textMuted, fontSize: 12),
                              ),
                              trailing: isAlreadyIn
                                  ? const Text(
                                      'Đã tham gia',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _isAdding
                                          ? null
                                          : () async {
                                              setState(() => _isAdding = true);
                                              try {
                                                await ProjectProvider().addMember(
                                                  projectId: widget.project.id,
                                                  user: user,
                                                  projectName: widget.project.name,
                                                );
                                                if (context.mounted) {
                                                  Navigator.pop(context, name);
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  setState(() => _isAdding = false);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Lỗi thêm thành viên: $e'),
                                                      backgroundColor: LinearTheme.priorityUrgent,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: LinearTheme.accent,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Mời', style: TextStyle(fontSize: 12)),
                                    ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: LinearTheme.textMuted)),
        ),
      ],
    );
  }
}
