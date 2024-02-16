// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wateriqcloud_mobile/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/urls.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color lightBlue = const Color(0xFFD3E8F8);
  final Color darkBlue = const Color(0xFF17366D);
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;


  Future<void> _login() async {
    print('Login function called');
    var baseUrl = BaseUrl.getBaseUrl();
    if (_formKey.currentState!.validate()) {
      print('Form validated, proceeding with login');
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/login/'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': _username, 'password': _password}),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const MyHomePage(title: 'WaterIQ Cloud')),
        );
      } else {
        // Show error message
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Invalid username or password.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child:
                  Center(child: LayoutBuilder(builder: (context, constraints) {
                double cardWidth = MediaQuery.of(context).size.width > 800
                    ? 350
                    : MediaQuery.of(context).size.width * 0.85;
                double cardHeight = MediaQuery.of(context).size.height * 0.65;
                return Card(
                  elevation: 8,
                  child: Container(
                      padding: const EdgeInsets.all(12.0),
                      height: cardHeight,
                      width: cardWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _gap(),
                            _logo(),
                            _gap(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "WaterIQ Cloud",
                                style: TextStyle(
                                    color: darkBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            _gap(),
                            _usernameField(),
                            _gap(),
                            _passwordField(context),
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: _loginButton(context, cardWidth),
                            ),
                          ],
                        ),
                      )),
                );
              })),
            ),
    );
  }

  Widget _usernameField() => TextFormField(
        decoration: const InputDecoration(
          hintText: 'Enter your username',
          prefixIcon: Icon(Icons.account_circle),
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSaved: (value) => _username = value!,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
      );

  Widget _passwordField(BuildContext context) => TextFormField(
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          prefixIcon: const Icon(Icons.lock),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
        ),
        autofocus: true,
        onSaved: (value) => _password = value!,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      );

  Widget _loginButton(BuildContext context, cardWidth) => ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          // Dynamically size button width based on the container/card width
          minimumSize: Size(
              cardWidth * 0.9, 50), // Adjust the width as per the card width
          backgroundColor: darkBlue,
        ),
        child: const Text('Login',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
      );

  Widget _gap() => const SizedBox(height: 16);
  Widget _logo() => Image.asset('assets/images/wiqt_crop.png');
}
