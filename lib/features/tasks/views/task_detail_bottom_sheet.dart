import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../projects/state/project_provider.dart';
import '../../../core/theme/linear_theme.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final TaskModel? task;
  final String? initialProjectId;
  final String? initialProjectName;

  const TaskDetailBottomSheet({
    super.key,
    this.task,
    this.initialProjectId,
    this.initialProjectName,
  });

  static Future<void> show(
    BuildContext context, {
    TaskModel? task,
    String? initialProjectId,
    String? initialProjectName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailBottomSheet(
        task: task,
        initialProjectId: initialProjectId,
        initialProjectName: initialProjectName,
      ),
    );
  }

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskStatus _status;
  late TaskPriority _priority;
  late String _assignee;
  late List<String> _labels;
  late String _project;
  String? _projectId;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? TaskStatus.backlog;
    _priority = t?.priority ?? TaskPriority.none;
    _assignee = t?.assignee ?? 'Nguyen Nhat Minh Quan';
    _labels = List.from(t?.labels ?? []);
    _project = t?.project ?? widget.initialProjectName ?? 'Linear Mobile App';
    _projectId = t?.projectId ?? widget.initialProjectId;
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề công việc'),
          backgroundColor: LinearTheme.priorityUrgent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = TaskProvider();
    if (widget.task == null) {
      final newId = 'LIN-${100 + provider.tasks.length + 1}';
      final newTask = TaskModel(
        id: newId,
        code: newId,
        title: title,
        description: _descController.text.trim(),
        status: _status,
        priority: _priority,
        assignee: _assignee,
        labels: _labels,
        project: _project,
        projectId: _projectId,
        dueDate: _dueDate,
      );
      provider.addTask(newTask);
    } else {
      final updated = widget.task!.copyWith(
        title: title,
        description: _descController.text.trim(),
        status: _status,
        priority: _priority,
        assignee: _assignee,
        labels: _labels,
        project: _project,
        projectId: _projectId,
        dueDate: _dueDate,
      );
      provider.updateTask(updated);
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
          'Bạn có chắc muốn xoá công việc "${widget.task?.displayCode}" không?',
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
              TaskProvider().deleteTask(widget.task!.id);
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
    final isEditing = widget.task != null;

    return Container(
      height: mediaQuery.size.height * 0.85,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1013),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: LinearTheme.surfaceRaised,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: LinearTheme.textSecondary, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? widget.task!.displayCode : 'Tạo mới công việc',
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
                  onPressed: _saveTask,
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

          // Body Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề công việc...',
                      hintStyle: TextStyle(
                        color: Color(0xFF4C505C),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Property Chips Row (Status, Priority, Assignee, Due date, Labels)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPropertyChip(
                          icon: LinearTheme.buildStatusIcon(_status, size: 13),
                          label: LinearTheme.getStatusLabel(_status),
                          onTap: _showStatusPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: LinearTheme.buildPriorityIcon(_priority, size: 13),
                          label: _priority == TaskPriority.none
                              ? 'Mức ưu tiên'
                              : LinearTheme.getPriorityLabel(_priority),
                          onTap: _showPriorityPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.person_outline, size: 13, color: LinearTheme.textSecondary),
                          label: _assignee.isNotEmpty ? _assignee.split(' ').last : 'Người làm',
                          onTap: _showAssigneePicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.calendar_today_outlined, size: 12, color: LinearTheme.textSecondary),
                          label: _dueDate != null ? DateFormat('dd/MM/yyyy').format(_dueDate!) : 'Hạn chót',
                          onTap: _showDatePicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.view_in_ar_rounded, size: 12, color: Color(0xFFEB5757)),
                          label: _projectId != null ? _project : 'Dự án',
                          onTap: _showProjectPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.local_offer_outlined, size: 12, color: LinearTheme.textSecondary),
                          label: _labels.isNotEmpty ? _labels.first : 'Nhãn',
                          onTap: _showLabelPicker,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: LinearTheme.surfaceBorder, height: 1),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: _descController,
                    maxLines: null,
                    minLines: 5,
                    style: const TextStyle(
                      color: LinearTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Thêm mô tả chi tiết...',
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

  Widget _buildPropertyChip({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: LinearTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: LinearTheme.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskStatus.values.map((s) {
              return ListTile(
                dense: true,
                leading: LinearTheme.buildStatusIcon(s, size: 18),
                title: Text(
                  LinearTheme.getStatusLabel(s),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: _status == s
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 18)
                    : null,
                onTap: () {
                  setState(() => _status = s);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskPriority.values.map((p) {
              return ListTile(
                dense: true,
                leading: LinearTheme.buildPriorityIcon(p, size: 18),
                title: Text(
                  LinearTheme.getPriorityLabel(p),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: _priority == p
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 18)
                    : null,
                onTap: () {
                  setState(() => _priority = p);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAssigneePicker() {
    final members = [
      'Nguyen Nhat Minh Quan',
      'Thanh vien 1',
      'Thanh vien 2',
      'Thanh vien 3',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: members.map((m) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: LinearTheme.accent,
                  child: Text(
                    m[0],
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                title: Text(m, style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: _assignee == m
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 18)
                    : null,
                onTap: () {
                  setState(() => _assignee = m);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLabelPicker() {
    final availableLabels = ['Feature', 'Bug', 'Design', 'Kanban', 'Calendar', 'System'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableLabels.map((lbl) {
              final isChosen = _labels.contains(lbl);
              return ListTile(
                dense: true,
                leading: const Icon(Icons.local_offer_outlined, color: LinearTheme.textSecondary, size: 18),
                title: Text('#$lbl', style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: isChosen
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 18)
                    : null,
                onTap: () {
                  setState(() {
                    if (isChosen) {
                      _labels.remove(lbl);
                    } else {
                      _labels.add(lbl);
                    }
                  });
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showProjectPicker() {
    final projects = ProjectProvider().projects;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: projects.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Chưa có dự án nào',
                      style: TextStyle(color: LinearTheme.textSecondary),
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: projects.map((proj) {
                    final isSelected = _projectId == proj.id;
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.view_in_ar_rounded, color: Color(0xFFEB5757), size: 18),
                      title: Text(proj.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: LinearTheme.accent, size: 18)
                          : null,
                      onTap: () {
                        setState(() {
                          _projectId = proj.id;
                          _project = proj.name;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: LinearTheme.accent,
              surface: Color(0xFF16171B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }
}
