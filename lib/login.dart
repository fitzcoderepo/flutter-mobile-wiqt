// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wateriqcloud_mobile/base_scaffold.dart';
import 'dart:convert';
import 'package:wateriqcloud_mobile/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final bool _isLocalIphone = false;

  String getBaseUrl() {
    if (Platform.isAndroid) {
      // return "http://10.0.2.2:8000";
      return "http://192.168.1.202:8000";
    } else if (_isLocalIphone) {
      return "http://192.168.1.139:8000"; // local mac ip address
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }


  Future<void> _login() async {
    print('Login function called');
    var baseUrl = getBaseUrl();
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
                double cardHeight = MediaQuery.of(context).size.height * 0.60;
                return Card(
                  elevation: 8,
                  child: Container(
                      padding: const EdgeInsets.all(32.0),
                      height: cardHeight,
                      width: cardWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _logo(),
                            _gap(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "WaterIQ Cloud",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            _gap(),
                            TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Enter your username',
                                  prefixIcon: Icon(Icons.account_circle),
                                  border: OutlineInputBorder()),
                              autofocus: true,
                              onSaved: (value) => _username = value!,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            _gap(),
                            TextFormField(
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                      icon: Icon(_isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      })),
                              autofocus: true,
                              onSaved: (value) => _password = value!,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            _gap(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  minimumSize: const Size(400, 50),
                                  maximumSize: const Size(400, 50),
                                  backgroundColor: darkBlue,
                                ),
                                child: const Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )),
                              ),
                            )
                          ],
                        ),
                      )),
                );
              })),
            ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
  Widget _logo() => Image.asset('assets/images/wiqt_crop.png');
}
