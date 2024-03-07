import 'package:flutter/material.dart';

class DetailRowsList extends StatelessWidget {
  final Map<String, dynamic> unitDetails;
  // final Map<String, dynamic> latestReport;

  const DetailRowsList({
    super.key,
    required this.unitDetails,
    // required this.latestReport,
  });

  @override
  Widget build(BuildContext context) {
    const selectedKeys = [
      'system',
      'head',
      'type',
      'battery_choice',
      'battery_type',
      'health_index',
    ];

    // Dynamic crossAxisCount based on screen width
    int crossAxisCount = MediaQuery.of(context).size.width > 800 ? 4 : MediaQuery.of(context).size.width > 600 ? 3 : 2;

    // Adjust childAspectRatio based on device orientation and size
    double aspectRatio = MediaQuery.of(context).orientation == Orientation.landscape ? 2.5 / 1 : 2 / 1;

    return Card(
        elevation: 8,
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 4,
          mainAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: selectedKeys.map((key) {
            // Only generate widgets for keys that exist in unitDetails
            if (unitDetails.containsKey(key)) {
              String displayValue = key == 'battery_choice' && unitDetails[key] == false ? 'N/A' : unitDetails[key]?.toString() ?? 'N/A';
              return Container(
                padding: const EdgeInsets.all(8), // Consider making padding responsive as well
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      key.replaceAll('_', ' ').toUpperCase(), // Format key as title
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12, // Adjust font size based on screen width
                          decoration: TextDecoration.underline,
                          decorationThickness: 1),
                    ),
                    Text(
                      displayValue.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10, // Adjust font size based on screen width
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink(); // Return an empty widget for missing keys
            }
          }).toList(),
        ));
  }

}
