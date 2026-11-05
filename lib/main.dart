import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/linear_theme.dart';
import 'core/layout/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(const LinearApp());
}

class LinearApp extends StatelessWidget {
  const LinearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linear Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: LinearTheme.background,
        colorScheme: const ColorScheme.dark(
          primary: LinearTheme.accent,
          surface: LinearTheme.surface,
        ),
      ),
      home: const MainLayout(),
    );
  }
}
