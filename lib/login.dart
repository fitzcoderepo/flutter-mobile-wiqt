import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wateriqcloud_mobile/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isLocalIphone = false;

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else if (_isLocalIphone) {
      return "http://192.168.1.139:8000"; // local mac ip address
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }

  Future<void> _login() async {
    var baseUrl = getBaseUrl();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/login/'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': _username, 'password': _password}),
      );

      setState(() {
        _isLoading = false;
      });
      print('Request URL: $baseUrl/api/v1/login/');
      print('Request Body: ${json.encode({
            'username': _username,
            'password': _password
          })}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token =
            data['token']; // Assuming 'token' is the key in the JSON response
        print('Auth Token: $token');
        // TODO: Store the token securely (e.g., using flutter_secure_storage)
        await _storage.write(key: 'auth_token', value: token);
        // Navigate to your home screen or another appropriate screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'WaterIQ Cloud')),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username'),
                    onSaved: (value) => _username = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) => _password = value!,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
    );
  }
}
