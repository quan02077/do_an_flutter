import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';

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
      centerTitle: false,
      titleSpacing: 20,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LinearTheme.surfaceRaised,
              border: Border.all(color: LinearTheme.surfaceBorder, width: 0.8),
            ),
            child: const Center(
              child: Text(
                'Q',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
