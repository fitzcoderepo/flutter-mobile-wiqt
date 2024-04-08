// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wateriqcloud_mobile/core/theme/app_pallete.dart';
import 'package:wateriqcloud_mobile/services/auth_service.dart';
import 'package:wateriqcloud_mobile/views/home_page.dart';
import 'services/auth_utils.dart';

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
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    print('Login function called');
    if (_formKey.currentState!.validate()) {
      print('Form validated, proceeding with login');
      _formKey.currentState!.save();

   

      AuthenticationService authLogin = AuthenticationService();
      bool loginSuccess = await authLogin.login(_username, _password);


      if (loginSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
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
        backgroundColor: AppPallete.backgroundColor,
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset('assets/images/CircleLogo.svg'),
              const Text(
                "WaterIQ Cloud",
                style: TextStyle(
                    color: AppPallete.darkBlue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _userCredentials(context),
              const SizedBox(height: 20),
              _loginButton(context),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      text: 'Having trouble signing in? ',
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                    TextSpan(
                      text: 'Tap Here',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppPallete.blue, fontWeight: FontWeight.bold),
                    )
                  ]))
            ]),
          ),
        ));
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

  Widget _loginButton(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppPallete.darkBlue,
              AppPallete.blue,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.transparentColor,
            shadowColor: AppPallete.transparentColor,
            fixedSize: const Size(395, 55),
          ),
          child: const Text('Login',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 19,
                color: AppPallete.whiteColor,
              )),
        ),
      );

  Widget _gap() => const SizedBox(height: 16);
  Widget _logo() => Image.asset('assets/images/wiqt_crop.png');
}
