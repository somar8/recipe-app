import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/recipe.dart';
import 'config.dart';
import 'services/auth_service.dart';
import 'services/theme_settings.dart';
import 'services/locale_settings.dart';
import 'l10n/l10n.dart';
import 'widgets/app_shell.dart';
import 'screens/account_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/not_found_screen.dart';
import 'theme/app_theme.dart';
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
  await useBundledFonts();
  if (!isSupabaseConfigured) {
    runApp(const MissingConfigApp());
    return;
  }
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  AuthService().init();
  Recipe.currentUserId = () => Supabase.instance.client.auth.currentUser?.id;
  ThemeSettings().init();
  await LocaleSettings().init();
  runApp(const RecipeApp());
}

final _rootKey = GlobalKey<NavigatorState>();

/// Builds a page from a number in the link, or "Not found" for a link like /recipes/abc.
Widget _withId(GoRouterState state, String name, Widget Function(int id) page) {
  final id = int.tryParse(state.pathParameters[name] ?? '');
  return id == null ? const NotFoundScreen() : page(id);
}

final _router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/recipes',
  // Any address the app doesn't know.
  errorBuilder: (_, _) => const NotFoundScreen(),
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

    // Forms open full-screen, over the navigation bar. Listed before the tabs so
    // '/recipes/new' is not read as a recipe id.
    GoRoute(
      path: '/recipes/new',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, state) => _fullScreen(state, const RecipeFormScreen()),
    ),
    GoRoute(
      path: '/recipes/:id/edit',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, state) => _fullScreen(
        state,
        _withId(state, 'id', (id) => RecipeFormScreen(editId: id)),
      ),
    ),
    GoRoute(
      path: '/groups/new',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, state) => _fullScreen(state, const GroupFormScreen()),
    ),
    GoRoute(
      path: '/groups/:id/edit',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, state) => _fullScreen(
        state,
        _withId(state, 'id', (id) => GroupFormScreen(editId: id)),
      ),
    ),

    // The three tabs. Each keeps its own history and scroll position.
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (_, _) => const RecipeListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      _withId(state, 'id', (id) => RecipeDetailScreen(id: id)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/groups',
              builder: (_, _) => const GroupListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      _withId(state, 'id', (id) => GroupDetailScreen(id: id)),
                  routes: [
                    // A recipe opened from a collection stays in the Collections tab.
                    GoRoute(
                      path: 'recipes/:rid',
                      builder: (_, state) => _withId(
                        state,
                        'rid',
                        (id) => RecipeDetailScreen(id: id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (_, _) => const AccountScreen(),
              routes: [
                GoRoute(
                  path: 'friends',
                  builder: (_, _) => const FriendsScreen(),
                ),
                GoRoute(
                  path: 'details',
                  builder: (_, _) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// A full-screen page that slides up, used for forms.
Page<void> _fullScreen(GoRouterState state, Widget child) =>
    MaterialPage(key: state.pageKey, fullscreenDialog: true, child: child);

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeSettings(), LocaleSettings()]),
      builder: (_, _) {
        final locale = LocaleSettings().effective;
        return MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(locale),
          darkTheme: AppTheme.dark(locale),
          themeMode: ThemeSettings().mode,
          // The chosen language, or the phone's when it's one the app speaks.
          locale: locale,
          supportedLocales: LocaleSettings.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router,
        );
      },
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
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
