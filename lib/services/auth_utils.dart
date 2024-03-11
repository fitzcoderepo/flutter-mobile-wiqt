import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../login.dart'; // Import the login screen
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_url.dart';

class AuthUtils {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    var baseUrl = BaseUrl.getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token']; 
      await _storage.write(key: 'auth_token', value: token);
      return true; // Login successful
    } else {
      return false; // Login failed
    }
  }

  static Future<void> logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
