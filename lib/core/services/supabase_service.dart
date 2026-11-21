import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static const String supabaseUrl = 'https://tfwmzlzqglgwmjntshgx.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_ahkbKqGgMiLvIcqzW0rq-Q_xEZ12XZZ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
