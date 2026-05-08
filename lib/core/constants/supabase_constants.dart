// ignore_for_file: avoid_hardcoded_credentials
class SupabaseConstants {
  SupabaseConstants._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zqihvfzxgrfsgbfziwly.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_SA8pfclEUJxx1n0TNpJVJg_Bo8aomSB',
  );

  static const String serviceRoleKey = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE_KEY',
    defaultValue: 'sb_secret_s0ajyKmnOfVUvf7CewF6pQ_gf-whbuW',
  );

  static void assertConfigured() {
    assert(url.isNotEmpty,
    'SUPABASE_URL is not set. Pass --dart-define=SUPABASE_URL=... at build time.');
    assert(anonKey.isNotEmpty,
    'SUPABASE_ANON_KEY is not set. Pass --dart-define=SUPABASE_ANON_KEY=... at build time.');
  }
}
