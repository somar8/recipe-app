import '../l10n/l10n.dart';
import 'recipe.dart';

/// Total time (prep + cook), or null when neither is set.
int? totalMinutesOf(Recipe r) {
  if (r.prepTimeMinutes == null && r.cookTimeMinutes == null) return null;
  return (r.prepTimeMinutes ?? 0) + (r.cookTimeMinutes ?? 0);
}

/// "How long may it take?" filter on the recipe list.
enum TimeFilter {
  any,
  under30,
  under60,
  hourPlus;

  String get label => switch (this) {
    any => tr.anyTime,
    under30 => tr.under30Min,
    under60 => tr.under1Hour,
    hourPlus => tr.oneHourOrMore,
  };

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
  all,
  mine,
  shared;

  String get label => switch (this) {
    all => tr.all,
    mine => tr.mine,
    shared => tr.sharedWithMe,
  };

  bool matches(Recipe r) => switch (this) {
    all => true,
    mine => r.isMine,
    shared => !r.isMine,
  };
}
