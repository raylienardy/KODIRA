import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration injected at build time via `--dart-define`.
///
/// Release builds must not bundle `.env` (see `pubspec.yaml`); pass secrets on
/// the command line instead:
///
/// ```
/// flutter build apk --release \
///   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
const _supabaseUrlFromDefine = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKeyFromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');

bool _dotenvLoaded = false;

/// Loads a bundled `.env` file when one is present.
///
/// Release builds do not bundle `.env`, so this is a no-op there and the app
/// relies on the `--dart-define` values instead. For local development use:
/// `flutter run --dart-define-from-file=.env`.
Future<void> _loadDotenvIfBundled() async {
  try {
    await dotenv.load();
    _dotenvLoaded = true;
  } catch (_) {
    // No bundled `.env`: expected unless a local dev setup opts back in.
  }
}

/// Resolves a configuration value: `--dart-define` first, then `.env`.
///
/// `dotenv` throws `NotInitializedError` when no `.env` was loaded. In that
/// case return an empty string so `initSupabase` can raise one clear
/// `StateError` listing the missing keys.
String _resolve(String fromDefine, String dotenvKey) {
  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }
  if (!_dotenvLoaded) {
    return '';
  }
  return dotenv.maybeGet(dotenvKey) ?? '';
}

Future<void> initSupabase() async {
  await _loadDotenvIfBundled();
  final url = _resolve(_supabaseUrlFromDefine, 'SUPABASE_URL');
  final anonKey = _resolve(_supabaseAnonKeyFromDefine, 'SUPABASE_ANON_KEY');
  final missing = [
    if (url.isEmpty) 'SUPABASE_URL',
    if (anonKey.isEmpty) 'SUPABASE_ANON_KEY',
  ];
  if (missing.isNotEmpty) {
    throw StateError(
      '${missing.join(' and ')} not configured. Use --dart-define for '
      'release builds, or --dart-define-from-file=.env for development.',
    );
  }
  await Supabase.initialize(url: url, publishableKey: anonKey);
}
