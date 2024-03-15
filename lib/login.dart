// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wateriqcloud_mobile/views/home_page.dart';
import 'services/auth_services/auth_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color lightBlue = const Color(0xFFD3E8F8);
  final Color darkBlue = const Color(0xFF17366D);
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  AuthUtils authLogin = AuthUtils();

  Future<void> _login() async {
    var auth = authLogin.isLoggedIn();
    if (await auth) {
      print("Yep, logged in");
    } else {
      print('Nope, not logged in');
    }
    print('Login function called');
    if (_formKey.currentState!.validate()) {
      print('Form validated, proceeding with login');
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      bool loginSuccess = await authLogin.login(_username, _password);

      setState(() {
        _isLoading = false;
      });

      if (loginSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeContent()),
        );
      } else {
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
                            _userCredentials(context),
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

  Widget _userCredentials(BuildContext context) => AutofillGroup(
          child: Column(
        children: [
          TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder()),
              autofillHints: const [AutofillHints.username],
              onSaved: (value) => _username = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              }),
          _gap(),
          TextFormField(
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      }),
                  border: const OutlineInputBorder()),
              autofillHints: const [AutofillHints.password],
              onSaved: (value) => _password = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              })
        ],
      ));

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
  Widget _logo() => SvgPicture.asset('assets/images/CircleLogo.svg');
}
