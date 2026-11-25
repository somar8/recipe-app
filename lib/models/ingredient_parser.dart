import 'recipe.dart';

/// Turns pasted text (from a website, a note, a message) into ingredients.
///
/// One ingredient per line, or a single line separated by commas. Understands:
///   "200 g flour", "200g flour", "2 eggs", "1/2 cup sugar", "½ tsp salt",
///   "1 1/2 cups milk", "2-3 cloves garlic", "1,5 dl melk", "1 cup of oats",
///   "Flour - 200 g", "Bloem: 200 gram", "Salt to taste", "2 EL Olivenöl",
///   "eine Prise Salz", "٢ كوب حليب", "ملعقة كبيرة زيت",
/// and ignores bullets, numbering, checkboxes and headings such as "Ingredients:".
/// English, Dutch, German and Arabic units are recognised.
List<RecipeIngredient> parseIngredients(String text) {
  var lines = _normalize(text)
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  // A single line like "flour, sugar, 2 eggs": split on commas (not on "1,5").
  if (lines.length == 1 && RegExp(r',(?!\d)').hasMatch(lines.first)) {
    lines = lines.first
        .split(RegExp(r',(?!\d)'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
  return [for (final line in lines) ?parseIngredientLine(line)];
}

/// One line -> an ingredient, or null for lines that aren't one (headings, empty).
RecipeIngredient? parseIngredientLine(String raw) {
  var line = _normalize(raw).trim();
  // List markers: "- ", "• ", "* ", "[ ] ", "☐ ", "1. ", "2) ". A bare "2 eggs" is an amount, not numbering.
  line = line.replaceFirst(
    RegExp(r'^(?:[-*•·◦▪–—]+|\[\s?[xX]?\s?\]|[☐☑✓✔]|\d+[.)](?!\d))\s*'),
    '',
  );
  line = line.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (line.isEmpty) return null;
  // Headings: "Ingredients:", "For the sauce:", "Ingrediënten" (a short line ending in ":" or a known word).
  final lower = line.toLowerCase();
  if (_headings.contains(lower.replaceAll(':', '').trim())) return null;
  if (line.endsWith(':') && !RegExp(r'\d').hasMatch(line)) return null;

  // 1. Amount first: "200 g flour", "2 eggs", "½ tsp salt".
  final front = RegExp(
    '^($_amount)\\s*(?:($_unit)(?=[\\s.,]|\$)\\.?)?\\s*(.*)\$',
    caseSensitive: false,
  ).firstMatch(line);
  if (front != null && (front.group(3)?.isNotEmpty ?? false)) {
    return _make(
      name: front.group(3)!,
      quantity: front.group(1)!,
      unit: front.group(2),
    );
  }

  // 2. Amount last: "Flour - 200 g", "Bloem: 200 gram", "Eggs 2".
  final back = RegExp(
    '^(.+?)\\s*[-–—:,]?\\s+($_amount)\\s*(?:($_unit)\\.?)?\$',
    caseSensitive: false,
  ).firstMatch(line);
  if (back != null) {
    return _make(
      name: back.group(1)!,
      quantity: back.group(2)!,
      unit: back.group(3),
    );
  }

  // 3. Unit without a number: "pinch of salt", "snufje zout".
  final unitOnly = RegExp(
    '^(a |an |een |eine |ein )?($_unit)\\s+(?:of |van |von |من )?(.+)\$',
    caseSensitive: false,
  ).firstMatch(line);
  if (unitOnly != null &&
      _wordUnits.contains(unitOnly.group(2)!.toLowerCase())) {
    // "ملعقة كبيرة زيت" (a spoonful, no number) means one.
    return _make(
      name: unitOnly.group(3)!,
      quantity: unitOnly.group(1) == null ? null : '1',
      unit: unitOnly.group(2),
    );
  }

  // 4. Just a name: "Salt to taste", "Fresh basil".
  return _make(name: line);
}

RecipeIngredient? _make({
  required String name,
  String? quantity,
  String? unit,
}) {
  var n = name.trim();
  // "1 cup of oats", "2 el van de olie": drop the joining word.
  n = n.replaceFirst(RegExp(r'^(of|van|von|من)\s+', caseSensitive: false), '');
  n = n.replaceFirst(RegExp(r'^[,:;\-–—]\s*'), '').trim();
  n = n.replaceFirst(RegExp(r'[,;]$'), '').trim();
  if (n.isEmpty) return null;
  final q = quantity?.replaceAll(RegExp(r'\s*[-–]\s*'), '-').trim();
  return RecipeIngredient(
    name: n.length > 200 ? n.substring(0, 200) : n,
    quantity: (q == null || q.isEmpty) ? null : q,
    unit: (unit == null || unit.isEmpty) ? null : unit.trim(),
  );
}

// "1", "1.5", "1,5", "1/2", "1 1/2", "½", "1½", "2-3", "2 - 3".
const _number = r'(?:\d+\s+\d+/\d+|\d+/\d+|\d+(?:[.,]\d+)?[½¼¾⅓⅔⅛]?|[½¼¾⅓⅔⅛])';
const _amount = '$_number(?:\\s*[-–]\\s*$_number)?';

// Units, longest first so "tbsp" wins over "tb" and "tablespoons" over "tablespoon".
const _unitWords = [
  // English
  'tablespoons',
  'tablespoon',
  'teaspoons',
  'teaspoon',
  'kilograms',
  'kilogram',
  'milliliters',
  'milliliter',
  'millilitres',
  'millilitre',
  'liters',
  'liter',
  'litres',
  'litre',
  'grams',
  'gram',
  'ounces',
  'ounce',
  'pounds',
  'pound',
  'pinches',
  'pinch',
  'handfuls',
  'handful',
  'bunches',
  'bunch',
  'sprigs',
  'sprig',
  'cloves',
  'clove',
  'slices',
  'slice',
  'pieces',
  'piece',
  'packages',
  'package',
  'packs',
  'pack',
  'sticks',
  'stick',
  'cans',
  'can',
  'tins',
  'tin',
  'jars',
  'jar',
  'cups',
  'cup',
  'dashes',
  'dash',
  'drops',
  'drop',
  'heads',
  'head',
  'leaves',
  'stalks',
  'stalk',
  'tbsp',
  'tbs',
  'tsp',
  'kg',
  'mg',
  'ml',
  'cl',
  'dl',
  'oz',
  'lbs', 'lb', 'pcs', 'pc', 'g', 'l',
  // Dutch
  'eetlepels',
  'eetlepel',
  'theelepels',
  'theelepel',
  'kopjes',
  'kopje',
  'snufjes',
  'snufje',
  'teentjes',
  'teentje',
  'tenen',
  'teen',
  'plakjes',
  'plakje',
  'blikjes',
  'blikje',
  'blikken',
  'blik',
  'zakjes',
  'zakje',
  'pakjes',
  'pakje',
  'stuks',
  'stuk',
  'takjes',
  'takje',
  'bosjes',
  'bosje',
  'handjes',
  'handje',
  'el',
  'tl',
  // German
  'esslöffel',
  'teelöffel',
  'messerspitzen',
  'messerspitze',
  'msp',
  'prisen',
  'prise',
  'zehen',
  'zehe',
  'becher',
  'dosen',
  'dose',
  'päckchen',
  'packungen',
  'packung',
  'pck',
  'bund',
  'stück',
  'stk',
  'scheiben',
  'scheibe',
  'tassen',
  'tasse',
  'gramm',
  'handvoll',
  'zweige',
  'zweig',
  'würfel',
  'blätter',
  // Arabic
  'ملاعق كبيرة',
  'ملعقة كبيرة',
  'ملعقتان كبيرتان',
  'ملاعق صغيرة',
  'ملعقة صغيرة',
  'ملعقتان صغيرتان',
  'ملعقة',
  'ملاعق',
  'أكواب',
  'كوبان',
  'كوب',
  'غرام',
  'جرام',
  'غ',
  'جم',
  'كيلوغرام',
  'كيلو',
  'كغ',
  'كجم',
  'مل',
  'ملل',
  'لتر',
  'رشة',
  'رشات',
  'قرصة',
  'فصوص',
  'فص',
  'حبات',
  'حبة',
  'علب',
  'علبة',
  'شرائح',
  'شريحة',
  'حزمة',
  'حفنة',
  'كيس',
];
// Longest first, so "ملعقة كبيرة" wins over "ملعقة" and "tbsp" over "tb".
final _unit = ([
  ..._unitWords,
]..sort((a, b) => b.length - a.length)).map(RegExp.escape).join('|');

/// Arabic and Persian digits become 0-9, the Arabic decimal sign and comma become
/// "," and the invisible direction marks that come along when copying are removed.
String _normalize(String text) {
  final out = StringBuffer();
  for (final r in text.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      out.writeCharCode(0x30 + r - 0x0660);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      out.writeCharCode(0x30 + r - 0x06F0);
    } else if (r == 0x066B || r == 0x060C) {
      out.write(','); // ٫ and ،
    } else if (r == 0x200E || r == 0x200F || r == 0x061C) {
      continue;
    } else {
      out.writeCharCode(r);
    }
  }
  return out.toString();
}

// Units that read naturally without a number ("pinch of salt").
const _wordUnits = {
  'pinch',
  'pinches',
  'dash',
  'handful',
  'bunch',
  'sprig',
  'snufje',
  'handje',
  'bosje',
  'takje',
  'prise',
  'handvoll',
  'bund',
  'zweig',
  'messerspitze',
  'msp',
  'رشة',
  'قرصة',
  'حفنة',
  'حزمة',
  'ملعقة كبيرة',
  'ملعقة صغيرة',
  'كوب',
};

const _headings = {
  'ingredients',
  'ingredient',
  'ingrediënten',
  'ingredienten',
  'you will need',
  'you\'ll need',
  'wat heb je nodig',
  'benodigdheden',
  'boodschappen',
  'shopping list',
  'zutaten',
  'einkaufsliste',
  'du brauchst',
  'المكونات',
  'مكونات',
  'المقادير',
  'مقادير',
};
