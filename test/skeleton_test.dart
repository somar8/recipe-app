import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/theme/app_theme.dart';
import 'package:recipe_app/widgets/skeleton.dart';

void main() {
  for (final (name, widget) in [
    ('list', const ListPageSkeleton()),
    ('collections', const ListPageSkeleton(cards: 3, showSearch: false)),
    ('recipe page', const RecipePageSkeleton()),
  ]) {
    for (final width in [320.0, 375.0, 1280.0]) {
      testWidgets('$name placeholder fits at ${width.toInt()} px', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: widget),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('placeholders hold still when reduced motion is on', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: ListPageSkeleton()),
        ),
      ),
    );
    final fade = tester.widget<FadeTransition>(
      find
          .descendant(
            of: find.byType(Pulse),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1.0);
    await tester.pump(const Duration(milliseconds: 450));
    expect(fade.opacity.value, 1.0); // not pulsing
    expect(tester.takeException(), isNull);
  });
}
