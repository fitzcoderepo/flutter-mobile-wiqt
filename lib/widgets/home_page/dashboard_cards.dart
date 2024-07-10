import 'package:flutter/material.dart';

class DashboardCards extends StatelessWidget {
  // Properties
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final String tooltipMessage;
  // Constructor
  const DashboardCards({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: Duration.zero,
      preferBelow: true,
      verticalOffset: 60.5,
      message: tooltipMessage,
      child: Card(
        elevation: 4,
        child: InkWell(
          splashColor: Colors.blue,
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width / 3 - 20,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 10),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
