import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';
import 'package:do_an_flutter/features/tasks/views/task_detail_bottom_sheet.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentIndex;

  const MainAppBar({
    super.key,
    required this.title,
    required this.currentIndex,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LinearTheme.background,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  if (currentIndex == 1) {
                    TaskDetailBottomSheet.show(context);
                  }
                },
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Colors.white, size: 22),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
