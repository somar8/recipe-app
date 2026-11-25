import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group_recipes.dart';
import 'auth_service.dart';

class GroupService {
  static const _baseUrl = 'https://recipes-be-production.up.railway.app/api/group-recipes';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService().token}',
      };

  Future<List<GroupRecipes>> getAll() async {
    final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
    if (response.statusCode != 200) throw Exception('Failed to load groups.');
    return (jsonDecode(response.body) as List)
        .map((e) => GroupRecipes.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GroupRecipes> getById(int id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/$id'), headers: _headers);
    if (response.statusCode != 200) throw Exception('Group not found.');
    return GroupRecipes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GroupRecipes> create(GroupRecipes group) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(group.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save group.');
    }
    return GroupRecipes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GroupRecipes> update(int id, GroupRecipes group) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers,
      body: jsonEncode(group.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Failed to save group.');
    return GroupRecipes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/$id'), headers: _headers);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete group.');
    }
  }

  Future<GroupRecipes> addRecipe(int groupId, int recipeId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$groupId/recipes/$recipeId'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to add recipe.');
    return GroupRecipes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GroupRecipes> removeRecipe(int groupId, int recipeId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$groupId/recipes/$recipeId'),
      headers: _headers,
    );
    if (response.statusCode != 200) throw Exception('Failed to remove recipe.');
    return GroupRecipes.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}