// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wateriqcloud_mobile/core/theme/app_pallete.dart';
import 'package:wateriqcloud_mobile/services/auth_services/auth_service.dart';
import 'package:wateriqcloud_mobile/views/home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final AuthenticationService authLogin = AuthenticationService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
  }

  void _initLocalNotifications() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            iOS: DarwinInitializationSettings(),
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool loginSuccess = await authLogin.login(_username, _password);

      // make sure after the asynchronous operation that the widget is still
      // part of the widget tree before attempting to use the context.
      // This check prevents issues caused by the widget being
      // disposed of while the async operation is in progress.
      if (!mounted) return;

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
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _logo()
            ),
            const Text(
              "WaterIQ Cloud",
              style: TextStyle(
                    color: AppPallete.darkBlue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
              ),
            ),
            _userCredentials(context),
            _loginButton(context),
            const Spacer(), // this pushes up the content to give more space on small devices
          ]
        )
      
      ),
    );
  }

  Widget _userCredentials(BuildContext context) => AutofillGroup(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
            Column(
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
                      },
                  ),
                  const SizedBox(height: 20),
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
                      },
                  ),
              ],
            ),
        ),
    );

  Widget _loginButton(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
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
        ),
  );

  Widget _logo() => SvgPicture.asset('assets/images/CircleLogo.svg');
}
