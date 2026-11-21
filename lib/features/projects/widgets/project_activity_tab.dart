import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/linear_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/state/auth_provider.dart';
import '../models/project_model.dart';

class ProjectActivityTab extends StatefulWidget {
  final ProjectModel project;

  const ProjectActivityTab({super.key, required this.project});

  @override
  State<ProjectActivityTab> createState() => _ProjectActivityTabState();
}

class _ProjectActivityTabState extends State<ProjectActivityTab> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Gửi bình luận lên Supabase
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final user = AuthService().currentUser;
      final userName = AuthProvider().displayName;

      await SupabaseService.client.from('comments').insert({
        'project_id': widget.project.id,
        if (user != null) 'user_id': user.id,
        'user_name': userName,
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      });

      _commentController.clear();
    } catch (e) {
      debugPrint('Lỗi gửi comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi bình luận: $e'),
            backgroundColor: LinearTheme.priorityUrgent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Danh sách bình luận & hoạt động Realtime từ Supabase
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: SupabaseService.client
                .from('comments')
                .stream(primaryKey: ['id'])
                .eq('project_id', widget.project.id)
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              final comments = snapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: comments.length + 1, // +1 cho sự kiện tạo dự án ban đầu
                itemBuilder: (context, index) {
                  // Dòng cuối cùng: Sự kiện tạo dự án
                  if (index == comments.length) {
                    return _buildActivityItem(
                      avatarLetter: (widget.project.ownerName ?? 'A')[0].toUpperCase(),
                      userName: widget.project.ownerName ?? 'Admin',
                      content: 'đã tạo dự án "${widget.project.name}"',
                      time: DateFormat('dd/MM/yyyy HH:mm').format(widget.project.createdAt),
                      isSystemEvent: true,
                    );
                  }

                  // Các bình luận Realtime của người dùng
                  final item = comments[index];
                  final author = item['user_name'] as String? ?? 'Thành viên';
                  final content = item['content'] as String? ?? '';
                  final createdAtStr = item['created_at']?.toString();
                  DateTime? createdTime;
                  if (createdAtStr != null) {
                    createdTime = DateTime.tryParse(createdAtStr);
                  }
                  final timeStr = createdTime != null
                      ? DateFormat('dd/MM HH:mm').format(createdTime.toLocal())
                      : 'Vừa xong';

                  return _buildActivityItem(
                    avatarLetter: author.isNotEmpty ? author[0].toUpperCase() : 'U',
                    userName: author,
                    content: content,
                    time: timeStr,
                  );
                },
              );
            },
          ),
        ),

        // Thanh nhập bình luận dưới cùng
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Icon Avatar của người dùng hiện tại
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: LinearTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      AuthProvider().displayName.isNotEmpty
                          ? AuthProvider().displayName[0].toUpperCase()
                          : 'Q',
                      style: const TextStyle(
                        color: LinearTheme.accentLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Ô nhập nội dung bình luận
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: LinearTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onSubmitted: (_) => _sendComment(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập bình luận thảo luận...',
                        hintStyle: TextStyle(color: LinearTheme.textMuted, fontSize: 12.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Nút Gửi (Mũi tên lên)
                GestureDetector(
                  onTap: _sendComment,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: LinearTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Item hiển thị 1 bình luận hoặc hoạt động
  Widget _buildActivityItem({
    required String avatarLetter,
    required String userName,
    required String content,
    required String time,
    bool isSystemEvent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar tròn
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSystemEvent ? LinearTheme.surfaceRaised : LinearTheme.accent.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSystemEvent ? LinearTheme.surfaceBorder : LinearTheme.accent,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Text(
                avatarLetter,
                style: TextStyle(
                  color: isSystemEvent ? Colors.white70 : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tên + Nội dung + Thời gian
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: LinearTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: isSystemEvent ? LinearTheme.textSecondary : LinearTheme.textPrimary,
                    fontSize: 13,
                    fontStyle: isSystemEvent ? FontStyle.italic : FontStyle.normal,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
