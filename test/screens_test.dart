// Every screen of the real app, on the demo data, at phone, tablet and laptop sizes:
// no layout overflow or errors, tap targets big enough, every button labelled, and
// readable text contrast. Also every screen at twice the normal text size.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/demo/demo_backend.dart';
import 'package:recipe_app/main.dart' show RecipeApp;
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/ai_service.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/services/theme_settings.dart';
import 'package:recipe_app/services/locale_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _backend = DemoBackend();

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
  '/account/details',
  '/cook',
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

/// Saving the language also updates the (demo) account, which needs a real clock.
Future<void> _setLanguage(WidgetTester tester, Locale? locale) async {
  await tester.runAsync(() => LocaleSettings().setLanguage(locale));
}

/// Waits for an AI answer: the functions client encodes JSON on a background isolate,
/// which needs real time, while the demo's pretend network delay needs test time.
Future<void> _waitForAi(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await useBundledFonts();
    await Supabase.initialize(
      url: 'https://demo.recipe-app.invalid',
      publishableKey: 'demo',
      httpClient: _backend,
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    AuthService().init();
    ThemeSettings().init();
    SharedPreferences.setMockInitialValues({});
    await LocaleSettings().init();
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

  // Every screen in each other language: German has long words, Arabic runs right to
  // left. Phone size and at 150% text, where long words overflow first.
  for (final code in ['ar', 'nl', 'de']) {
    for (final path in _screens) {
      testWidgets('$path on a phone in $code', (tester) async {
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await _setLanguage(tester, Locale(code));
        addTearDown(() => _setLanguage(tester, null));
        final semantics = tester.ensureSemantics();
        await _show(tester, path, _sizes['phone']!);
        expect(tester.takeException(), isNull, reason: 'layout error in $code');
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await _show(tester, path, _sizes['phone']!, textScale: 1.5);
        expect(
          tester.takeException(),
          isNull,
          reason: 'layout error in $code at large text',
        );
        semantics.dispose();
      });
    }
  }

  testWidgets('Arabic runs right to left in the Arabic font', (tester) async {
    addTearDown(tester.view.reset);
    await _setLanguage(tester, const Locale('ar'));
    addTearDown(() => _setLanguage(tester, null));
    await _show(tester, '/account', _sizes['phone']!);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
    expect(
      Theme.of(context).textTheme.bodyMedium?.fontFamily,
      contains('IBMPlexSansArabic'),
    );
    expect(find.text('الحساب'), findsWidgets);
  });

  testWidgets('choosing a language in Account switches the app', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    addTearDown(() => _setLanguage(tester, null));
    await _show(tester, '/account', _sizes['phone']!);
    final card = find.widgetWithIcon(ListTile, Icons.language);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    for (var i = 0; i < 5; i++) {
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // the sheet slides up
    }
    await tester.tap(find.text('Deutsch'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(LocaleSettings().chosen, const Locale('de'));
    expect(find.text('Sprache'), findsOneWidget);
    expect(find.text('Konto'), findsWidgets);
  });

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

  testWidgets(
    'Friends still searches when the database lacks a newer function',
    (tester) async {
      addTearDown(tester.view.reset);
      _backend.missingFunctions.add(
        'list_sent_requests',
      ); // an out-of-date project
      addTearDown(_backend.missingFunctions.clear);
      await _show(tester, '/account/friends', _sizes['phone']!);
      expect(find.textContaining('Some lists didn\'t load'), findsOneWidget);
      expect(
        find.text('Anna'),
        findsWidgets,
        reason: 'the friends list still shows',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Name or email'),
        'jan',
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(
        find.text('Jan de Boer'),
        findsOneWidget,
        reason: 'and search still works',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pasting a list fills the ingredient rows in one go', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await _show(tester, '/recipes/new', _sizes['phone']!);
    await tester.ensureVisible(find.text('Paste a list'));
    await tester.tap(find.text('Paste a list'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(
        TextField,
        '200 g flour\n300 ml milk\n2 eggs\nPinch of salt',
      ),
      'Ingredients:\n- 250 g flour\n- 2 eggs\n- 1/2 tsp salt',
    );
    await tester.pump();
    expect(find.text('We found 3 ingredients'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add 3'));
    await tester.pumpAndSettle();
    // The rows now hold the pasted ingredients.
    expect(find.widgetWithText(TextField, 'flour'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'eggs'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1/2'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'tsp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the AI writes the steps from the ingredients', (tester) async {
    addTearDown(tester.view.reset);
    await _show(tester, '/recipes/100/edit', _sizes['phone']!);
    final button = find.text('Write the steps with AI');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();
    // The pancakes already have steps, so it asks first.
    expect(find.text('Replace your steps?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await _waitForAi(tester);
    final steps = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((f) => f.controller?.text ?? '')
        .firstWhere((t) => t.contains('Serve warm.'));
    expect(steps.split('\n'), hasLength(5));
    expect(steps, contains('Flour'));
    expect(find.textContaining('AI requests left today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Cook tab suggests meals and saves the one you pick', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await _show(tester, '/cook', _sizes['phone']!);
    expect(find.text('What can I cook?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'eggs, tomatoes, rice');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(InputChip), findsNWidgets(3));
    await tester.tap(find.text('Suggest meals'));
    await _waitForAi(tester);
    expect(find.text('Pick a meal'), findsOneWidget);
    expect(find.text('Quick eggs stir-fry'), findsOneWidget);
    expect(find.text("You'd need: Soy sauce"), findsOneWidget);
    expect(find.text('You have everything'), findsOneWidget);

    await tester.tap(find.text('Oven-baked eggs'));
    await tester.pumpAndSettle();
    expect(find.text('Save to my recipes'), findsOneWidget);
    await tester.tap(find.text('Save to my recipes'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    // Saved, and now open as a normal recipe.
    expect(
      GoRouter.of(
        tester.element(find.byType(Navigator).first),
      ).routerDelegate.currentConfiguration.uri.path,
      startsWith('/recipes/'),
    );
    expect(find.text('Oven-baked eggs'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the AI answers in the app language unless you pick another', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    addTearDown(() => AiService().answerLanguage.value = null);
    await _show(tester, '/cook', _sizes['phone']!);
    await tester.enterText(find.byType(TextField), 'eggs');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('AI language: English'), findsOneWidget);
    await tester.tap(find.text('Suggest meals'));
    await _waitForAi(tester);
    expect(_backend.lastAiLanguage, 'en');

    await tester.tap(find.text('AI language: English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();
    expect(find.text('AI language: العربية'), findsOneWidget);
    await tester.tap(find.text('Suggest other meals'));
    await _waitForAi(tester);
    expect(_backend.lastAiLanguage, 'ar');
    // The app itself stays in English.
    expect(find.text('What can I cook?'), findsOneWidget);
  });

  testWidgets('a used-up daily AI allowance says so', (tester) async {
    addTearDown(tester.view.reset);
    _backend.aiError = 'daily_limit';
    addTearDown(() => _backend.aiError = null);
    await _show(tester, '/cook', _sizes['phone']!);
    await tester.enterText(find.byType(TextField), 'eggs');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Suggest meals'));
    await _waitForAi(tester);
    expect(
      find.text("You've used today's 20 AI requests. Try again tomorrow."),
      findsOneWidget,
    );
  });

  testWidgets('Your details saves first and last name', (tester) async {
    addTearDown(tester.view.reset);
    await _show(tester, '/account/details', _sizes['phone']!);
    expect(find.widgetWithText(TextFormField, 'Samer'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save');
    expect(
      tester.widget<FilledButton>(save).onPressed,
      isNull,
      reason: 'nothing changed yet',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Haddad'),
      'Khalil',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    expect(
      find.text('Samer Khalil'),
      findsOneWidget,
      reason: 'the preview follows the fields',
    );
    await tester.tap(save);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Your details are saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
