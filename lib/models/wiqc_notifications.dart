import 'package:hive/hive.dart';

// include the generated part file
part 'wiqc_notifications.g.dart';

@HiveType(typeId: 1)
class WiqcNotification {
  

  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  Map<String, dynamic> payload;

  @HiveField(3)
  bool isRead;

  WiqcNotification({
    required this.title, 
    required this.body, 
    required this.payload, 
    this.isRead = false
  });
}
