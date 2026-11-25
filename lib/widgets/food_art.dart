import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Picks an icon from words in a recipe title (English, Dutch, German and Arabic), so a recipe gets a
/// fitting picture without photos. Unknown titles get a general food icon.
const _iconsByWord = <(List<String>, IconData)>[
  (
    [
      'pancake',
      'pannenkoek',
      'bread',
      'brood',
      'toast',
      'croissant',
      'bun',
      'broodje',
      'pfannkuchen',
      'brot',
      'brötchen',
      'فطائر',
      'فطيرة',
      'خبز',
      'مناقيش',
      'كرواسون',
    ],
    Icons.bakery_dining,
  ),
  (
    [
      'soup',
      'soep',
      'stew',
      'stoof',
      'chili',
      'curry',
      'suppe',
      'eintopf',
      'شوربة',
      'شوربه',
      'حساء',
      'يخنة',
      'طاجن',
    ],
    Icons.soup_kitchen,
  ),
  (
    [
      'salad',
      'salade',
      'bowl',
      'vegan',
      'veggie',
      'groente',
      'salat',
      'gemüse',
      'سلطة',
      'فتوش',
      'تبولة',
      'خضار',
    ],
    Icons.eco,
  ),
  (
    [
      'pasta',
      'spaghetti',
      'noodle',
      'noedel',
      'ramen',
      'lasagna',
      'lasagne',
      'macaroni',
      'nudel',
      'spätzle',
      'معكرونة',
      'مكرونة',
      'باستا',
      'لازانيا',
    ],
    Icons.ramen_dining,
  ),
  (['pizza', 'بيتزا'], Icons.local_pizza),
  (
    [
      'cake',
      'taart',
      'muffin',
      'cookie',
      'koek',
      'brownie',
      'dessert',
      'pie',
      'kuchen',
      'torte',
      'keks',
      'plätzchen',
      'كيك',
      'كعك',
      'كعكة',
      'حلوى',
      'بسبوسة',
      'كنافة',
      'معمول',
    ],
    Icons.cake,
  ),
  (['ice', 'ijs', 'sorbet', 'eis', 'بوظة', 'آيس'], Icons.icecream),
  (
    ['egg', 'ei', 'eieren', 'omelet', 'omelette', 'frittata', 'بيض', 'عجة'],
    Icons.egg_alt,
  ),
  (
    [
      'fish',
      'vis',
      'salmon',
      'zalm',
      'tuna',
      'tonijn',
      'shrimp',
      'garnaal',
      'sushi',
      'fisch',
      'lachs',
      'thunfisch',
      'garnele',
      'سمك',
      'سلمون',
      'تونة',
      'روبيان',
      'جمبري',
      'صيادية',
    ],
    Icons.set_meal,
  ),
  (
    [
      'burger',
      'sandwich',
      'wrap',
      'taco',
      'burrito',
      'برجر',
      'شطيرة',
      'ساندويش',
      'شاورما',
      'فلافل',
    ],
    Icons.lunch_dining,
  ),
  (
    [
      'rice',
      'rijst',
      'risotto',
      'paella',
      'biryani',
      'reis',
      'أرز',
      'رز',
      'كبسة',
      'برياني',
      'مندي',
      'مقلوبة',
    ],
    Icons.rice_bowl,
  ),
  (
    [
      'kebab',
      'skewer',
      'spies',
      'satay',
      'saté',
      'bbq',
      'grill',
      'spieß',
      'كباب',
      'شيش',
      'مشاوي',
      'كفتة',
    ],
    Icons.kebab_dining,
  ),
  (
    [
      'chicken',
      'kip',
      'beef',
      'rund',
      'steak',
      'pork',
      'varken',
      'lamb',
      'lam',
      'meat',
      'vlees',
      'hähnchen',
      'huhn',
      'rind',
      'schwein',
      'fleisch',
      'دجاج',
      'فراخ',
      'لحم',
      'ستيك',
    ],
    Icons.outdoor_grill,
  ),
  (
    [
      'coffee',
      'koffie',
      'tea',
      'thee',
      'latte',
      'kaffee',
      'tee',
      'قهوة',
      'شاي',
    ],
    Icons.local_cafe,
  ),
  (
    [
      'smoothie',
      'juice',
      'sap',
      'cocktail',
      'drink',
      'shake',
      'saft',
      'عصير',
      'مشروب',
    ],
    Icons.local_bar,
  ),
];

IconData foodIconFor(String title) {
  final titleWords = title
      .toLowerCase()
      .split(RegExp(r'[^a-z\u00df-\u00ff\u0621-\u064a]+'))
      .where((w) => w.isNotEmpty)
      // Arabic "the" (ال, also بال/وال/لل) is written onto the word: "الدجاج" is chicken.
      .map(
        (w) => w.replaceFirst(RegExp(r'^(?:وال|بال|فال|كال|ال|لل)(?=..)'), ''),
      );
  // A title word matches when it starts with a keyword ("pancakes"), or ends with one of
  // 4+ letters, for Dutch compounds ("kipsoep" is a soup). "rice" never matches "ice".
  bool matches(String word, String key) =>
      word.startsWith(key) || (key.length >= 4 && word.endsWith(key));
  for (final (keys, icon) in _iconsByWord) {
    if (titleWords.any((w) => keys.any((k) => matches(w, k)))) return icon;
  }
  return Icons.restaurant;
}

/// A stable colour index for a name, so the same recipe always gets the same colour.
int colorIndexFor(String name) =>
    name.toLowerCase().codeUnits.fold<int>(
      7,
      (a, c) => (a * 31 + c) & 0x7fffffff,
    ) %
    TileColors.count;

/// Rounded tile with a food icon, used for recipes in lists and on the recipe page.
class FoodArt extends StatelessWidget {
  const FoodArt({
    super.key,
    required this.title,
    this.size = 64,
    this.radius = Corners.sm,
  });

  final String title;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = TileColors.of(context, colorIndexFor(title));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(foodIconFor(title), color: fg, size: size * 0.44),
    );
  }
}

/// Wide banner version of [FoodArt] for the top of the recipe page.
class FoodBanner extends StatelessWidget {
  const FoodBanner({super.key, required this.title, this.height = 160});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = TileColors.of(context, colorIndexFor(title));
    return Container(
      height: height,
      width: double.infinity,
      color: bg,
      alignment: Alignment.center,
      child: Icon(foodIconFor(title), color: fg, size: height * 0.38),
    );
  }
}

/// Tile for a collection.
class CollectionArt extends StatelessWidget {
  const CollectionArt({super.key, required this.name, this.size = 56});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = TileColors.of(context, colorIndexFor(name));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Corners.sm),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.folder_special_outlined, color: fg, size: size * 0.46),
    );
  }
}

/// The app's mark, used on the sign-in and register screens.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_menu, color: c.onPrimary, size: size * 0.5),
    );
  }
}
