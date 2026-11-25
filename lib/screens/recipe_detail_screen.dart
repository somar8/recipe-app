import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

const _foodEmojis = ['🥘','🍝','🥗','🍜','🥩','🍰','🥪','🍛','🫕','🥙','🍲','🧁'];

String _recipeEmoji(String title) {
  final idx = title.codeUnits.fold(0, (a, c) => a + c).abs() % _foodEmojis.length;
  return _foodEmojis[idx];
}

class RecipeDetailScreen extends StatefulWidget {
  final int id;
  const RecipeDetailScreen({super.key, required this.id});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _recipeService = RecipeService();
  Recipe? _recipe;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _recipeService.getById(widget.id);
      setState(() { _recipe = data; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Recipe not found.'; _loading = false; });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _recipeService.delete(_recipe!.id!);
      if (mounted) context.go('/recipes');
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to delete recipe.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(recipe?.title ?? 'Recipe'),
        actions: recipe == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () async {
                    await context.push('/recipes/${recipe.id}/edit');
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
              : recipe == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              _recipeEmoji(recipe.title),
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            recipe.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(recipe.description!),
                          ],
                          const SizedBox(height: 16),
                          _InfoRow(
                            items: [
                              if (recipe.prepTimeMinutes != null) ('⏱ Prep', '${recipe.prepTimeMinutes} min'),
                              if (recipe.cookTimeMinutes != null) ('🍳 Cook', '${recipe.cookTimeMinutes} min'),
                              if (recipe.servings != null) ('🍽 Servings', '${recipe.servings}'),
                            ],
                          ),
                          if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...recipe.ingredients!.map((ing) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      const Text('• '),
                                      Text(
                                        [
                                          ing.name,
                                          if (ing.quantity != null && ing.quantity!.isNotEmpty) ing.quantity!,
                                          if (ing.unit != null && ing.unit!.isNotEmpty) ing.unit!,
                                        ].join(' '),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                          if (recipe.instructions != null && recipe.instructions!.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text('Instructions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(recipe.instructions!),
                          ],
                        ],
                      ),
                    ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: items
          .map((item) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(item.$1, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(item.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}