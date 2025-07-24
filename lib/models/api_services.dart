import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServices {
  final String baseUrl;

  ApiServices({this.baseUrl = 'http://192.168.0.100'});

  // Get all users
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ofppt_be/crud_auth.php'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Get user by id
  Future<Map<String, dynamic>> fetchUser(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ofppt_be/crud_auth.php?id=$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('User not found');
    }
  }

  // Create new user
  Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String password,
    String? pin,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ofppt_be/crud_auth.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'pin': pin,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  // Update existing user
  Future<Map<String, dynamic>> updateUser({
    required int id,
    String? username,
    String? email,
    String? password,
    String? pin,
    String? role,
  }) async {
    Map<String, dynamic> data = {};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (pin != null) data['pin'] = pin;
    if (role != null) data['role'] = role;

    final response = await http.put(
      Uri.parse('$baseUrl/ofppt_be/crud_auth.php?id=$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user');
    }
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ofppt_be/crud_auth.php?id=$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete user');
    }
  }
}
