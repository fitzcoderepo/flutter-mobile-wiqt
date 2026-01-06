import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_url.dart';
import '../../views/login.dart'; // Import the login screen
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticationService {
  Future<bool> login(String username, String password) async {
    var baseUrl = BaseUrl.getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        final token = data['token'];
        await SecureStorageManager.storage.write(key: 'auth_token', value: token);
        await SecureStorageManager.storage.write(
            key: 'user_groups', value: jsonEncode(data['groups']));

        print(response.body);
        return true; // Login successful

      } catch (e) {
        print('Failed to parse JSON: $e');
        return false;
      }
    } else {
      print('Server responded with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<List<String>> getUserGroups() async {
    final groups = await SecureStorageManager.storage.read(key: 'user_groups');
    if (groups != null) {
      return List<String>.from(jsonDecode(groups));
    } else {
      throw Exception('Failed to get user groups');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorageManager.storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout(BuildContext context) async {
    await SecureStorageManager.storage.delete(key: 'auth_token');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
