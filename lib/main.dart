import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wateriqcloud_mobile/models/wiqc_notifications.dart';
import 'package:wateriqcloud_mobile/views/notification_screen.dart';
import 'login.dart';
import 'views/home_page.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// entry point of flutter application
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ensure plugin services are initialized
  await initializeDateFormatting(); // initialize date formatting

  // initialize hive
  try {
    await Hive.initFlutter();
    // register adapter for hive boxes to use custom objects
    Hive.registerAdapter(WiqcNotificationAdapter());
    // open hive db box
    await Hive.openBox<WiqcNotification>('notifications');
  } catch (e) {
    if (kDebugMode) {
      print("There was an error registering the notification adapter");
    }
  }
  runApp(const MyApp());
}

// class used to define global app settings (themes, routes, title, etc...)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaterIQ Cloud',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Login route
        '/home': (context) => const HomePage(), // home route
        '/notification_screen': (context) => const NotificationScreen(), // notifications
      },
      navigatorKey: navigatorKey,
    );
  }
}
