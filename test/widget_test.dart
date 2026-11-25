import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/main.dart';
import 'package:recipe_app/models/group_recipes.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('without Supabase settings the app explains how to set it up', (tester) async {
    await tester.pumpWidget(const MissingConfigApp());
    expect(find.textContaining('not set up yet'), findsOneWidget);
  });

  group('Recipe', () {
    test('reads a database row with ingredients in their saved order', () {
      final r = Recipe.fromDb({
        'id': 7,
        'title': 'Pancakes',
        'prep_time_minutes': 10,
        'cook_time_minutes': null,
        'servings': 4,
        'recipe_ingredients': [
          {'id': 2, 'position': 1, 'name': 'milk', 'quantity': '500', 'unit': 'ml'},
          {'id': 1, 'position': 0, 'name': 'flour', 'quantity': '250', 'unit': 'g'},
        ],
      });
      expect(r.id, 7);
      expect(r.prepTimeMinutes, 10);
      expect(r.cookTimeMinutes, isNull);
      expect(r.ingredients!.map((i) => i.name), ['flour', 'milk']);
    });

    test('writes the shape save_recipe expects', () {
      final r = Recipe(
        title: 'Soup',
        servings: 2,
        ingredients: [RecipeIngredient(name: 'tomatoes', quantity: '', unit: 'kg')],
      );
      expect(r.toDb(), {
        'title': 'Soup',
        'description': null,
        'instructions': null,
        'prep_time_minutes': null,
        'cook_time_minutes': null,
        'servings': 2,
        'ingredients': [
          {'name': 'tomatoes', 'unit': 'kg'},
        ],
      });
    });
  });

  test('a group reads its nested recipes and writes only its own fields', () {
    final g = GroupRecipes.fromDb({
      'id': 3,
      'name': 'Breakfast',
      'description': '',
      'user_id': 'abc',
      'recipes': [
        {'id': 7, 'title': 'Pancakes'},
      ],
    });
    expect(g.recipes!.single.title, 'Pancakes');
    expect(g.toDb(), {'name': 'Breakfast', 'description': null});
  });

  group('friendlyError', () {
    test('explains a wrong password', () {
      expect(friendlyError(const AuthException('Invalid login credentials')),
          'Wrong email or password.');
    });
    test('explains an unconfirmed email', () {
      expect(friendlyError(const AuthException('Email not confirmed')), contains('confirm your email'));
    });
    test('explains invalid numbers', () {
      expect(friendlyError(const PostgrestException(message: 'violates check', code: '23514')),
          contains('above 0'));
    });
    test('explains being offline', () {
      expect(friendlyError(Exception('ClientException: Failed to fetch')), contains('No connection'));
    });
    test('explains being offline during sign-in, not the raw request', () {
      expect(
          friendlyError(AuthRetryableFetchException(
              message: 'ClientException: Failed to fetch, uri=https://x.supabase.co/auth/v1/token?grant_type=password')),
          contains('No connection'));
    });
    test('passes on a password rule', () {
      expect(friendlyError(const AuthException('Password should be at least 6 characters.')),
          'Password should be at least 6 characters.');
    });
  });
}
