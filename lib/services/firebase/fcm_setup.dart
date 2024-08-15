import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // request perms for iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // get token
  String? token = await messaging.getToken(vapidKey: "");
  print("FCM Token: $token");

  // handle token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("FCM Token refreshed: $newToken");
    // Send new token to server if needed
  }).onError((err) {
    print("Error getting FCM token: $err");
  });

  // iOS, get APNS token
  if (Platform.isIOS) {
    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      print("APNS token: $apnsToken");
    }
  }

  // listen for incoming msgs
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a message while in foreground: ${message.messageId}");
    print("MSG data: $message.data");

    if (message.notification != null) {
      print('Message contained a notification: ${message.notification}');
    }
  });
}
