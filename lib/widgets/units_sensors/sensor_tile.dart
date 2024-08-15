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
    return Card.filled(
      elevation: 4.0,
      shadowColor: darkBlue,  
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ParameterChartScreen(
                unitId: unitId,
                parameterName: sensorName,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child:Text(
                    sensorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child:
                    Text(formatValue, style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[800],
                    )),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child:
                    Text(
                      reportDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center
                    ),
                ),
              ],
            ),
          
        ),
      ),
    );
  }
}
