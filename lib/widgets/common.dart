import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import 'food_art.dart';

/// Prep plus cook time, or null when neither is known.
int? totalMinutes(Recipe r) {
  if (r.prepTimeMinutes == null && r.cookTimeMinutes == null) return null;
  return (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
}

/// "45 min", "1 h", "1 h 20 min".
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60, m = minutes % 60;
  return m == 0 ? '$h h' : '$h h $m min';
}

/// Small icon + text, used for time, servings and counts.
class MetaLabel extends StatelessWidget {
  const MetaLabel({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.onSurfaceVariant),
        const SizedBox(width: Gap.xs),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// A recipe as a card: picture tile, title, one line of description, time and servings.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.trailing,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final total = totalMinutes(recipe);
    final count = recipe.ingredients?.length ?? 0;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            children: [
              FoodArt(title: recipe.title, size: 72),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        recipe.description!,
                        style: t.bodyMedium?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: Gap.sm),
                    Wrap(
                      spacing: Gap.md,
                      runSpacing: Gap.xs,
                      children: [
                        if (total != null)
                          MetaLabel(
                            icon: Icons.schedule,
                            text: formatMinutes(total),
                          ),
                        if (recipe.servings != null)
                          MetaLabel(
                            icon: Icons.people_outline,
                            text: '${recipe.servings}',
                          ),
                        if (count > 0)
                          MetaLabel(
                            icon: Icons.shopping_basket_outlined,
                            text: '$count ingredients',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Red background shown while swiping a card away to delete it.
class SwipeDeleteBackground extends StatelessWidget {
  const SwipeDeleteBackground({super.key, this.label = 'Delete'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: c.errorContainer,
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: Gap.sm),
          Icon(Icons.delete_outline, color: c.onErrorContainer),
        ],
      ),
    );
  }
}

/// A friendly screen for "nothing here yet", with one clear next step.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: c.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: c.onPrimaryContainer),
              ),
              const SizedBox(height: Gap.lg),
              Text(title, style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: Gap.sm),
              Text(
                message,
                style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: Gap.xl),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What went wrong, and a button to try again.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: c.onSurfaceVariant),
            const SizedBox(height: Gap.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: Gap.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title with an optional action on the right, e.g. "Ingredients · 4".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl, bottom: Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Asks before something that can't be undone. Returns true when confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final c = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: c.error,
                  foregroundColor: c.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Shows a short message at the bottom of the screen.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Readable text of an error thrown by the services.
String errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

/// Number of grid columns for card lists at a given width.
int cardColumns(double width) => width >= 840 ? 2 : 1;

/// Cards in [columns] columns. Each row is as tall as its tallest card, so nothing is
/// cut off at large text sizes.
class SliverCardGrid extends StatelessWidget {
  const SliverCardGrid({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int columns;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final rows = (itemCount / columns).ceil();
    return SliverList.builder(
      itemCount: rows,
      itemBuilder: (context, row) {
        if (columns == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Gap.md),
            child: itemBuilder(context, row),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: Gap.md),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) const SizedBox(width: Gap.md),
                  Expanded(
                    child: row * columns + col < itemCount
                        ? itemBuilder(context, row * columns + col)
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
