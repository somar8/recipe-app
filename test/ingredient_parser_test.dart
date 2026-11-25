import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/models/ingredient_parser.dart';

/// "quantity|unit|name" for easy comparison.
String _p(String line) {
  final i = parseIngredientLine(line);
  return i == null ? 'null' : '${i.quantity ?? ''}|${i.unit ?? ''}|${i.name}';
}

void main() {
  test('amount and unit first', () {
    expect(_p('200 g flour'), '200|g|flour');
    expect(_p('200g flour'), '200|g|flour');
    expect(_p('2 tbsp olive oil'), '2|tbsp|olive oil');
    expect(_p('1 cup of oats'), '1|cup|oats');
    expect(_p('1,5 dl melk'), '1,5|dl|melk');
    expect(_p('2 el olijfolie'), '2|el|olijfolie');
  });

  test('amount without a unit', () {
    expect(_p('2 eggs'), '2||eggs');
    expect(
      _p('3 large onions'),
      '3||large onions',
      reason: '"l" of "large" is not litres',
    );
    expect(_p('2 lemons'), '2||lemons');
  });

  test('fractions and ranges', () {
    expect(_p('1/2 cup sugar'), '1/2|cup|sugar');
    expect(_p('½ tsp salt'), '½|tsp|salt');
    expect(_p('1 1/2 cups milk'), '1 1/2|cups|milk');
    expect(_p('1½ cups milk'), '1½|cups|milk');
    expect(_p('2-3 cloves garlic'), '2-3|cloves|garlic');
    expect(_p('2 - 3 teentjes knoflook'), '2-3|teentjes|knoflook');
  });

  test('amount at the end', () {
    expect(_p('Flour - 200 g'), '200|g|Flour');
    expect(_p('Bloem: 200 gram'), '200|gram|Bloem');
    expect(_p('Eggs 2'), '2||Eggs');
  });

  test('no amount', () {
    expect(_p('Salt to taste'), '||Salt to taste');
    expect(_p('pinch of salt'), '|pinch|salt');
    expect(_p('a pinch of salt'), '1|pinch|salt');
    expect(_p('Juice of 1 lemon'), '||Juice of 1 lemon');
  });

  test('list markers are removed, a leading amount is kept', () {
    expect(_p('- 200 g flour'), '200|g|flour');
    expect(_p('• 2 eggs'), '2||eggs');
    expect(_p('[ ] 1 tsp vanilla'), '1|tsp|vanilla');
    expect(_p('1. 200 g flour'), '200|g|flour');
    expect(_p('2) butter'), '||butter');
    expect(
      _p('1.5 kg potatoes'),
      '1.5|kg|potatoes',
      reason: '"1." followed by a digit is an amount',
    );
  });

  test('headings and empty lines are skipped', () {
    expect(_p('Ingredients:'), 'null');
    expect(_p('Ingrediënten'), 'null');
    expect(_p('For the sauce:'), 'null');
    expect(_p('   '), 'null');
  });

  test('a pasted block becomes a list', () {
    final list = parseIngredients('''
Ingredients:
- 200 g flour
- 300 ml buttermilk

• 2 eggs
Salt to taste
''');
    expect(list.map((i) => i.name), [
      'flour',
      'buttermilk',
      'eggs',
      'Salt to taste',
    ]);
  });

  test('one line separated by commas, without splitting decimals', () {
    final list = parseIngredients('flour, sugar, 1,5 dl milk, 2 eggs');
    expect(list.map((i) => i.name), ['flour', 'sugar', 'milk', 'eggs']);
    expect(list[2].quantity, '1,5');
  });

  test('German units', () {
    expect(_p('200 g Mehl'), '200|g|Mehl');
    expect(_p('2 EL Olivenöl'), '2|EL|Olivenöl');
    expect(_p('1 TL Zucker'), '1|TL|Zucker');
    expect(_p('3 Zehen Knoblauch'), '3|Zehen|Knoblauch');
    expect(_p('1 Becher Sahne'), '1|Becher|Sahne');
    expect(_p('eine Prise Salz'), '1|Prise|Salz');
    expect(_p('Prise Salz'), '|Prise|Salz');
    expect(_p('Mehl: 500 Gramm'), '500|Gramm|Mehl');
    expect(_p('Zutaten:'), 'null');
    expect(_p('Zutaten'), 'null');
  });

  test('Arabic units, digits and headings', () {
    expect(_p('200 غ طحين'), '200|غ|طحين');
    expect(_p('٢ كوب حليب'), '2|كوب|حليب');
    expect(_p('١٫٥ لتر ماء'), '1,5|لتر|ماء');
    expect(_p('2 ملعقة كبيرة زيت زيتون'), '2|ملعقة كبيرة|زيت زيتون');
    expect(_p('1 ملعقة صغيرة ملح'), '1|ملعقة صغيرة|ملح');
    expect(_p('3 فصوص ثوم'), '3|فصوص|ثوم');
    expect(_p('كوب من الأرز'), '|كوب|الأرز');
    expect(_p('رشة ملح'), '|رشة|ملح');
    expect(_p('3 بيض'), '3||بيض');
    expect(
      _p('\u200f٢ كوب سكر'),
      '2|كوب|سكر',
      reason: 'direction marks are removed',
    );
    expect(_p('المكونات:'), 'null');
    expect(_p('المقادير'), 'null');
  });

  test('an Arabic list separated by the Arabic comma', () {
    final list = parseIngredients('طحين، سكر، ٢ بيض');
    expect(list.map((i) => i.name), ['طحين', 'سكر', 'بيض']);
    expect(list.last.quantity, '2');
  });
}
