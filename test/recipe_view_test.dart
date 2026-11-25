import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/theme/app_theme.dart';
import 'package:recipe_app/widgets/common.dart';

void main() {
  group('splitSteps', () {
    test('one step per line, typed numbering removed', () {
      expect(
        splitSteps(
          '1. Whisk the eggs\n2) Add milk\n\nStep 3: Fry\n- Serve warm\n• Enjoy',
        ),
        ['Whisk the eggs', 'Add milk', 'Fry', 'Serve warm', 'Enjoy'],
      );
    });
    test('keeps a quantity at the start of a step', () {
      expect(splitSteps('2 eggs, beaten\n1.5 kg flour, sifted'), [
        '2 eggs, beaten',
        '1.5 kg flour, sifted',
      ]);
    });
    test('nothing in, nothing out', () {
      expect(splitSteps(null), isEmpty);
      expect(splitSteps('  \n '), isEmpty);
    });
  });

  test('formatMinutes', () {
    expect(formatMinutes(45), '45 min');
    expect(formatMinutes(60), '1 h');
    expect(formatMinutes(80), '1 h 20 min');
  });

  test('totalMinutes adds prep and cook', () {
    expect(
      totalMinutes(
        Recipe(title: 'a', prepTimeMinutes: 10, cookTimeMinutes: 20),
      ),
      30,
    );
    expect(totalMinutes(Recipe(title: 'a', cookTimeMinutes: 20)), 20);
    expect(totalMinutes(Recipe(title: 'a')), isNull);
  });

  for (final scale in [1.0, 1.3, 2.0]) {
    testWidgets('a recipe card has no overflow at text size $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final recipe = Recipe(
        title: 'A rather long recipe name that will not fit on one line',
        description:
            'And a description that is also much too long for one line',
        prepTimeMinutes: 15,
        cookTimeMinutes: 70,
        servings: 4,
        ingredients: [
          RecipeIngredient(name: 'flour'),
          RecipeIngredient(name: 'milk'),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(375, 812),
              textScaler: TextScaler.linear(scale),
            ),
            child: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [RecipeCard(recipe: recipe, onTap: () {})],
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull); // no overflow
      expect(find.text('1 h 25 min'), findsOneWidget);
    });
  }
}
