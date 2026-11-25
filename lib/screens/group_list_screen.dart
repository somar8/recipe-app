import 'package:flutter/material.dart';
import '../services/data_changes.dart';
import '../widgets/skeleton.dart';
import 'package:go_router/go_router.dart';
import '../models/group_recipes.dart';
import '../services/group_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/food_art.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _groupService = GroupService();
  List<GroupRecipes> _groups = [];
  final Set<int> _hidden = {};
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
    if (mounted) _load(quiet: true);
  }

  @override
  void dispose() {
    dataChanges.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _groupService.getAll();
      if (!mounted) return;
      setState(() {
        _groups = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!quiet || _groups.isEmpty) _error = errorText(e);
      });
      if (quiet) showMessage(context, errorText(e));
    }
  }

  Future<void> _open(GroupRecipes g) async {
    await context.push('/groups/${g.id}');
    _load(quiet: true);
  }

  Future<void> _create() async {
    final id = await context.push<int>('/groups/new');
    await _load(quiet: true);
    if (id != null && mounted) {
      await context.push('/groups/$id');
      _load(quiet: true);
    }
  }

  void _swipeDelete(GroupRecipes g) {
    final id = g.id!;
    setState(() => _hidden.add(id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist:
              false, // otherwise a bar with a button never closes by itself
          content: Text('Deleted "${g.name}". Its recipes are kept.'),
          action: SnackBarAction(label: 'Undo', onPressed: () {}),
          duration: const Duration(seconds: 5),
        ),
      ).closed.then((reason) async {
        if (reason == SnackBarClosedReason.action) {
          if (mounted) setState(() => _hidden.remove(id));
          return;
        }
        try {
          await _groupService.delete(id);
          if (mounted) {
            setState(() {
              _groups.removeWhere((x) => x.id == id);
              _hidden.remove(id);
            });
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _hidden.remove(id));
          showMessage(context, errorText(e));
        }
      });
  }

  List<Widget> _grid(
    BuildContext context,
    double width,
    List<GroupRecipes> groups,
  ) => [
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      sliver: SliverCardGrid(
        columns: cardColumns(width),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final g = groups[i];
          return Dismissible(
            key: ValueKey('group-${g.id}'),
            // Only your own collections can be deleted.
            direction: g.isMine
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: const SwipeDeleteBackground(),
            onDismissed: (_) => _swipeDelete(g),
            child: _CollectionCard(group: g, onTap: () => _open(g)),
          );
        },
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final visible = _groups.where((g) => !_hidden.contains(g.id)).toList();

    return Scaffold(
      floatingActionButton: _groups.isEmpty && !_loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('New collection'),
            ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const ListPageSkeleton(cards: 3, showSearch: false)
            : _error != null
            ? ErrorState(message: _error!, onRetry: _load)
            : _groups.isEmpty
            ? EmptyState(
                icon: Icons.folder_special_outlined,
                title: 'Group your recipes',
                message:
                    'Make collections like "Weeknight dinners" or "Baking" to find recipes faster.',
                actionLabel: 'New collection',
                onAction: _create,
              )
            : RefreshIndicator(
                onRefresh: () => _load(quiet: true),
                child: PageWidth(
                  maxWidth: 1100,
                  child: LayoutBuilder(
                    builder: (context, box) => CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            Gap.lg,
                            Gap.lg,
                            Gap.lg,
                            Gap.lg,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your collections',
                                  style: t.headlineMedium,
                                ),
                                const SizedBox(height: Gap.xs),
                                Text(
                                  '${visible.length} ${visible.length == 1 ? 'collection' : 'collections'}',
                                  style: t.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ..._grid(
                          context,
                          box.maxWidth,
                          visible.where((g) => g.isMine).toList(),
                        ),
                        if (visible.any((g) => !g.isMine)) ...[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              Gap.lg,
                              Gap.md,
                              Gap.lg,
                              0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: SectionHeader(title: 'Shared with you'),
                            ),
                          ),
                          ..._grid(
                            context,
                            box.maxWidth,
                            visible.where((g) => !g.isMine).toList(),
                          ),
                        ],
                        const SliverToBoxAdapter(child: SizedBox(height: 96)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.group, required this.onTap});

  final GroupRecipes group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final recipes = group.recipes ?? const [];
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            children: [
              CollectionArt(name: group.name, size: 64),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.name,
                      style: t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      !group.isMine
                          ? 'From ${group.ownerName ?? 'a friend'} · ${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'}'
                          : group.description?.isNotEmpty == true
                          ? group.description!
                          : '${recipes.length} ${recipes.length == 1 ? 'recipe' : 'recipes'}',
                      style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Gap.sm),
                    // A peek at what's inside.
                    Row(
                      children: [
                        for (final r in recipes.take(4))
                          Padding(
                            padding: const EdgeInsets.only(right: Gap.xs),
                            child: FoodArt(title: r.title, size: 28, radius: 8),
                          ),
                        if (recipes.length > 4)
                          Text(
                            '+${recipes.length - 4}',
                            style: t.labelMedium?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                        if (recipes.isEmpty)
                          Text(
                            'Empty',
                            style: t.labelMedium?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
