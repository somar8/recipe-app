import 'recipe.dart';

/// Total time (prep + cook), or null when neither is set.
int? totalMinutesOf(Recipe r) {
  if (r.prepTimeMinutes == null && r.cookTimeMinutes == null) return null;
  return (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
}

/// "How long may it take?" filter on the recipe list.
enum TimeFilter {
  any('Any time'),
  under30('Under 30 min'),
  under60('Under 1 hour'),
  hourPlus('1 hour or more');

  const TimeFilter(this.label);
  final String label;

  /// Recipes without a time only show under [any]: we can't promise they're quick.
  bool matches(Recipe r) {
    if (this == any) return true;
    final t = totalMinutesOf(r);
    if (t == null) return false;
    return switch (this) {
      under30 => t <= 30,
      under60 => t < 60,
      hourPlus => t >= 60,
      any => true,
    };
  }
}

/// "Whose recipes?" filter on the recipe list.
enum OwnerFilter {
  all('All'),
  mine('Mine'),
  shared('Shared with me');

  const OwnerFilter(this.label);
  final String label;

  bool matches(Recipe r) => switch (this) {
    all => true,
    mine => r.isMine,
    shared => !r.isMine,
  };
}
