// Demo mode: the real app on made-up data, no Supabase project needed.
//   flutter run -d chrome -t lib/demo/main_demo.dart
// Nothing is saved: a page reload starts over. Not part of the Vercel build.
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../main.dart' show RecipeApp;
import '../services/auth_service.dart';
import '../services/theme_settings.dart';
import 'demo_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await useBundledFonts();
  await Supabase.initialize(
    url: 'https://demo.recipe-app.invalid',
    publishableKey: 'demo',
    httpClient: DemoBackend(),
  );
  AuthService().init();
  ThemeSettings().init();
  await Supabase.instance.client.auth.signInWithPassword(
    email: 'demo@example.com',
    password: 'demo-only',
  );
  runApp(const RecipeApp());
}
