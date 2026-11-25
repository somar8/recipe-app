/// Supabase settings, passed in when the app is built or run:
///
///   flutter run --dart-define-from-file=supabase.local.json
///
/// `supabase.local.json` is not committed; copy `supabase.example.json` to start.
/// The publishable key is meant to be public: the database's access rules
/// protect the data. Never put the secret (service role) key in the app.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

bool get isSupabaseConfigured =>
    supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
