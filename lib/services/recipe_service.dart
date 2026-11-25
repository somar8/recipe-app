import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'auth_service.dart';

class RecipeService {
  static const _baseUrl = 'https://recipes-be-production.up.railway.app/api/recipes';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService().token}',
      };

  Future<List<Recipe>> getAll({String? title}) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters:
          (title != null && title.isNotEmpty) ? {'title': title} : null,
    );
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) throw Exception('Failed to load recipes.');
    return (jsonDecode(response.body) as List)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> getById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'), headers: _headers);
    if (response.statusCode != 200) throw Exception('Recipe not found.');
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Recipe> create(Recipe recipe) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(recipe.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save recipe.');
    }
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Recipe> update(int id, Recipe recipe) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(recipe.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Failed to save recipe.');
    return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete recipe.');
    }
  }
}