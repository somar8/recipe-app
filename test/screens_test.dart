// Every screen of the real app, on the demo data, at phone, tablet and laptop sizes:
// no layout overflow or errors, tap targets big enough, every button labelled, and
// readable text contrast. Also every screen at twice the normal text size.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/demo/demo_backend.dart';
import 'package:recipe_app/main.dart' show RecipeApp;
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/services/theme_settings.dart';
import 'package:recipe_app/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _items[key];
  @override
  Future<void> setItem({required String key, required String value}) async =>
      _items[key] = value;
  @override
  Future<void> removeItem({required String key}) async => _items.remove(key);
}

const _screens = [
  '/recipes',
  '/recipes/100',
  '/recipes/100/edit',
  '/recipes/new',
  '/groups',
  '/groups/106',
  '/groups/106/recipes/100',
  '/groups/106/edit',
  '/groups/new',
  '/account',
  '/account/friends',
  '/recipes/108', // shared by Anna
  '/groups/110', // Anna's shared collection
  '/groups/110/recipes/109',
];

const _sizes = {
  'phone': Size(375, 812),
  'tablet': Size(800, 1100),
  'laptop': Size(1280, 800),
};

Future<void> _show(
  WidgetTester tester,
  String path,
  Size size, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  await tester.pumpWidget(const RecipeApp());
  await tester.pump();
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(path);
  // Data arrives after a short pretend network delay; placeholders pulse meanwhile,
  // so pump in steps instead of waiting for everything to settle.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await useBundledFonts();
    await Supabase.initialize(
      url: 'https://demo.recipe-app.invalid',
      publishableKey: 'demo',
      httpClient: DemoBackend(),
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    AuthService().init();
    ThemeSettings().init();
    Recipe.currentUserId = () => Supabase.instance.client.auth.currentUser?.id;
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'demo@example.com',
      password: 'demo-only',
    );
  });

  for (final MapEntry(key: device, value: size) in _sizes.entries) {
    for (final path in _screens) {
      testWidgets('$path on a $device', (tester) async {
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final semantics = tester.ensureSemantics();
        await _show(tester, path, size);
        expect(tester.takeException(), isNull, reason: 'layout error');
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }

  for (final path in _screens) {
    testWidgets('$path on a phone in dark mode', (tester) async {
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      final semantics = tester.ensureSemantics();
      await _show(tester, path, _sizes['phone']!);
      expect(tester.takeException(), isNull, reason: 'layout error');
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    });
  }

  for (final path in _screens) {
    testWidgets('$path on a phone with text at 200%', (tester) async {
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _show(tester, path, _sizes['phone']!, textScale: 2);
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout error at large text',
      );
    });
  }

  testWidgets(
    'typing a name in Friends shows matching people with hidden emails',
    (tester) async {
      addTearDown(tester.view.reset);
      await _show(tester, '/account/friends', _sizes['phone']!);
      await tester.enterText(
        find.widgetWithText(TextField, 'Name or email'),
        'ann',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('Anna'), findsWidgets); // already a friend
      expect(find.text('Anneke Jansen'), findsOneWidget);
      expect(
        find.text('an***@example.com'),
        findsNWidgets(2),
      ); // Anna and Anneke
      expect(find.text('anneke.jansen@example.com'), findsNothing);
      expect(find.text('Friends'), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Add'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('Requested'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a broken link shows "Page not found" with a way back', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await _show(tester, '/recipes/abc', _sizes['phone']!);
    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go to your recipes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'an edit form that cannot load shows an error, never an empty form to save',
    (tester) async {
      addTearDown(tester.view.reset);
      await _show(tester, '/recipes/999999/edit', _sizes['phone']!);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Save changes'), findsNothing);
      expect(find.text('Recipe name'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a swiped-away recipe is really deleted when the Undo bar times out',
    (tester) async {
      addTearDown(tester.view.reset);
      await _show(tester, '/recipes', _sizes['phone']!);
      final card = find.text('Banana bread');
      expect(card, findsOneWidget);
      await tester.drag(card, const Offset(-500, 0));
      for (var i = 0; i < 40; i++) {
        await tester.pump(
          const Duration(milliseconds: 200),
        ); // 8 s: past the 5 s Undo window
      }
      expect(
        find.text('Undo'),
        findsNothing,
        reason: 'the bar closes by itself',
      );
      expect(
        find.text('Banana bread'),
        findsNothing,
        reason: 'and the recipe stays deleted',
      );
    },
  );
}
