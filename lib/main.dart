import 'package:do_an_flutter/MainLayout.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tfwmzlzqglgwmjntshgx.supabase.co',
    anonKey: 'sb_publishable_ahkbKqGgMiLvIcqzW0rq-Q_xEZ12XZZ',
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainLayout(),
  ));
}
