import '../l10n/l10n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_recipes.dart';
import 'data_changes.dart';
import 'errors.dart';

/// Recipe groups ("collections") of the signed-in user, with the recipes in them.
class GroupService {
  SupabaseClient get _db => Supabase.instance.client;

  // recipe_group_items links groups and recipes, so Supabase can nest the recipes directly.
  static const _select =
      '*, recipes(*), owner:recipe_profiles!recipe_groups_owner_profile_fkey(display_name)';

  Future<List<GroupRecipes>> getAll() async {
    try {
      final rows = await _db
          .from('recipe_groups')
          .select(_select)
          .order('id')
          .order('title', referencedTable: 'recipes');
      return rows.map(GroupRecipes.fromDb).toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedLoadCollections));
    }
  }

  Future<GroupRecipes> getById(int id) async {
    final Map<String, dynamic>? row;
    try {
      row = await _db
          .from('recipe_groups')
          .select(_select)
          .eq('id', id)
          .order('title', referencedTable: 'recipes')
          .maybeSingle();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedLoadCollection));
    }
    if (row == null) throw Exception(tr.collectionNotFound);
    return GroupRecipes.fromDb(row);
  }

  Future<GroupRecipes> create(GroupRecipes group) async {
    try {
      final row = await _db
          .from('recipe_groups')
          .insert(group.toDb())
          .select(_select)
          .single();
      markDataChanged();
      return GroupRecipes.fromDb(row);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedSaveCollection));
    }
  }

  Future<GroupRecipes> update(int id, GroupRecipes group) async {
    try {
      final row = await _db
          .from('recipe_groups')
          .update(group.toDb())
          .eq('id', id)
          .select(_select)
          .single();
      markDataChanged();
      return GroupRecipes.fromDb(row);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedSaveCollection));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.from('recipe_groups').delete().eq('id', id);
      markDataChanged();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedDeleteCollection));
    }
  }

  Future<GroupRecipes> addRecipe(int groupId, int recipeId) =>
      addRecipes(groupId, [recipeId]);

  /// Adds several recipes in one request.
  Future<GroupRecipes> addRecipes(int groupId, List<int> recipeIds) async {
    if (recipeIds.isNotEmpty) {
      try {
        await _db.from('recipe_group_items').upsert([
          for (final id in recipeIds) {'group_id': groupId, 'recipe_id': id},
        ], ignoreDuplicates: true);
        markDataChanged();
      } catch (e) {
        throw Exception(friendlyError(e, fallback: tr.failedAddRecipes));
      }
    }
    return getById(groupId);
  }

  Future<GroupRecipes> removeRecipe(int groupId, int recipeId) async {
    try {
      await _db
          .from('recipe_group_items')
          .delete()
          .eq('group_id', groupId)
          .eq('recipe_id', recipeId);
      markDataChanged();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: tr.failedRemoveRecipe));
    }
    return getById(groupId);
  }
}
