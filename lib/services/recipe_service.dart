import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import 'data_changes.dart';
import 'errors.dart';

/// Recipes of the signed-in user. The database only ever returns the user's own rows.
class RecipeService {
  SupabaseClient get _db => Supabase.instance.client;

  static const _select =
      '*, recipe_ingredients(*), owner:recipe_profiles!recipes_owner_profile_fkey(display_name)';

  Future<List<Recipe>> getAll({String? title}) async {
    try {
      var query = _db.from('recipes').select(_select);
      if (title != null && title.isNotEmpty) {
        query = query.ilike('title', '%${_escapeLike(title)}%');
      }
      final rows = await query
          .order('id')
          .order('position', referencedTable: 'recipe_ingredients');
      return rows.map(Recipe.fromDb).toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to load recipes.'));
    }
  }

  Future<Recipe> getById(int id) async {
    final Map<String, dynamic>? row;
    try {
      row = await _db
          .from('recipes')
          .select(_select)
          .eq('id', id)
          .order('position', referencedTable: 'recipe_ingredients')
          .maybeSingle();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to load the recipe.'));
    }
    if (row == null) throw Exception('Recipe not found.');
    return Recipe.fromDb(row);
  }

  Future<Recipe> create(Recipe recipe) => _save(recipe.toDb());

  Future<Recipe> update(int id, Recipe recipe) =>
      _save({...recipe.toDb(), 'id': id});

  /// Saves the recipe and its ingredients in one step (database function save_recipe).
  Future<Recipe> _save(Map<String, dynamic> recipe) async {
    final int id;
    try {
      id = (await _db.rpc('save_recipe', params: {'recipe': recipe}) as num)
          .toInt();
      markDataChanged();
    } catch (e) {
      throw Exception(
        friendlyError(
          e,
          fallback: 'Failed to save recipe.',
          forbidden: 'Only the owner can change this recipe.',
        ),
      );
    }
    return getById(id);
  }

  /// Makes your own editable copy of a recipe (for example one a friend shared).
  /// Returns the new recipe's id.
  Future<int> copy(int id) async {
    try {
      final copyId =
          (await _db.rpc('copy_recipe', params: {'source_id': id}) as num)
              .toInt();
      markDataChanged();
      return copyId;
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Could not save a copy.'));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.from('recipes').delete().eq('id', id);
      markDataChanged();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to delete recipe.'));
    }
  }
}

/// `%` and `_` are wildcards in a LIKE pattern; search for them literally.
String _escapeLike(String text) =>
    text.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
