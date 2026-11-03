import 'package:flutter/material.dart';
import 'package:do_an_flutter/Home/task.dart';
import 'package:do_an_flutter/Home/inbox.dart';
import 'package:do_an_flutter/Settings/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 1. Biến lưu vị trí tab đang được chọn (0: Inbox, 1: Tasks, 2: Projects & Teams, 3: Others)
  int currentIndex = 0;

  // 2. Danh sách các màn hình tương ứng với các nút ở thanh bên dưới
  final List<Widget> pages = [
    const InboxPage(),
    const TaskPage(),
    const Center(child: Text('Màn hình Projects & Teams', style: TextStyle(color: Colors.white, fontSize: 18))),
    // const Center(child: Text('Màn hình Others', style: TextStyle(color: Colors.white, fontSize: 18))),
    const SettingsPage(),
  ];

  // Danh sách tiêu đề tương ứng với từng tab
  final List<String> titles = [
    'Inbox',
    'Tasks',
    'Projects & Teams',
    'Settings',
  ];

  // 3. Hàm chuyển tab khi bấm vào từng icon
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
            fontSize: 26,
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
                  onPressed: () {},
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

      // 4. Đổi trang tương ứng với tab đang chọn
      body: pages[currentIndex],

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thanh viên thuốc chứa các icon tab
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tab 0: Inbox
                    _buildNavButton(
                      index: 0,
                      icon: Icons.inbox_outlined,
                      hasBadge: true,
                    ),

                    // Tab 1: Tasks
                    _buildNavButton(
                      index: 1,
                      icon: Icons.assignment_outlined,
                    ),

                    // Tab 2: Focus
                    _buildNavButton(
                      index: 2,
                      icon: Icons.center_focus_weak,
                    ),

                    // Tab 3: AI
                    _buildNavButton(
                      index: 3,
                      icon: Icons.auto_awesome,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Nút tròn bên phải
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_new, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hỗ trợ tạo nút bấm tab có highlight khi chọn
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
