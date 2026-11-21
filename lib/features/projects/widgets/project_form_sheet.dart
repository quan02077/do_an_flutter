import 'package:flutter/material.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/project_model.dart';
import '../state/project_provider.dart';

class ProjectFormSheet extends StatefulWidget {
  final ProjectModel? project;

  const ProjectFormSheet({super.key, this.project});

  static Future<void> show(BuildContext context, {ProjectModel? project}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProjectFormSheet(project: project),
    );
  }

  @override
  State<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends State<ProjectFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveProject() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên dự án'),
          backgroundColor: LinearTheme.priorityUrgent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = ProjectProvider();
    final desc = _descController.text.trim();

    if (widget.project != null) {
      provider.updateProject(
        widget.project!.copyWith(name: name, description: desc),
      );
    } else {
      provider.addProject(
        ProjectModel(id: '', name: name, description: desc),
      );
    }

    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16171B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xác nhận xoá', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Bạn có chắc muốn xoá dự án "${widget.project?.name}" không?',
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
              ProjectProvider().deleteProject(widget.project!.id);
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
    final mediaQuery = MediaQuery.of(context);
    final isEditing = widget.project != null;

    return Container(
      height: mediaQuery.size.height * 0.72,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1013),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: LinearTheme.surfaceRaised,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: LinearTheme.textSecondary, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Chỉnh sửa dự án' : 'Tạo mới dự án',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: LinearTheme.priorityUrgent, size: 20),
                    onPressed: _confirmDelete,
                  ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LinearTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditing ? 'Lưu' : 'Tạo',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: LinearTheme.surfaceBorder, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: !isEditing,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tên dự án...',
                      hintStyle: TextStyle(
                        color: Color(0xFF4C505C),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: LinearTheme.surfaceBorder, height: 1),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: null,
                    minLines: 4,
                    style: const TextStyle(
                      color: LinearTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Thêm mô tả chi tiết dự án...',
                      hintStyle: TextStyle(
                        color: Color(0xFF4C505C),
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
