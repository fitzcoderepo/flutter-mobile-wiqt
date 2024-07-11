import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wateriqcloud_mobile/main.dart';

class UnitDetailsCard extends StatelessWidget {
  // Properties
  final String detailsKey;
  final dynamic value;
  // Constructor
  const UnitDetailsCard({
    super.key,
    required this.detailsKey,
    required this.value,
  });

  // Methods
  void someMethod() {
    // Method implementation
  }

  @override
  Widget build(BuildContext context) {
    Widget displayWidget;
    // Handle as text for all keys values
    String displayValue = value?.toString() ?? '--';

    if (detailsKey == 'battery_choice' && value == false) {
      displayWidget = Text('--',
          style: TextStyle(
              fontSize: 10, color: Colors.blue[800], fontWeight: FontWeight.w500));
    } else if (detailsKey == 'last_reported' && value != null) {
      try {
        DateTime dateTime = DateTime.parse(value);
        String formattedDate =
            DateFormat.yMd().add_jm().format(dateTime.toLocal());
        displayWidget = Text(
          formattedDate,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
        );
      } catch (e) {
        displayWidget = Text('--',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: Colors.blue[800]));
      }
    } else {
      displayWidget = Text(displayValue,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: Colors.blue[800]));
    }

    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              detailsKey.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: darkBlue, // Adjust color if needed
              ),
            ),
            displayWidget,
          ],
        ),
      ),
    );
  }
}

const selectedKeys = [
  'last_reported',
  'system',
  'head',
  'type',
  'battery_choice',
  'battery_type',
  'health_index',
  'signal_strength',
];
