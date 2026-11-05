import 'package:flutter/material.dart';
import 'package:do_an_flutter/core/theme/linear_theme.dart';
import 'package:do_an_flutter/features/inbox/views/inbox_page.dart';
import 'package:do_an_flutter/features/projects/views/projects_page.dart';
import 'package:do_an_flutter/features/settings/views/settings_page.dart';
import 'package:do_an_flutter/features/tasks/task_main_page.dart';
import 'widgets/floating_toolbar.dart';
import 'widgets/main_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 1; // Mặc định mở tab Tasks

  final List<Widget> pages = [
    const InboxPage(),
    const TaskMainPage(),
    const ProjectsPage(),
    const SettingsPage(), // Màn hình Cài đặt của Thành viên 1
  ];

  final List<String> titles = [
    'Inbox',
    'Tasks',
    'Projects',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinearTheme.background,
      appBar: MainAppBar(
        title: titles[currentIndex],
        currentIndex: currentIndex,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: FloatingToolbar(
        currentIndex: currentIndex,
        onTabSelected: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
