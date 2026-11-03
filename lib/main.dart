
import 'package:flutter/material.dart';
import 'package:do_an_flutter/MainLayout.dart';
import 'package:do_an_flutter/theme/app_theme.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    ),
  );
}
