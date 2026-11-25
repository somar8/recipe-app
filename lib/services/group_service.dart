import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_recipes.dart';
import 'errors.dart';

/// Recipe groups ("collections") of the signed-in user, with the recipes in them.
class GroupService {
  SupabaseClient get _db => Supabase.instance.client;

  // recipe_group_items links groups and recipes, so Supabase can nest the recipes directly.
  static const _select =
      '*, recipes(*), owner:profiles!recipe_groups_owner_profile_fkey(display_name)';

  Future<List<GroupRecipes>> getAll() async {
    try {
      final rows = await _db.from('recipe_groups').select(_select).order('id');
      return rows.map(GroupRecipes.fromDb).toList();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to load groups.'));
    }
  }

  Future<GroupRecipes> getById(int id) async {
    final Map<String, dynamic>? row;
    try {
      row = await _db
          .from('recipe_groups')
          .select(_select)
          .eq('id', id)
          .maybeSingle();
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to load the group.'));
    }
    if (row == null) throw Exception('Group not found.');
    return GroupRecipes.fromDb(row);
  }

  Future<GroupRecipes> create(GroupRecipes group) async {
    try {
      final row = await _db
          .from('recipe_groups')
          .insert(group.toDb())
          .select(_select)
          .single();
      return GroupRecipes.fromDb(row);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to save group.'));
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
      return GroupRecipes.fromDb(row);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to save group.'));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _db.from('recipe_groups').delete().eq('id', id);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to delete group.'));
    }
  }

  Future<GroupRecipes> addRecipe(int groupId, int recipeId) async {
    try {
      await _db.from('recipe_group_items').upsert({
        'group_id': groupId,
        'recipe_id': recipeId,
      }, ignoreDuplicates: true);
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to add recipe.'));
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
    } catch (e) {
      throw Exception(friendlyError(e, fallback: 'Failed to remove recipe.'));
    }
    return getById(groupId);
  }
}
