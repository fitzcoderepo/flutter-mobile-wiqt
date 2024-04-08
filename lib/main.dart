import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wateriqcloud_mobile/firebase_options.dart';
import 'package:wateriqcloud_mobile/models/wiqc_notifications.dart';
import 'package:wateriqcloud_mobile/services/firebase/firebase_api.dart';
import 'login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_api_services/firebase_api.dart';
import 'widgets/app_init_widget.dart';
import 'views/notification_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/wiqc_notifications.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// entry point of flutter application
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ensure plugin services are initialized
  await initializeDateFormatting(); // initialize date formatting

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

try {
  // initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(FirebaseApi.handleBackgroundMessage);

  final firebaseApi = FirebaseApi(
    firebaseMessaging: FirebaseMessaging.instance,
    localNotifications: FlutterLocalNotificationsPlugin(),
  );

  await firebaseApi.initNotifications();
} catch (e) {
  if (kDebugMode) {
    print("There was an error somewhere with firebase: $e");
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
      title: 'WaterIQ Cloud',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Login route
        '/home': (context) => const HomePage(), // home route
      },
      navigatorKey: navigatorKey,
    );
  }
}
