import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';
import 'package:do_an_flutter/features/tasks/views/task_detail_bottom_sheet.dart';

class FloatingToolbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingToolbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thanh viên thuốc nổi chứa các tab điều hướng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavButton(
                    index: 0,
                    icon: Icons.inbox_outlined,
                    hasBadge: true,
                  ),
                  _buildNavButton(
                    index: 1,
                    icon: Icons.assignment_outlined,
                  ),
                  _buildNavButton(
                    index: 2,
                    icon: Icons.folder_outlined,
                  ),
                  _buildNavButton(
                    index: 3,
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Nút tròn tạo nhanh task
            GestureDetector(
              onTap: () {
                TaskDetailBottomSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: LinearTheme.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required int index,
    required IconData icon,
    bool hasBadge = false,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26282E) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : LinearTheme.textSecondary,
              size: 20,
            ),
            if (hasBadge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2994A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
