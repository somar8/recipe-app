import 'package:flutter/material.dart';
import '../services/data_changes.dart';
import '../widgets/skeleton.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../models/recipe_filters.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

enum _Sort { newest, az, quickest }

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _recipeService = RecipeService();
  final _searchController = TextEditingController();

  List<Recipe> _recipes = [];
  final Set<int> _hidden =
      {}; // swiped away, waiting for the Undo window to pass
  bool _loading = true;
  String? _error;
  String _query = '';
  TimeFilter _time = TimeFilter.any;
  OwnerFilter _owner = OwnerFilter.all;

  bool get _filtering => _time != TimeFilter.any || _owner != OwnerFilter.all;

  void _clearFilters() => setState(() {
    _time = TimeFilter.any;
    _owner = OwnerFilter.all;
  });
  _Sort _sort = _Sort.newest;

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
    _searchController.dispose();
    super.dispose();
  }

  /// Loads all recipes. With [quiet], the current list stays on screen meanwhile.
  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _recipeService.getAll();
      if (!mounted) return;
      setState(() {
        _recipes = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (!quiet || _recipes.isEmpty) _error = errorText(e);
      });
      if (quiet) showMessage(context, errorText(e));
    }
  }

  List<Recipe> get _visible {
    final q = _query.trim().toLowerCase();
    final list = _recipes.where((r) {
      if (_hidden.contains(r.id)) return false;
      if (!_time.matches(r) || !_owner.matches(r)) return false;
      if (q.isEmpty) return true;
      return r.title.toLowerCase().contains(q) ||
          (r.description?.toLowerCase().contains(q) ?? false) ||
          (r.ingredients?.any((i) => i.name.toLowerCase().contains(q)) ??
              false);
    }).toList();
    switch (_sort) {
      case _Sort.newest:
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      case _Sort.az:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _Sort.quickest:
        list.sort(
          (a, b) => (totalMinutes(a) ?? 1 << 20).compareTo(
            totalMinutes(b) ?? 1 << 20,
          ),
        );
    }
    return list;
  }

  Future<void> _open(Recipe r) async {
    await context.push('/recipes/${r.id}');
    _load(quiet: true);
  }

  Future<void> _create() async {
    final id = await context.push<int>('/recipes/new');
    await _load(quiet: true);
    if (id != null && mounted) {
      await context.push('/recipes/$id');
      _load(quiet: true);
    }
  }

  /// Hides the recipe at once and deletes it for real unless Undo is tapped.
  void _swipeDelete(Recipe r) {
    final id = r.id!;
    setState(() => _hidden.add(id));
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            persist:
                false, // otherwise a bar with a button never closes by itself
            content: Text('Deleted "${r.title}"'),
            action: SnackBarAction(label: 'Undo', onPressed: () {}),
            duration: const Duration(seconds: 5),
          ),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) {
            if (mounted) setState(() => _hidden.remove(id));
            return;
          }
          try {
            await _recipeService.delete(id);
            if (mounted) {
              setState(() {
                _recipes.removeWhere((x) => x.id == id);
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

  String get _greeting {
    final h = DateTime.now().hour;
    final part = h < 12
        ? 'Good morning'
        : (h < 18 ? 'Good afternoon' : 'Good evening');
    final name = AuthService().username;
    return (name == null || name.contains('@'))
        ? part
        : '$part, ${name.split(' ').first}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _recipes.isEmpty && !_loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('New recipe'),
            ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const ListPageSkeleton()
            : _error != null
            ? ErrorState(message: _error!, onRetry: _load)
            : _recipes.isEmpty
            ? EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'Add your first recipe',
                message:
                    'Save the dishes you love, with ingredients and steps, and find them in seconds.',
                actionLabel: 'New recipe',
                onAction: _create,
              )
            : RefreshIndicator(
                onRefresh: () => _load(quiet: true),
                child: PageWidth(maxWidth: 1100, child: _list(context)),
              ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final visible = _visible;

    return LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Your recipes', style: t.headlineMedium),
                      ),
                      PopupMenuButton<_Sort>(
                        tooltip: 'Sort',
                        icon: const Icon(Icons.sort),
                        initialValue: _sort,
                        onSelected: (s) => setState(() => _sort = s),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _Sort.newest,
                            child: Text('Newest first'),
                          ),
                          PopupMenuItem(value: _Sort.az, child: Text('A to Z')),
                          PopupMenuItem(
                            value: _Sort.quickest,
                            child: Text('Quickest first'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText:
                          'Search ${_recipes.length} recipes or ingredients',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                  _FilterChips(
                    time: _time,
                    owner: _owner,
                    showOwner: _recipes.any((r) => !r.isMine),
                    onTime: (t) => setState(() => _time = t),
                    onOwner: (o) => setState(() => _owner = o),
                    onClear: _filtering ? _clearFilters : null,
                  ),
                  const SizedBox(height: Gap.md),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off,
                title: 'No matches',
                message: _filtering
                    ? 'Nothing fits "${[if (_owner != OwnerFilter.all) _owner.label, if (_time != TimeFilter.any) _time.label].join(' · ')}". Try another filter, or show all recipes.'
                    : 'Try another word, or show all recipes.',
                actionLabel: 'Show all',
                onAction: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                    _time = TimeFilter.any;
                    _owner = OwnerFilter.all;
                  });
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, 96),
              sliver: SliverCardGrid(
                columns: cardColumns(constraints.maxWidth),
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final r = visible[i];
                  return Dismissible(
                    key: ValueKey('recipe-${r.id}'),
                    // Only your own recipes can be deleted.
                    direction: r.isMine
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: const SwipeDeleteBackground(),
                    onDismissed: (_) => _swipeDelete(r),
                    child: RecipeCard(recipe: r, onTap: () => _open(r)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The filter chips under the search field. Each row picks one option.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.time,
    required this.owner,
    required this.showOwner,
    required this.onTime,
    required this.onOwner,
    required this.onClear,
  });

  final TimeFilter time;
  final OwnerFilter owner;
  final bool showOwner;
  final ValueChanged<TimeFilter> onTime;
  final ValueChanged<OwnerFilter> onOwner;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    Widget row(List<Widget> chips) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(spacing: Gap.sm, children: chips),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Gap.sm,
      children: [
        if (showOwner)
          row([
            for (final o in OwnerFilter.values)
              ChoiceChip(
                label: Text(o.label),
                selected: owner == o,
                onSelected: (_) => onOwner(o),
              ),
          ]),
        row([
          for (final t in TimeFilter.values)
            ChoiceChip(
              avatar: t == TimeFilter.any
                  ? null
                  : Icon(
                      Icons.schedule,
                      size: 16,
                      color: time == t ? c.onPrimary : c.secondary,
                    ),
              label: Text(t.label),
              selected: time == t,
              onSelected: (_) => onTime(t),
            ),
          if (onClear != null)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear'),
            ),
        ]),
      ],
    );
  }
}
