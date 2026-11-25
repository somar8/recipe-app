class RecipeIngredient {
  int? id;
  String name;
  String? quantity;
  String? unit;

  RecipeIngredient({this.id, required this.name, this.quantity, this.unit});

  factory RecipeIngredient.fromDb(Map<String, dynamic> row) => RecipeIngredient(
        id: (row['id'] as num?)?.toInt(),
        name: row['name'] ?? '',
        quantity: row['quantity'],
        unit: row['unit'],
      );

  Map<String, dynamic> toDb() => {
        'name': name,
        if (quantity != null && quantity!.isNotEmpty) 'quantity': quantity,
        if (unit != null && unit!.isNotEmpty) 'unit': unit,
      };

  RecipeIngredient copy() =>
      RecipeIngredient(id: id, name: name, quantity: quantity, unit: unit);
}

class Recipe {
  int? id;
  String title;
  String? description;
  List<RecipeIngredient>? ingredients;
  String? instructions;
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  int? servings;

  Recipe({
    this.id,
    required this.title,
    this.description,
    this.ingredients,
    this.instructions,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
  });

  /// Reads a row of the `recipes` table, with `recipe_ingredients` nested when selected.
  factory Recipe.fromDb(Map<String, dynamic> row) {
    final rawIngredients = (row['recipe_ingredients'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .toList();
    rawIngredients?.sort((a, b) =>
        ((a['position'] as num?) ?? 0).compareTo((b['position'] as num?) ?? 0));
    return Recipe(
      id: (row['id'] as num?)?.toInt(),
      title: row['title'] ?? '',
      description: row['description'],
      ingredients: rawIngredients?.map(RecipeIngredient.fromDb).toList(),
      instructions: row['instructions'],
      prepTimeMinutes: (row['prep_time_minutes'] as num?)?.toInt(),
      cookTimeMinutes: (row['cook_time_minutes'] as num?)?.toInt(),
      servings: (row['servings'] as num?)?.toInt(),
    );
  }

  /// The shape the `save_recipe` database function expects.
  Map<String, dynamic> toDb() => {
        if (id != null) 'id': id,
        'title': title,
        'description': description,
        'instructions': instructions,
        'prep_time_minutes': prepTimeMinutes,
        'cook_time_minutes': cookTimeMinutes,
        'servings': servings,
        'ingredients': ingredients?.map((i) => i.toDb()).toList() ?? [],
      };
}
