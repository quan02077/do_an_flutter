import 'package:flutter/material.dart';
import 'package:do_an_flutter/Home/task.dart';
import 'package:do_an_flutter/Home/inbox.dart';
import 'package:do_an_flutter/features/tasks/views/task_detail_bottom_sheet.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const InboxPage(),
    const TaskPage(),
    const Center(
      child: Text(
        'Màn hình Projects & Teams',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  ];

  final List<String> titles = [
    'Inbox',
    'Tasks',
    'Projects & Teams',
  ];

  void switchTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          titles[currentIndex],
          style: const TextStyle(
            fontFamily: 'MyCustomFont',
            fontWeight: FontWeight.bold,
            fontSize: 50,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    if (currentIndex == 1) TaskDetailBottomSheet.show(context);
                  },
                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(35),
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
                      icon: Icons.groups_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      onTap: () => switchTab(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF333333) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[500],
              size: 26,
            ),
            if (hasBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
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
