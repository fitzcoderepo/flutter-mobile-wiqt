import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/services/auth_services/auth_utils.dart';

import '../login.dart';
import '../views/home_page.dart';



class InitializerWidget extends StatefulWidget {
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
    final isLoggedIn = await AuthUtils().isLoggedIn();
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeContent()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You could return a splash screen widget here
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
