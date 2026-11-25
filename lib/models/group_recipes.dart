import 'recipe.dart';

class GroupUser {
  final int id;
  final String username;
  GroupUser({required this.id, required this.username});
  factory GroupUser.fromJson(Map<String, dynamic> json) =>
      GroupUser(id: json['id'], username: json['username']);
}

class GroupRecipes {
  int? id;
  String name;
  String? description;
  GroupUser? user;
  List<Recipe>? recipes;

  GroupRecipes({this.id, required this.name, this.description, this.user, this.recipes});

  factory GroupRecipes.fromJson(Map<String, dynamic> json) => GroupRecipes(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        user: json['user'] != null
            ? GroupUser.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        recipes: (json['recipes'] as List<dynamic>?)
            ?.map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (description != null) 'description': description,
      };
}