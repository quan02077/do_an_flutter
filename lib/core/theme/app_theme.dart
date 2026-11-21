
import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFF3B82F6);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Colors.white,
    ),
  );
}
