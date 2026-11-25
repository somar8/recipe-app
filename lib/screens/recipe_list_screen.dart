import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';

const _foodEmojis = ['🥘','🍝','🥗','🍜','🥩','🍰','🥪','🍛','🫕','🥙','🍲','🧁'];

String _recipeEmoji(String title) {
  final idx = title.codeUnits.fold(0, (a, c) => a + c).abs() % _foodEmojis.length;
  return _foodEmojis[idx];
}

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  final _recipeService = RecipeService();
  List<Recipe> _recipes = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _recipeService.getAll(title: _searchController.text.trim());
      setState(() { _recipes = data; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load recipes.'; _loading = false; });
    }
  }

  Future<void> _deleteRecipe(int id) async {
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
      await _recipeService.delete(id);
      setState(() { _recipes = _recipes.where((r) => r.id != id).toList(); });
    } catch (_) {
      if (mounted) {
        setState(() { _error = 'Failed to delete recipe.'; });
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _loadRecipes(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _loadRecipes, child: const Text('Search')),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? const Center(child: Text('No recipes found.'))
                    : ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (_, i) {
                          final recipe = _recipes[i];
                          return ListTile(
                            leading: Text(
                              _recipeEmoji(recipe.title),
                              style: const TextStyle(fontSize: 28),
                            ),
                            title: Text(recipe.title),
                            subtitle: recipe.description != null
                                ? Text(recipe.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteRecipe(recipe.id!),
                            ),
                            onTap: () => context.push('/recipes/${recipe.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/recipes/new');
          _loadRecipes();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.go('/groups');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Collections'),
        ],
      ),
    );
  }
}