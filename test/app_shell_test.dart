import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/theme/app_theme.dart';
import 'package:recipe_app/widgets/app_shell.dart';

/// The real shell with stand-in pages, so no Supabase is needed.
GoRouter _router() => GoRouter(
  initialLocation: '/recipes',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(shell: shell),
      branches: [
        for (final path in ['/recipes', '/groups', '/account'])
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: path,
                builder: (_, _) => Scaffold(body: Text('page $path')),
              ),
            ],
          ),
      ],
    ),
  ],
);

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light(), routerConfig: _router()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a phone gets a bottom bar with three tabs', (tester) async {
    await _pump(tester, const Size(375, 812));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('page /recipes'), findsOneWidget);

    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    expect(find.text('page /groups'), findsOneWidget);
  });

  testWidgets('a tablet gets a side rail', (tester) async {
    await _pump(tester, const Size(800, 1000));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
  });

  testWidgets('a laptop gets the wide rail with the app name', (tester) async {
    await _pump(tester, const Size(1280, 800));
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
    expect(find.text('Recipe App'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('page /account'), findsOneWidget);
  });
}
