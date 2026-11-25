import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../models/recipe.dart';
import '../services/group_service.dart';
import '../services/recipe_service.dart';

const _foodEmojis = ['🥘','🍝','🥗','🍜','🥩','🍰','🥪','🍛','🫕','🥙','🍲','🧁'];

String _recipeEmoji(String title) {
  final idx = title.codeUnits.fold(0, (a, c) => a + c).abs() % _foodEmojis.length;
  return _foodEmojis[idx];
}

class GroupDetailScreen extends StatefulWidget {
  final int id;
  const GroupDetailScreen({super.key, required this.id});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _groupService = GroupService();
  final _recipeService = RecipeService();

  GroupRecipes? _group;
  List<Recipe> _allRecipes = [];
  bool _loading = false;
  String? _error;

  List<Recipe> get _availableRecipes {
    final groupRecipeIds = _group?.recipes?.map((r) => r.id).toSet() ?? {};
    return _allRecipes.where((r) => !groupRecipeIds.contains(r.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final group = await _groupService.getById(widget.id);
      final allRecipes = await _recipeService.getAll();
      setState(() {
        _group = group;
        _allRecipes = allRecipes;
        _loading = false;
      });
    } catch (_) {
      setState(() { _error = 'Failed to load collection.'; _loading = false; });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Collection'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _groupService.delete(_group!.id!);
      if (mounted) context.go('/groups');
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to delete collection.'; });
    }
  }

  Future<void> _removeRecipe(int recipeId) async {
    try {
      final updated = await _groupService.removeRecipe(_group!.id!, recipeId);
      setState(() { _group = updated; });
    } catch (_) {
      setState(() { _error = 'Failed to remove recipe.'; });
    }
  }

  Future<void> _addRecipe(int recipeId) async {
    try {
      final updated = await _groupService.addRecipe(_group!.id!, recipeId);
      setState(() { _group = updated; });
    } catch (_) {
      setState(() { _error = 'Failed to add recipe.'; });
    }
  }

  void _showAddRecipeSheet() {
    final available = _availableRecipes;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All recipes are already in this collection.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Add Recipe', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...available.map((r) => ListTile(
                leading: Text(_recipeEmoji(r.title), style: const TextStyle(fontSize: 24)),
                title: Text(r.title),
                onTap: () {
                  Navigator.pop(context);
                  _addRecipe(r.id!);
                },
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Collection'),
        actions: group == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () async {
                    await context.push('/groups/${group.id}/edit');
                    _load();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  onPressed: _delete,
                ),
              ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)))
              : group == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (group.description != null && group.description!.isNotEmpty) ...[
                            Text(group.description!),
                            const SizedBox(height: 8),
                          ],
                          if (group.user != null) ...[
                            Text('By ${group.user!.username}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recipes (${group.recipes?.length ?? 0})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: _showAddRecipeSheet,
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (group.recipes == null || group.recipes!.isEmpty)
                            const Text('No recipes in this collection yet.')
                          else
                            ...group.recipes!.map((r) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Text(_recipeEmoji(r.title), style: const TextStyle(fontSize: 24)),
                                  title: Text(r.title),
                                  subtitle: r.description != null
                                      ? Text(r.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    tooltip: 'Remove from collection',
                                    onPressed: () => _removeRecipe(r.id!),
                                  ),
                                  onTap: () => context.push('/recipes/${r.id}'),
                                )),
                        ],
                      ),
                    ),
    );
  }
}