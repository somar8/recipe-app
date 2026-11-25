import 'package:supabase_flutter/supabase_flutter.dart';
import 'data_changes.dart';
import 'errors.dart';

/// What you share with which friends. Only the owner can share; friends only read.
class ShareService {
  SupabaseClient get _db => Supabase.instance.client;
  String get _me => Supabase.instance.client.auth.currentUser!.id;

  static const _recipes = ('recipe_shares', 'recipe_id');
  static const _collections = ('collection_shares', 'group_id');

  Future<Set<String>> _sharedWith((String, String) table, int id) async {
    try {
      final rows = await _db
          .from(table.$1)
          .select('friend_id')
          .eq(table.$2, id);
      return {for (final r in rows) r['friend_id'] as String};
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Failed to load who this is shared with.'),
      );
    }
  }

  /// Makes the share list exactly [friendIds]: adds the new ones, removes the rest.
  Future<void> _setSharedWith(
    (String, String) table,
    int id,
    Set<String> friendIds,
  ) async {
    try {
      final current = await _sharedWith(table, id);
      final add = friendIds.difference(current);
      final remove = current.difference(friendIds);
      if (add.isNotEmpty) {
        await _db.from(table.$1).insert([
          for (final f in add) {table.$2: id, 'friend_id': f},
        ]);
      }
      if (remove.isNotEmpty) {
        await _db
            .from(table.$1)
            .delete()
            .eq(table.$2, id)
            .inFilter('friend_id', remove.toList());
      }
      markDataChanged();
    } catch (e) {
      throw Exception(
        friendlyError(
          e,
          fallback: 'Could not update sharing. Please try again.',
          forbidden:
              'You can only share your own recipes and collections, and only with friends.',
        ),
      );
    }
  }

  /// Removes something a friend shared with you from your own list.
  Future<void> _leave((String, String) table, int id) async {
    try {
      await _db.from(table.$1).delete().eq(table.$2, id).eq('friend_id', _me);
      markDataChanged();
    } catch (e) {
      throw Exception(
        friendlyError(e, fallback: 'Could not remove it. Please try again.'),
      );
    }
  }

  Future<Set<String>> recipeSharedWith(int recipeId) =>
      _sharedWith(_recipes, recipeId);
  Future<void> setRecipeSharedWith(int recipeId, Set<String> friendIds) =>
      _setSharedWith(_recipes, recipeId, friendIds);
  Future<void> leaveRecipe(int recipeId) => _leave(_recipes, recipeId);

  Future<Set<String>> collectionSharedWith(int groupId) =>
      _sharedWith(_collections, groupId);
  Future<void> setCollectionSharedWith(int groupId, Set<String> friendIds) =>
      _setSharedWith(_collections, groupId, friendIds);
  Future<void> leaveCollection(int groupId) => _leave(_collections, groupId);
}
