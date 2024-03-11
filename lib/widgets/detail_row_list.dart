import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/rendering.dart';

class DetailRowsList extends StatelessWidget {
  final Map<String, dynamic> unitDetails;
  final int? unitId;
  // final Map<String, dynamic> latestReport;

  DetailRowsList({
    super.key,
    required this.unitDetails,
    this.unitId,
    // required this.latestReport,
  });

  Widget _buildRow(BuildContext context, String key, dynamic value) {
    Widget displayWidget = Text('N/A',
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: Colors.blue));

    if (key == 'gpios') {
      key = 'Pulsar Power';
      bool active = false; // Default to false

      if (value is String) {
        // If value is a JSON string
        try {
          Map<String, dynamic> gpios =
              json.decode(value.trim().replaceAll('\'', '\"'));
          if (gpios.containsKey('16') && gpios['16'].toString() == '1') {
            active = true;
          }
        } catch (e) {
          print('Error decoding gpios JSON: $e');
        }
      } else if (value is int) {
        // If value is an integer
        active = value == 1;
      }

      IconData iconData = active ? Icons.power : Icons.power_off;
      Color iconColor = active ? Colors.green : Colors.red;
      displayWidget = Icon(iconData, color: iconColor, size: 20);
    } else {
      // Handle as text for all other keys
      String displayValue = value?.toString() ?? 'N/A';
      displayWidget = Text(displayValue.toUpperCase(),
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
              fontWeight: FontWeight.bold,
              color: Colors.blue));
    }
    

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
              decoration: TextDecoration.underline,
              decorationThickness: 1,
            ),
          ),
          SizedBox(height: 4), // Add some spacing
          displayWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const selectedKeys = [
      'gpios',
      'system',
      'head',
      'type',
      'battery_choice',
      'battery_type',
      'health_index',
      'signal_strength',
    ];

    // Dynamic crossAxisCount based on screen width
    int crossAxisCount = MediaQuery.of(context).size.width > 800
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;

    // Adjust childAspectRatio based on device orientation and size
    double aspectRatio =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? 3 / 1
            : 3 / 1;

    return Card(
        elevation: 8,
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 4,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: selectedKeys
              .where((key) => unitDetails.containsKey(key))
              .map((key) => _buildRow(context, key, unitDetails[key]))
              .toList(),
        ));
  }
}
