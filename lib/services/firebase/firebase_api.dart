import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:wateriqcloud_mobile/main.dart';
import 'package:wateriqcloud_mobile/services/auth_service.dart';
import 'package:wateriqcloud_mobile/views/notification_screen.dart';
import '../../models/wiqc_notifications.dart';

class FirebaseApi {
  // firebase and notification plugins instances
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin localNotifications;

  // Notif channel details
  static const String channelID = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important notifications.';

  FirebaseApi({
    required this.firebaseMessaging,
    required this.localNotifications,
  }) {
    // called as soon as an instance of the api is created
    _initLocalNotifications();
    _initPushNotifications();
  }

  // INITIALIZATION METHODS \\

  /// Init FCM and local notifs
  Future<void> initNotifications() async {
    try {
      await firebaseMessaging.requestPermission();
      final FCMToken = await firebaseMessaging.getToken();
      print('Token: $FCMToken');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Init local notifs settings
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // final iOS = IOSInitializationSettings();

    const initSettings = InitializationSettings(
      android: android,
    );

    await localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse);
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelID,
            channelName,
            description: channelDescription,
            importance: Importance.high,
          ),
        );
  }

  /// Set up push notif behavior
  Future<void> _initPushNotifications() async {
    /// Sets the presentation options for Apple notifications when received in the foreground.
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _handleInitialMessage();
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // MESSAGE HANDLING METHODS

  /// Handles backgroud message from FCM
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Ensure Hive is initialized in the background handler context
    final appDocDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);

    // Register the adapter if not already done
    if (!Hive.isAdapterRegistered(WiqcNotificationAdapter().typeId)) {
      Hive.registerAdapter(WiqcNotificationAdapter());
    }

    // Open the box
    Box<WiqcNotification> box;
    if (!Hive.isBoxOpen('notifications')) {
      box = await Hive.openBox<WiqcNotification>('notifications');
    } else {
      box = Hive.box<WiqcNotification>('notifications');
    }

    // Construct the notification object
    final notification = WiqcNotification(
      title: message.notification?.title ?? 'No Title',
      body: message.notification?.body ?? 'No Body',
      payload: message.data,
    );

    notification.isRead ??= false;

    // Save the notification to Hive
    await box.add(notification);

    // Consider keeping the box open or closing it based on your app's needs
    // await box.close();
  }

  /// Handles notif tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final loggedIn = await AuthenticationService().isLoggedIn();
    print("loggin in status: $loggedIn");
    if (loggedIn) {
      navigatorKey.currentState
          ?.pushNamed(NotificationScreen.route, arguments: message);
    } else {
      navigatorKey.currentState?.pushNamed('/');
    }
  }

  // PRIVATE UTILITY METHODS

  /// Handle initial msg if app was launched by tapping notif
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handles onMessage event from FCM when app is in foreground
  void _onMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    saveNotification(message);
    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelID,
          channelName,
          channelDescription: channelDescription,
          icon: '@mipmap/ic_launcher',
        ),
        // TODO: Add iOS notification details if necessary
      ),
      payload: jsonEncode(message.toMap()),
    );
  }

  /// Handles notif response
  void _handleNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      final String payload = response.payload ?? '';
      final messageMap = jsonDecode(payload);
      final message = RemoteMessage.fromMap(messageMap as Map<String, dynamic>);
      await _handleNotificationTap(message);
    }
  }

  /// Handles saving notification
  Future<void> saveNotification(RemoteMessage message) async {
    try {
      var box = Hive.box<WiqcNotification>('notifications');
      var notification = WiqcNotification(
        title: message.notification?.title ?? 'No Title',
        body: message.notification?.body ?? 'No Body',
        payload: message.data,
      );
      notification.isRead ??= false;
      print('Saving notification...');
      await box.add(notification);
      print('Notification saved');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }
}