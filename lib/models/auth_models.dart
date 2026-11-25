class AuthRequest {
  final String username;
  final String password;
  AuthRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  RegisterRequest({required this.username, required this.email, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'email': email, 'password': password};
}

class AuthResponse {
  final String token;
  final String username;
  AuthResponse({required this.token, required this.username});
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      AuthResponse(token: json['token'], username: json['username']);
}