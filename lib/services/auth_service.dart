import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _baseUrl = 'https://recipes-be-production.up.railway.app/api/auth';

  String? _token;
  String? _username;

  String? get token => _token;
  String? get username => _username;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('auth_username');
  }

  Future<AuthResponse> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Invalid username or password.');
    }
    final data = AuthResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    await _storeAuth(data);
    return data;
  }

  Future<AuthResponse> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body.isNotEmpty ? response.body : 'Registration failed.');
    }
    final data = AuthResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    await _storeAuth(data);
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_username');
    _token = null;
    _username = null;
  }

  Future<void> _storeAuth(AuthResponse res) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', res.token);
    await prefs.setString('auth_username', res.username);
    _token = res.token;
    _username = res.username;
  }
}