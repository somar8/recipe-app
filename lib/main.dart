import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipe_form_screen.dart';
import 'screens/group_list_screen.dart';
import 'screens/group_detail_screen.dart';
import 'screens/group_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean web links (/recipes/3 instead of /#/recipes/3); vercel.json sends every path to the app.
  usePathUrlStrategy();
  if (!isSupabaseConfigured) {
    runApp(const MissingConfigApp());
    return;
  }
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  AuthService().init();
  runApp(const RecipeApp());
}

final _router = GoRouter(
  initialLocation: '/recipes',
  refreshListenable: AuthService(),
  redirect: (context, state) {
    final isAuth = AuthService().isLoggedIn;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/login' || loc == '/register';
    if (loc == '/') return isAuth ? '/recipes' : '/login';
    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/recipes';
    return null;
  },
  routes: [
    // The email confirmation link lands on '/'; the redirect above sends it on.
    GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
    GoRoute(path: '/recipes', builder: (_, _) => const RecipeListScreen()),
    GoRoute(path: '/recipes/new', builder: (_, _) => const RecipeFormScreen()),
    GoRoute(
      path: '/recipes/:id',
      builder: (_, state) =>
          RecipeDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/recipes/:id/edit',
      builder: (_, state) =>
          RecipeFormScreen(editId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/groups', builder: (_, _) => const GroupListScreen()),
    GoRoute(path: '/groups/new', builder: (_, _) => const GroupFormScreen()),
    GoRoute(
      path: '/groups/:id',
      builder: (_, state) =>
          GroupDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/groups/:id/edit',
      builder: (_, state) =>
          GroupFormScreen(editId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

ThemeData _theme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    );

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe App',
      theme: _theme(),
      routerConfig: _router,
    );
  }
}

/// Shown when the app was built without Supabase settings.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: _theme(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Recipe App is not set up yet.\n\n'
              'Build or run it with the Supabase settings, for example:\n'
              'flutter run --dart-define-from-file=supabase.local.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
