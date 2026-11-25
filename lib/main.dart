import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipe_form_screen.dart';
import 'screens/group_list_screen.dart';
import 'screens/group_detail_screen.dart';
import 'screens/group_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const RecipeApp());
}

final _router = GoRouter(
  initialLocation: '/recipes',
  redirect: (context, state) {
    final isAuth = AuthService().isLoggedIn;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/login' || loc == '/register';
    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/recipes';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/recipes', builder: (_, __) => const RecipeListScreen()),
    GoRoute(path: '/recipes/new', builder: (_, __) => const RecipeFormScreen()),
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
    GoRoute(path: '/groups', builder: (_, __) => const GroupListScreen()),
    GoRoute(path: '/groups/new', builder: (_, __) => const GroupFormScreen()),
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

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}