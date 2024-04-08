import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wiqc_notifications.dart';
import '../services/auth_services/auth_utils.dart';
import 'package:flutter_svg/svg.dart';

import '../views/notification_screen.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}
Future<bool> hasUnreadNotifications() async {
    final box = Hive.box<WiqcNotification>('notifications');
    return box.values.any((notification) => !notification.isRead);
  }

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SvgPicture.asset(
              'assets/images/WIQTLogoFullColor.svg',
              height: 45,
            ),
          ),
          ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('Notifications'),
              trailing: FutureBuilder<bool>(
                future: hasUnreadNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // Return an empty widget or a loader based on your preference
                  } else if (snapshot.hasData && snapshot.data == true) {
                    // If there are unread notifications, show an indicator
                    return Icon(Icons.circle, color: Colors.red, size: 12.0);
                  } else {
                    return SizedBox(); // No unread notifications
                  }
                },
              ),
              onTap: () {
                Navigator.of(context).pushNamed(NotificationScreen.route);
              }),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthenticationService.logout(context);
            },
          ),
        ],
      ),
    );
  }
}