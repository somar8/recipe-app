import 'package:flutter/material.dart';
import '../services/data_changes.dart';
import '../widgets/skeleton.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../models/recipe.dart';
import '../services/group_service.dart';
import '../services/recipe_service.dart';
import '../services/share_service.dart';
import '../widgets/share_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/food_art.dart';

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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Changes made elsewhere (another tab, a shared item) refresh this list quietly.
    dataChanges.addListener(_onDataChanged);
    _load();
  }

  void _onDataChanged() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    dataChanges.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _group == null;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _groupService.getById(widget.id),
        _recipeService.getAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _group = results[0] as GroupRecipes;
        _allRecipes = results[1] as List<Recipe>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  List<Recipe> get _recipesInGroup {
    // Use the full recipe (with ingredients) where we have it, for the card details.
    final byId = {for (final r in _allRecipes) r.id: r};
    return [
      for (final r in _group?.recipes ?? const <Recipe>[]) byId[r.id] ?? r,
    ];
  }

  List<Recipe> get _notInGroup {
    final inGroup = (_group?.recipes ?? const <Recipe>[])
        .map((r) => r.id)
        .toSet();
    // Only your own recipes can go into your collection (save a shared one as a copy first).
    return _allRecipes
        .where((r) => r.isMine && !inGroup.contains(r.id))
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  Future<void> _edit() async {
    await context.push('/groups/${widget.id}/edit');
    _load();
  }

  Future<void> _share() => showShareSheet(
    context,
    title: 'Share "${_group!.name}"',
    explanation:
        'Friends you pick can see this collection and every recipe in it, including ones you add later. Only you can change it.',
    load: () => ShareService().collectionSharedWith(widget.id),
    save: (ids) => ShareService().setCollectionSharedWith(widget.id, ids),
  );

  /// Removes a collection a friend shared from your list (it stays theirs).
  Future<void> _leave() async {
    final g = _group!;
    try {
      await ShareService().leaveCollection(g.id!);
      if (!mounted) return;
      showMessage(context, 'Removed "${g.name}" from your list');
      context.canPop() ? context.pop() : context.go('/groups');
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _delete() async {
    final g = _group!;
    final ok = await confirmDialog(
      context,
      title: 'Delete this collection?',
      message: '"${g.name}" will be deleted. The recipes in it are kept.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;
    try {
      await _groupService.delete(g.id!);
      if (!mounted) return;
      showMessage(context, 'Deleted "${g.name}"');
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _remove(Recipe r) async {
    try {
      final updated = await _groupService.removeRecipe(widget.id, r.id!);
      if (!mounted) return;
      setState(() => _group = updated);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            persist:
                false, // otherwise a bar with a button never closes by itself
            content: Text('Removed "${r.title}" from this collection'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _add([r.id!]),
            ),
          ),
        );
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _add(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final updated = await _groupService.addRecipes(widget.id, ids);
      if (!mounted) return;
      setState(() => _group = updated);
      showMessage(
        context,
        ids.length == 1 ? 'Added 1 recipe' : 'Added ${ids.length} recipes',
      );
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _openAddSheet() async {
    final candidates = _notInGroup;
    if (candidates.isEmpty) {
      showMessage(
        context,
        _allRecipes.isEmpty
            ? 'Add some recipes first.'
            : 'All your recipes are already in this collection.',
      );
      return;
    }
    final picked = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true, // covers the bottom bar too
      builder: (_) => _AddRecipesSheet(recipes: candidates),
    );
    if (picked != null) _add(picked);
  }

  Future<void> _openRecipe(Recipe r) async {
    await context.push('/groups/${widget.id}/recipes/${r.id}');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // The name is in the header below; the bar only holds actions.
        actions: group == null
            ? null
            : !group.isMine
            ? [
                PopupMenuButton<String>(
                  tooltip: 'More',
                  onSelected: (v) {
                    if (v == 'leave') _leave();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'leave',
                      child: ListTile(
                        leading: Icon(Icons.remove_circle_outline),
                        title: Text('Remove from my list'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Share with friends',
                  onPressed: _share,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: _edit,
                ),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  onSelected: (v) {
                    if (v == 'delete') _delete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: c.error),
                        title: Text(
                          'Delete collection',
                          style: TextStyle(color: c.error),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
      ),
      floatingActionButton:
          group == null || !group.isMine || (group.recipes?.isEmpty ?? true)
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add recipes'),
            ),
      body: PageWidth(
        maxWidth: 1100,
        child: group == null
            ? (_loading
                  ? const ListPageSkeleton(cards: 3, showSearch: false)
                  : ErrorState(
                      message: _error ?? 'Collection not found.',
                      onRetry: _load,
                    ))
            : RefreshIndicator(
                onRefresh: _load,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final recipes = _recipesInGroup;
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            Gap.lg,
                            Gap.sm,
                            Gap.lg,
                            Gap.lg,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!group.isMine) ...[
                                  SharedByBanner(
                                    ownerName: group.ownerName ?? 'A friend',
                                    message:
                                        'Recipes they add later show up here too. Open one to save a copy.',
                                  ),
                                  const SizedBox(height: Gap.lg),
                                ],
                                Row(
                                  children: [
                                    CollectionArt(name: group.name, size: 72),
                                    const SizedBox(width: Gap.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.name,
                                            style: t.headlineSmall,
                                          ),
                                          if (group.description?.isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: Gap.xs),
                                            Text(
                                              group.description!,
                                              style: t.bodyMedium?.copyWith(
                                                color: c.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: Gap.xs),
                                          Text(
                                            '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'}',
                                            style: t.labelLarge?.copyWith(
                                              color: c.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (recipes.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: Icons.playlist_add,
                              title: 'Nothing here yet',
                              message: group.isMine
                                  ? 'Pick recipes to add to this collection.'
                                  : 'Recipes ${group.ownerName ?? 'your friend'} adds will show up here.',
                              actionLabel: group.isMine ? 'Add recipes' : null,
                              onAction: group.isMine ? _openAddSheet : null,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              Gap.lg,
                              0,
                              Gap.lg,
                              96,
                            ),
                            sliver: SliverCardGrid(
                              columns: cardColumns(box.maxWidth),
                              itemCount: recipes.length,
                              itemBuilder: (_, i) {
                                final r = recipes[i];
                                return RecipeCard(
                                  recipe: r,
                                  onTap: () => _openRecipe(r),
                                  trailing: !group.isMine
                                      ? null
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          tooltip: 'Remove from collection',
                                          color: c.onSurfaceVariant,
                                          onPressed: () => _remove(r),
                                        ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}

/// Bottom sheet to pick several recipes at once, with search.
class _AddRecipesSheet extends StatefulWidget {
  const _AddRecipesSheet({required this.recipes});

  final List<Recipe> recipes;

  @override
  State<_AddRecipesSheet> createState() => _AddRecipesSheetState();
}

class _AddRecipesSheetState extends State<_AddRecipesSheet> {
  final Set<int> _picked = {};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final q = _query.trim().toLowerCase();
    final shown = widget.recipes
        .where((r) => q.isEmpty || r.title.toLowerCase().contains(q))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add recipes', style: t.titleLarge),
                const SizedBox(height: Gap.md),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search recipes',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              itemCount: shown.length,
              itemBuilder: (_, i) {
                final r = shown[i];
                final selected = _picked.contains(r.id);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (_) => setState(
                    () => selected ? _picked.remove(r.id) : _picked.add(r.id!),
                  ),
                  secondary: FoodArt(title: r.title, size: 44),
                  title: Text(
                    r.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.sm,
                Gap.lg,
                Gap.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _picked.isEmpty
                      ? null
                      : () => Navigator.pop(context, _picked.toList()),
                  child: Text(
                    _picked.isEmpty
                        ? 'Select recipes'
                        : 'Add ${_picked.length} ${_picked.length == 1 ? 'recipe' : 'recipes'}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
