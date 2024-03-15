import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/wiqc_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static const route = '/notification_screen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<WiqcNotification>> listNotifications() async {
    var box = Hive.box<WiqcNotification>('notifications');
    return box.values.map((notification) {
      if (notification.isRead == null) {
        notification.isRead = false;
      }
      return notification;
    }).toList();
  }

  // used with setState() to rebuild the notification list after marked read or deleted
  int updateTrigger = 0;

  Future<void> markAsRead(int index) async {
    var box = Hive.box<WiqcNotification>('notifications');
    var notification = box.getAt(index);
    if (notification != null && !notification.isRead) {
      notification.isRead = true;
      await box.putAt(index, notification);
      setState(() => updateTrigger++);
    }
  }

  Future<void> removeNotification(int index) async {
    var box = Hive.box<WiqcNotification>('notifications');
    await box.deleteAt(index);
    setState(() => updateTrigger++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      // asynchronously fetch notifs from Hive with FutureBuilder
      // FutureBuilder builds itself based on the latest snapshot of interaction with a 'Future'
      // Allowing to display data that's being fetched asynchronously or show loading/error states
      body: FutureBuilder<List<WiqcNotification>>(
        future: listNotifications(),
        // using the state variable as a key
        key: ValueKey(updateTrigger),
        // snapshot instance of AsyncSnapshot<T>, holds info about the interaction with an async computation
        builder: (context, snapshot) {
          // connectionStates: none, waiting, active, done
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                WiqcNotification notification = snapshot.data![index];
                return Opacity(
                  opacity: notification.isRead ? 0.5 : 1.0,
                  child: Card(
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.body),
                      trailing: Row(mainAxisSize: MainAxisSize.min, 
                      children: [
                        TextButton(
                          child: Container(
                            padding: const EdgeInsets.only(right: 15.0),
                            decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    width: 1.0, color: Colors.black))),
                            child: Text(
                              'Mark as read',
                              style: TextStyle(
                              fontSize: 10,
                              color: notification.isRead ? Colors.grey : Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                          onPressed: () => markAsRead(index),
                        ),
                       
                        IconButton(
                          enableFeedback: true,
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => removeNotification(index))
                        
                      ]),
                      // trailing: Text(notification.payload.toString()),
                      tileColor:
                          notification.isRead ? Colors.grey[300] : Colors.white,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
