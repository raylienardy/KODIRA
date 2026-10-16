import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await dotenv.load();
  final url = dotenv.maybeGet('SUPABASE_URL');
  final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');
  if (url == null || anonKey == null) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not set in .env');
  }
  await Supabase.initialize(url: url, publishableKey: anonKey);
}
