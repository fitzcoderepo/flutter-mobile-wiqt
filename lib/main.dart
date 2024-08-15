import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:wateriqcloud_mobile/models/wiqc_notifications.dart';
import 'package:wateriqcloud_mobile/services/firebase/fcm_setup.dart';
import 'package:wateriqcloud_mobile/services/location_provider.dart';
import 'package:wateriqcloud_mobile/views/notification_screen.dart';
import 'views/login.dart';
import 'views/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase/firebase_options.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// entry point of flutter application
void main() async {
  // ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize date formatting
  await initializeDateFormatting();
  // initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    // initialize hive
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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                LocationProvider("f78835cf68e368e135f658c04088b04e")),
      ],
      child: const MyApp(),
    ),
  );
}

// class used to define global app settings (themes, routes, title, etc...)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    setupFirebaseMessaging();
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
        '/notification_screen': (context) =>
            const NotificationScreen(), // notifications
      },
      navigatorKey: navigatorKey,
    );
  }
}
