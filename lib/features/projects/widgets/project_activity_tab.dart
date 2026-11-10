import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/linear_theme.dart';
import '../models/project_model.dart';

class ProjectActivityTab extends StatefulWidget {
  final ProjectModel project;

  const ProjectActivityTab({super.key, required this.project});

  @override
  State<ProjectActivityTab> createState() => _ProjectActivityTabState();
}

class _ProjectActivityTabState extends State<ProjectActivityTab> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _activities = [];

  @override
  void initState() {
    super.initState();
    _activities.add({
      'title': '${widget.project.ownerName ?? 'Admin'} đã tạo dự án',
      'time': DateFormat('dd/MM/yyyy HH:mm').format(widget.project.createdAt),
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _activities.insert(0, {
        'title': text,
        'time': 'Vừa xong',
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              final item = _activities[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: LinearTheme.surfaceRaised,
                        shape: BoxShape.circle,
                        border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                      ),
                      child: const Center(
                        child: Text(
                          'Q',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['time'] ?? '',
                            style: const TextStyle(color: LinearTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: LinearTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                  ),
                  child: const Icon(Icons.view_in_ar_rounded, color: Colors.white70, size: 18),
                ),
                const SizedBox(width: 10),
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
                      onSubmitted: (_) => _addComment(),
                      decoration: const InputDecoration(
                        hintText: '+ Bình luận...',
                        hintStyle: TextStyle(color: LinearTheme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: LinearTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
