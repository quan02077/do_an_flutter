import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../state/task_provider.dart';
import '../../../core/theme/linear_theme.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final TaskModel? task;

  const TaskDetailBottomSheet({super.key, this.task});

  static Future<void> show(BuildContext context, {TaskModel? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailBottomSheet(task: task),
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
    _project = t?.project ?? 'Linear Mobile App';
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
          content: Text('Vui lòng nhập tiêu đề Issue/Task'),
          backgroundColor: LinearTheme.priorityUrgent,
        ),
      );
      return;
    }

    final provider = TaskProvider();
    if (widget.task == null) {
      final newId = 'LIN-${100 + provider.tasks.length + 1}';
      final newTask = TaskModel(
        id: newId,
        title: title,
        description: _descController.text.trim(),
        status: _status,
        priority: _priority,
        assignee: _assignee,
        labels: _labels,
        project: _project,
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
        dueDate: _dueDate,
      );
      provider.updateTask(updated);
    }

    Navigator.pop(context);
  }

  void _deleteCurrentTask() {
    if (widget.task != null) {
      TaskProvider().deleteTask(widget.task!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      height: mediaQuery.size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF101114),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
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
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1D22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.chevron_right, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nguyen Nhat Minh Quan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.task != null) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: LinearTheme.priorityUrgent, size: 22),
                    onPressed: _deleteCurrentTask,
                  ),
                  const SizedBox(width: 4),
                ],
                GestureDetector(
                  onTap: _saveTask,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E313A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: LinearTheme.surfaceBorder, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Issue title',
                      hintStyle: TextStyle(
                        color: Color(0xFF5E626E),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    maxLines: null,
                    minLines: 4,
                    style: const TextStyle(
                      color: LinearTheme.textPrimary,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Description...',
                      hintStyle: TextStyle(
                        color: Color(0xFF5E626E),
                        fontSize: 14.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPropertyChip(
                          icon: LinearTheme.buildStatusIcon(_status, size: 14),
                          label: LinearTheme.getStatusLabel(_status),
                          onTap: _showStatusPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: LinearTheme.buildPriorityIcon(_priority, size: 14),
                          label: _priority == TaskPriority.none
                              ? 'Priority'
                              : LinearTheme.getPriorityLabel(_priority),
                          onTap: _showPriorityPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.person_outline, size: 15, color: LinearTheme.textSecondary),
                          label: _assignee.isNotEmpty ? _assignee.split(' ').last : 'Assignee',
                          onTap: _showAssigneePicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.local_offer_outlined, size: 14, color: LinearTheme.textSecondary),
                          label: _labels.isNotEmpty ? _labels.first : 'Label',
                          onTap: _showLabelPicker,
                        ),
                        const SizedBox(width: 8),
                        _buildPropertyChip(
                          icon: const Icon(Icons.calendar_today_outlined, size: 14, color: LinearTheme.textSecondary),
                          label: _dueDate != null ? DateFormat('dd/MM/yyyy').format(_dueDate!) : 'Due date',
                          onTap: _showDatePicker,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: bottomInset > 0 ? bottomInset + 10 : 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141518),
              border: Border(
                top: BorderSide(color: LinearTheme.surfaceBorder, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildToolbarIcon(Icons.image_outlined, () {
                  _insertFormatting('[image]');
                }),
                _buildToolbarIcon(Icons.alternate_email, () {
                  _insertFormatting('@');
                }),
                _buildToolbarIcon(Icons.format_list_bulleted, () {
                  _insertFormatting('\n- ');
                }),
                _buildToolbarIcon(Icons.format_list_numbered, () {
                  _insertFormatting('\n1. ');
                }),
                _buildToolbarIcon(Icons.code, () {
                  _insertFormatting('`code`');
                }),
                _buildToolbarIcon(Icons.format_quote, () {
                  _insertFormatting('\n> ');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _insertFormatting(String text) {
    final curText = _descController.text;
    final selection = _descController.selection;
    if (selection.isValid) {
      final newText = curText.replaceRange(selection.start, selection.end, text);
      _descController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + text.length),
      );
    } else {
      _descController.text = curText + text;
    }
  }

  Widget _buildPropertyChip({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2025),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2B2E37), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: LinearTheme.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, color: const Color(0xFF9EA3B0), size: 21),
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
                leading: LinearTheme.buildStatusIcon(s, size: 20),
                title: Text(
                  LinearTheme.getStatusLabel(s),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                trailing: _status == s
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 20)
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
                leading: LinearTheme.buildPriorityIcon(p, size: 20),
                title: Text(
                  LinearTheme.getPriorityLabel(p),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                trailing: _priority == p
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 20)
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
      'Frontend Lead (Thanh vien 1)',
      'Backend Engineer',
      'UI/UX Designer',
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
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: LinearTheme.accent,
                  child: Text(
                    m[0],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(m, style: const TextStyle(color: Colors.white)),
                trailing: _assignee == m
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 20)
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
    final availableLabels = ['Feature', 'Bug', 'Design', 'Kanban', 'Calendar', 'Analytics', 'System'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: availableLabels.map((lbl) {
                  final isSelected = _labels.contains(lbl);
                  return ListTile(
                    leading: const Icon(Icons.label_outline, color: Colors.grey, size: 20),
                    title: Text('#$lbl', style: const TextStyle(color: Colors.white)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: LinearTheme.accent, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _labels.remove(lbl);
                        } else {
                          _labels.add(lbl);
                        }
                      });
                      setModalState(() {});
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  void _showProjectPicker() {
    final projects = ['Linear Mobile App', 'Design System v1', 'Core Backend API'];
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
            children: projects.map((proj) {
              return ListTile(
                leading: const Icon(Icons.folder_outlined, color: Colors.grey, size: 20),
                title: Text(proj, style: const TextStyle(color: Colors.white)),
                trailing: _project == proj
                    ? const Icon(Icons.check, color: LinearTheme.accent, size: 20)
                    : null,
                onTap: () {
                  setState(() => _project = proj);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: LinearTheme.accent,
              surface: Color(0xFF1E2025),
              onSurface: Colors.white,
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
