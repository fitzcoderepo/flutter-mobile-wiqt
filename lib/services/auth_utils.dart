
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../login.dart'; // Import the login screen

class AuthUtils {
  static Future<void> logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
