class RecipeIngredient {
  int? id;
  String name;
  String? quantity;
  String? unit;

  RecipeIngredient({this.id, required this.name, this.quantity, this.unit});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => RecipeIngredient(
        id: json['id'],
        name: json['name'] ?? '',
        quantity: json['quantity'],
        unit: json['unit'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
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

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        ingredients: (json['ingredients'] as List<dynamic>?)
            ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        instructions: json['instructions'],
        prepTimeMinutes: json['prepTimeMinutes'],
        cookTimeMinutes: json['cookTimeMinutes'],
        servings: json['servings'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        if (description != null) 'description': description,
        'ingredients': ingredients?.map((i) => i.toJson()).toList() ?? [],
        if (instructions != null) 'instructions': instructions,
        if (prepTimeMinutes != null) 'prepTimeMinutes': prepTimeMinutes,
        if (cookTimeMinutes != null) 'cookTimeMinutes': cookTimeMinutes,
        if (servings != null) 'servings': servings,
      };
}