import 'package:flutter/material.dart';
import '../../views/parameter_chart_screen.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

class SensorTile extends StatelessWidget {
  final String sensorName;
  final String value;
  final String reportDate;
  final int unitId;

  const SensorTile({
    super.key,
    required this.sensorName,
    required this.value,
    required this.reportDate,
    required this.unitId,
  });

  @override
  Widget build(BuildContext context) {
    var formatValue = double.tryParse(value)?.toStringAsFixed(2) ?? 'N/A';
    return Card(
      color: darkBlue,
      elevation: 12.0,
      shadowColor: darkBlue,
      margin: const EdgeInsets.all(2),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ParameterChartScreen(
                unitId: unitId,
                parameterName: sensorName.toLowerCase(),
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$sensorName\n',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '$formatValue\n\n',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: reportDate,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
