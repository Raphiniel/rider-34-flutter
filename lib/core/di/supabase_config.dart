import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration — values are loaded from the `.env` file at runtime.
/// Never commit real keys as constants; keep them in `.env` (git-ignored).
class SupabaseConfig {
  SupabaseConfig._();

  /// Your Supabase Project URL  (key: supabaseUrl)
  static String get supabaseUrl =>
      dotenv.env['supabaseUrl'] ?? '';

  /// Your Supabase Anonymous (public) Key  (key: supabaseAnonKey)
  static String get supabaseAnonKey =>
      dotenv.env['supabaseAnonKey'] ?? '';
}
