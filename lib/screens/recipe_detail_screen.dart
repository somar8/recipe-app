import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../widgets/skeleton.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/share_service.dart';
import '../widgets/share_sheet.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/food_art.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int id;
  const RecipeDetailScreen({super.key, required this.id});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _recipeService = RecipeService();
  Recipe? _recipe;
  bool _loading = true;
  String? _error;

  // Cooking progress: ticked ingredients and finished steps (kept while the page is open).
  final Set<int> _checked = {};
  final Set<int> _done = {};

  // The title shows in the top bar once the big header has scrolled away.
  final _scroll = ScrollController();
  bool _showTitle = false;

  void _onScroll() {
    final show =
        _scroll.hasClients && _scroll.offset > 200 - kToolbarHeight - 24;
    if (show != _showTitle) setState(() => _showTitle = show);
  }

  void _toggle(VoidCallback change) {
    HapticFeedback.selectionClick();
    setState(change);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _recipe == null;
      _error = null;
    });
    try {
      final data = await _recipeService.getById(widget.id);
      if (!mounted) return;
      setState(() {
        _recipe = data;
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

  Future<void> _edit() async {
    // The form returns the id only when something was saved; cancelling keeps your ticks.
    final saved = await context.push<int>('/recipes/${widget.id}/edit');
    if (saved == null) return;
    _checked.clear();
    _done.clear();
    _load();
  }

  bool _copying = false;

  Future<void> _share() => showShareSheet(
    context,
    title: context.l10n.shareTitle(_recipe!.title),
    explanation: context.l10n.shareRecipeExplanation,
    load: () => ShareService().recipeSharedWith(widget.id),
    save: (ids) => ShareService().setRecipeSharedWith(widget.id, ids),
  );

  Future<void> _saveCopy() async {
    setState(() => _copying = true);
    try {
      final id = await _recipeService.copy(widget.id);
      if (!mounted) return;
      // Keep the router: the page may be gone when Open is tapped.
      final router = GoRouter.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            persist:
                false, // otherwise a bar with a button never closes by itself
            content: Text(context.l10n.savedToYourRecipes),
            action: SnackBarAction(
              label: context.l10n.open,
              onPressed: () => router.go('/recipes/$id'),
            ),
          ),
        );
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  /// Removes a recipe a friend shared from your list (it stays theirs).
  Future<void> _leave() async {
    final r = _recipe!;
    try {
      await ShareService().leaveRecipe(r.id!);
      if (!mounted) return;
      // Still visible? Then it comes from a collection they shared.
      try {
        await _recipeService.getById(r.id!);
        if (mounted) {
          showMessage(
            context,
            context.l10n.alsoInSharedCollection(
              r.ownerName ?? context.l10n.yourFriend,
            ),
          );
        }
      } catch (_) {
        if (!mounted) return;
        showMessage(context, context.l10n.removedFromYourList(r.title));
        context.canPop() ? context.pop() : context.go('/recipes');
      }
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _delete() async {
    final r = _recipe!;
    final ok = await confirmDialog(
      context,
      title: context.l10n.deleteRecipeQuestion,
      message: context.l10n.deleteRecipeMessage(r.title),
      confirmLabel: context.l10n.delete,
    );
    if (!ok || !mounted) return;
    try {
      await _recipeService.delete(r.id!);
      if (!mounted) return;
      showMessage(context, context.l10n.deletedTitle(r.title));
      context.pop();
    } catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    if (recipe == null) {
      return Scaffold(
        extendBodyBehindAppBar: _loading,
        appBar: AppBar(backgroundColor: _loading ? Colors.transparent : null),
        body: _loading
            ? const RecipePageSkeleton()
            : ErrorState(
                message: _error ?? context.l10n.recipeNotFound,
                onRetry: _load,
              ),
      );
    }

    final c = Theme.of(context).colorScheme;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        edgeOffset: 120,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              title: AnimatedOpacity(
                opacity: _showTitle ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Text(
                  recipe.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
              ),
              backgroundColor: c.surface,
              leading: _RoundButton(
                icon: Icons.arrow_back,
                tooltip: context.l10n.back,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/recipes'),
              ),
              actions: recipe.isMine
                  ? [
                      _RoundButton(
                        icon: Icons.ios_share,
                        tooltip: context.l10n.shareWithFriends,
                        onPressed: _share,
                      ),
                      const SizedBox(width: Gap.xs),
                      _RoundButton(
                        icon: Icons.edit_outlined,
                        tooltip: context.l10n.edit,
                        onPressed: _edit,
                      ),
                      const SizedBox(width: Gap.xs),
                      PopupMenuButton<String>(
                        tooltip: context.l10n.more,
                        icon: const _RoundIcon(icon: Icons.more_horiz),
                        onSelected: (v) {
                          if (v == 'delete') _delete();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: c.error,
                              ),
                              title: Text(
                                context.l10n.deleteRecipe,
                                style: TextStyle(color: c.error),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Gap.sm),
                    ]
                  : [
                      PopupMenuButton<String>(
                        tooltip: context.l10n.more,
                        icon: const _RoundIcon(icon: Icons.more_horiz),
                        onSelected: (v) {
                          if (v == 'leave') _leave();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'leave',
                            child: ListTile(
                              leading: Icon(Icons.remove_circle_outline),
                              title: Text(context.l10n.removeFromMyList),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: Gap.sm),
                    ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: FoodBanner(title: recipe.title, height: 260),
              ),
            ),
            SliverToBoxAdapter(
              child: PageWidth(
                maxWidth: 1000,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Gap.lg,
                    Gap.xl,
                    Gap.lg,
                    Gap.xxl + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: _content(context, recipe),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Recipe recipe) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final total = totalMinutes(recipe);
    final ingredients = recipe.ingredients ?? const <RecipeIngredient>[];
    final steps = recipe.steps;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!recipe.isMine) ...[
          SharedByBanner(
            ownerName: recipe.ownerName ?? context.l10n.aFriend,
            message: context.l10n.sharedRecipeBanner,
            action: FilledButton.icon(
              onPressed: _copying ? null : _saveCopy,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text(context.l10n.saveACopy),
            ),
          ),
          const SizedBox(height: Gap.lg),
        ],
        Text(recipe.title, style: t.headlineMedium),
        if (recipe.description != null && recipe.description!.isNotEmpty) ...[
          const SizedBox(height: Gap.sm),
          Text(
            recipe.description!,
            style: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
          ),
        ],
        if (total != null || recipe.servings != null) ...[
          const SizedBox(height: Gap.lg),
          Row(
            spacing: Gap.sm,
            children: [
              if (recipe.prepTimeMinutes != null)
                _StatTile(
                  icon: Icons.timer_outlined,
                  label: context.l10n.prep,
                  value: formatMinutes(recipe.prepTimeMinutes!),
                ),
              if (recipe.cookTimeMinutes != null)
                _StatTile(
                  icon: Icons.local_fire_department_outlined,
                  label: context.l10n.cook,
                  value: formatMinutes(recipe.cookTimeMinutes!),
                ),
              if (recipe.prepTimeMinutes != null &&
                  recipe.cookTimeMinutes != null)
                _StatTile(
                  icon: Icons.schedule,
                  label: context.l10n.total,
                  value: formatMinutes(total!),
                ),
              if (recipe.servings != null)
                _StatTile(
                  icon: Icons.people_outline,
                  label: context.l10n.serves,
                  value: '${recipe.servings}',
                ),
            ],
          ),
        ],
      ],
    );

    final ingredientSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.ingredients,
          trailing: _checked.isEmpty
              ? Text(
                  '${ingredients.length}',
                  style: t.titleMedium?.copyWith(color: c.onSurfaceVariant),
                )
              : TextButton(
                  onPressed: () => setState(_checked.clear),
                  child: Text(context.l10n.clearTicks),
                ),
        ),
        if (ingredients.isEmpty)
          Text(
            context.l10n.noIngredientsYet,
            style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < ingredients.length; i++) ...[
                  if (i > 0) const Divider(indent: Gap.lg, endIndent: Gap.lg),
                  _IngredientRow(
                    ingredient: ingredients[i],
                    checked: _checked.contains(i),
                    onTap: () => _toggle(
                      () => _checked.contains(i)
                          ? _checked.remove(i)
                          : _checked.add(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );

    final stepSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.steps,
          trailing: _done.isEmpty
              ? (steps.isEmpty
                    ? null
                    : Text(
                        '${steps.length}',
                        style: t.titleMedium?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ))
              : TextButton(
                  onPressed: () => setState(_done.clear),
                  child: Text(context.l10n.startOver),
                ),
        ),
        if (steps.isEmpty)
          Text(
            context.l10n.noStepsYet,
            style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
          )
        else
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              number: i + 1,
              text: steps[i],
              done: _done.contains(i),
              current: !_done.contains(i) && (i == 0 || _done.contains(i - 1)),
              onTap: () => _toggle(
                () => _done.contains(i) ? _done.remove(i) : _done.add(i),
              ),
            ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, ingredientSection, stepSection],
          );
        }
        // Wide screens: ingredients next to the steps, like a cookbook page.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 340, child: ingredientSection),
                const SizedBox(width: Gap.xxl),
                Expanded(child: stepSection),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Icon button on a round light background, readable on top of the coloured header.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Gap.xs),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: _RoundIcon(icon: icon),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.92),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: c.onSurface),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Gap.md,
            horizontal: Gap.sm,
          ),
          decoration: BoxDecoration(
            color: c.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(Corners.sm),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: c.primary),
              const SizedBox(height: Gap.xs),
              Text(
                label,
                style: t.labelMedium?.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(value, style: t.titleSmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.checked,
    required this.onTap,
  });

  final RecipeIngredient ingredient;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final amount = ingredient.amountText;
    final faded = checked ? c.onSurfaceVariant.withValues(alpha: 0.7) : null;
    // Read out as one checkbox: "Flour, 200 g, checked".
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        label: [ingredient.name, if (amount.isNotEmpty) amount].join(', '),
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: Gap.md,
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    checked ? Icons.check_circle : Icons.radio_button_unchecked,
                    key: ValueKey(checked),
                    color: checked ? c.secondary : c.outline,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: t.bodyLarge?.copyWith(
                      color: faded,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (amount.isNotEmpty)
                  Text(
                    amount,
                    style: t.bodyMedium?.copyWith(
                      color: faded ?? c.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.done,
    required this.current,
    required this.onTap,
  });

  final int number;
  final String text;
  final bool done;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final Color badgeBg = done
        ? c.secondaryContainer
        : (current ? c.primary : c.primaryContainer);
    final Color badgeFg = done
        ? c.onSecondaryContainer
        : (current ? c.onPrimary : c.onPrimaryContainer);
    // Read out as "Step 2, up next: …" or "Step 1, done: …".
    return MergeSemantics(
      child: Semantics(
        checked: done,
        label: done
            ? context.l10n.stepDone(number, text)
            : current
            ? context.l10n.stepUpNext(number, text)
            : context.l10n.stepPlain(number, text),
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Corners.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Gap.md,
              horizontal: Gap.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? Icon(Icons.check, size: 18, color: badgeFg)
                      : Text(
                          '$number',
                          style: t.labelLarge?.copyWith(color: badgeFg),
                        ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      text,
                      style: t.bodyLarge?.copyWith(
                        height: 1.45,
                        color: done ? c.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
