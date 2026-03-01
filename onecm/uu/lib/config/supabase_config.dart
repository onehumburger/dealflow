import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for the UU app.
///
/// Configure your Supabase project credentials using `--dart-define`:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
///
/// Or replace the placeholder values below for development.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL.
  /// Override with `--dart-define=SUPABASE_URL=...`
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase anonymous key.
  /// Override with `--dart-define=SUPABASE_ANON_KEY=...`
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  /// Whether Supabase has been configured with real credentials.
  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      supabaseAnonKey != 'your-anon-key';

  /// Initialize Supabase. Safe to call even if not configured --
  /// auth features will simply be unavailable.
  static Future<void> initialize() async {
    if (!isConfigured) return;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Returns the Supabase client, or null if not configured.
  static SupabaseClient? get clientOrNull {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
