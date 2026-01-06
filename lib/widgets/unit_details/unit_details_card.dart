import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wateriqcloud_mobile/main.dart';

class UnitDetailsCard extends StatelessWidget {
  // Properties
  final String detailsKey;
  final dynamic value;
  final Map<String, dynamic> latestReport;

  // Constructor
  const UnitDetailsCard({
    super.key,
    required this.detailsKey,
    required this.value,
    required this.latestReport,
  });

  @override
  Widget build(BuildContext context) {
    Widget displayWidget;
    String displayValue = value.toString();

    // handle keys with values from latestReport
    if (detailsKey == 'signal_strength' ||
        detailsKey == 'battery_type' ||
        detailsKey == 'battery_choice') {
      displayValue = latestReport[detailsKey].toString();
    }

    // Handle special cases like battery_choice being false
    if (detailsKey == 'battery_choice' && latestReport[detailsKey] == false) {
      displayValue = '--';
    }
    
    // Handle date formatting for last_reported
    if (detailsKey == 'last_reported' && value != null) {
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
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.blue[800]));
      }
    } else {
      displayWidget = Text(displayValue,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.blue[800]));
    }

    return Card(
      elevation: 0,
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
                color: darkBlue,
              ),
            ),
            displayWidget,
          ],
        ),
      ),
    );
  }
}

// A list of selected keys to display in the UI
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
