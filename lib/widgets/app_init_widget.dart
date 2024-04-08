import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/services/auth_service.dart';
import '../login.dart';
import '../views/home_page.dart';



class InitializerWidget extends StatefulWidget {
  const InitializerWidget({super.key});

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthenticationService().isLoggedIn();
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You could return a splash screen widget here
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}