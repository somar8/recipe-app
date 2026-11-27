import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/l10n.dart';
import '../models/recipe.dart';
import 'errors.dart';
import 'locale_settings.dart';

/// One ingredient of a suggested meal; [have] is false for something still to buy.
class AiIngredient {
  const AiIngredient(this.ingredient, {required this.have});
  final RecipeIngredient ingredient;
  final bool have;
}

/// A meal the AI suggested from what you have. Becomes a normal recipe when saved.
class AiIdea {
  AiIdea({
    required this.title,
    required this.description,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final String description;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final List<AiIngredient> ingredients;
  final List<String> steps;

  List<AiIngredient> get missing => [
    for (final i in ingredients)
      if (!i.have) i,
  ];

  factory AiIdea.fromJson(Map<String, dynamic> j) => AiIdea(
    title: j['title'] as String,
    description: (j['description'] as String?) ?? '',
    prepMinutes: (j['prepMinutes'] as num).toInt(),
    cookMinutes: (j['cookMinutes'] as num).toInt(),
    servings: (j['servings'] as num).toInt(),
    ingredients: [
      for (final i in j['ingredients'] as List)
        AiIngredient(
          RecipeIngredient(
            name: i['name'] as String,
            quantity: i['quantity'] as String?,
            unit: i['unit'] as String?,
          ),
          have: i['have'] != false,
        ),
    ],
    steps: [for (final s in j['steps'] as List) s as String],
  );

  Recipe toRecipe() => Recipe(
    title: title,
    description: description.isEmpty ? null : description,
    instructions: steps.join('\n'),
    prepTimeMinutes: prepMinutes,
    cookTimeMinutes: cookMinutes,
    servings: servings,
    ingredients: [for (final i in ingredients) i.ingredient],
  );
}

/// The AI helper: writes steps for a recipe and suggests meals from what you have.
/// It runs in the Supabase Edge Function "ai" (supabase/functions/ai), which holds the
/// AI key and counts each account's daily allowance.
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Requests left today, once the first answer says so.
  final remaining = ValueNotifier<int?>(null);

  /// The language the AI answers in. null = the app's language (the default), so the
  /// answer follows the app until someone picks another one.
  final answerLanguage = ValueNotifier<Locale?>(null);

  /// The language actually used for the next answer.
  Locale get effectiveAnswerLanguage =>
      answerLanguage.value ?? LocaleSettings().effective;

  SupabaseClient get _db => Supabase.instance.client;
  String get _language => effectiveAnswerLanguage.languageCode;

  Future<Map<String, dynamic>> _ask(Map<String, dynamic> body) async {
    try {
      final res = await _db.functions.invoke(
        'ai',
        body: {...body, 'language': _language},
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      if (data['remaining'] is num) {
        remaining.value = (data['remaining'] as num).toInt();
      }
      return data;
    } on FunctionException catch (e) {
      final code = e.details is Map ? (e.details as Map)['error'] : null;
      if (code == 'daily_limit') remaining.value = 0;
      throw Exception(switch ((e.status, code)) {
        (0, _) => tr.errorOffline,
        (_, 'daily_limit') => tr.aiDailyLimit,
        (_, 'busy') => tr.aiBusy,
        (_, 'not_configured') || (404, _) => tr.aiNotSetUp,
        (_, 'confirm_email') => tr.errorConfirmEmailFirst,
        (401, _) => tr.errorSessionExpired,
        _ => tr.aiFailed,
      });
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.aiFailed));
    }
  }

  /// Steps for a recipe from its name, ingredients and times; one string per step.
  Future<List<String>> writeSteps(Recipe recipe) async {
    final data = await _ask({
      'task': 'steps',
      'recipe': {
        'title': recipe.title,
        'description': recipe.description,
        'prepMinutes': recipe.prepTimeMinutes,
        'cookMinutes': recipe.cookTimeMinutes,
        'servings': recipe.servings,
        'ingredients': [
          for (final i in recipe.ingredients ?? const <RecipeIngredient>[])
            {'name': i.name, 'quantity': i.quantity, 'unit': i.unit},
        ],
      },
    });
    return [for (final s in data['steps'] as List) s as String];
  }

  /// A few meals to choose from, built on what you have at home.
  Future<List<AiIdea>> suggestMeals(List<String> have) async {
    final data = await _ask({'task': 'ideas', 'have': have});
    return [
      for (final i in data['ideas'] as List)
        AiIdea.fromJson(Map<String, dynamic>.from(i as Map)),
    ];
  }
}
