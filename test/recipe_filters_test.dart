import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/recipe_filters.dart';

Recipe _r({int? prep, int? cook, String? owner}) => Recipe(
  title: 'x',
  prepTimeMinutes: prep,
  cookTimeMinutes: cook,
  ownerId: owner,
);

void main() {
  setUp(() => Recipe.currentUserId = () => 'me');

  test('time filters use prep plus cook', () {
    final quick = _r(prep: 10, cook: 15); // 25
    final medium = _r(prep: 20, cook: 30); // 50
    final hour = _r(prep: 0, cook: 60); // 60
    final long = _r(prep: 30, cook: 90); // 120
    expect(
      [quick, medium, hour, long].where(TimeFilter.under30.matches).length,
      1,
    );
    expect(
      [quick, medium, hour, long].where(TimeFilter.under60.matches).length,
      2,
    );
    expect(
      [quick, medium, hour, long].where(TimeFilter.hourPlus.matches).length,
      2,
    );
    expect([quick, medium, hour, long].where(TimeFilter.any.matches).length, 4);
  });

  test(
    'exactly 30 minutes counts as under 30; exactly 60 counts as 1 hour or more',
    () {
      expect(TimeFilter.under30.matches(_r(cook: 30)), isTrue);
      expect(TimeFilter.under60.matches(_r(cook: 60)), isFalse);
      expect(TimeFilter.hourPlus.matches(_r(cook: 60)), isTrue);
    },
  );

  test('a recipe without a time only shows under "Any time"', () {
    final unknown = _r();
    expect(TimeFilter.any.matches(unknown), isTrue);
    for (final f in [
      TimeFilter.under30,
      TimeFilter.under60,
      TimeFilter.hourPlus,
    ]) {
      expect(f.matches(unknown), isFalse, reason: f.label);
    }
  });

  test('owner filter tells your recipes from shared ones', () {
    final mine = _r(owner: 'me'), shared = _r(owner: 'anna'), unsaved = _r();
    expect(OwnerFilter.mine.matches(mine), isTrue);
    expect(OwnerFilter.mine.matches(unsaved), isTrue);
    expect(OwnerFilter.shared.matches(shared), isTrue);
    expect(OwnerFilter.shared.matches(mine), isFalse);
    expect(OwnerFilter.all.matches(shared), isTrue);
  });
}
