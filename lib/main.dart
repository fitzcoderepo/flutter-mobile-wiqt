import 'package:flutter/material.dart';
import 'login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/home_page.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);
// entry point of flutter application
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ensure plugin services are initialized
  await initializeDateFormatting(); // initialize date formatting
  runApp(const MyApp());
}

// class used to define global app settings (themes, routes, title, etc...)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterIQ Cloud',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Login route
        '/home': (context) => const HomeContent(), // home route
      }
    );
  }
}



