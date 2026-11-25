import 'recipe.dart';

class GroupRecipes {
  int? id;
  String name;
  String? description;
  List<Recipe>? recipes;

  /// The account that owns this collection, and its name for collections friends shared.
  String? ownerId;
  String? ownerName;

  /// True for your own collections, false for ones a friend shared with you.
  bool get isMine => ownerId == null || ownerId == Recipe.currentUserId?.call();

  GroupRecipes({
    this.id,
    required this.name,
    this.description,
    this.recipes,
    this.ownerId,
    this.ownerName,
  });

  /// Reads a row of the `recipe_groups` table, with `recipes` nested when selected.
  factory GroupRecipes.fromDb(Map<String, dynamic> row) => GroupRecipes(
    id: (row['id'] as num?)?.toInt(),
    name: row['name'] ?? '',
    description: row['description'],
    ownerId: row['user_id'] as String?,
    ownerName: (row['owner'] as Map?)?['display_name'] as String?,
    recipes: (row['recipes'] as List<dynamic>?)
        ?.map((e) => Recipe.fromDb(e as Map<String, dynamic>))
        .toList(),
  );

  /// The columns the app writes; the owner is filled in by the database.
  Map<String, dynamic> toDb() => {
    'name': name,
    'description': (description == null || description!.isEmpty)
        ? null
        : description,
  };
}
