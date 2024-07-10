import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sensor_tile.dart';

class SensorTilesList extends StatelessWidget {
  final Map<String, dynamic> latestReport;
  final String telemetryType;
  final int unitId;
  final String reportDate;

  const SensorTilesList({
    super.key,
    required this.latestReport,
    required this.telemetryType,
    required this.unitId,
    required this.reportDate,
  });

  // FORMAT DATE
  String _formatReportDate(dynamic reportDate) {
    return reportDate != null
        ? DateFormat.yMd().add_jm().format(DateTime.parse(reportDate).toLocal())
        : 'N/A';
  }

  // PREPARE SENSOR TILES
  List<Map<String, String>> _prepareSensorData(
      Map latestReport, String telemetryType) {
    List<Map<String, String>> sensorData = [
      {'name': 'cport2', 'value': latestReport['cport2'] ?? 'N/A'},
      {'name': 'vport1', 'value': latestReport['vport1'] ?? 'N/A'},
      {'name': 'vport2', 'value': latestReport['vport2'] ?? 'N/A'},
    ];
    // add more sensors based on telemetryType
    if (telemetryType == 'telemetry_monitoring' ||
        telemetryType == 'monitoring_only') {
      sensorData.addAll([
        {'name': 'temp', 'value': latestReport['temp'] ?? 'N/A'},
        {'name': 'pH', 'value': latestReport['ph'] ?? 'N/A'},
        {'name': 'Orp', 'value': latestReport['orp'] ?? 'N/A'},
        {'name': 'Spcond', 'value': latestReport['spcond'] ?? 'N/A'},
        {'name': 'Turb', 'value': latestReport['turb'] ?? 'N/A'},
        {'name': 'Chl', 'value': latestReport['chl'] ?? 'N/A'},
        {'name': 'Bg', 'value': latestReport['bg'] ?? 'N/A'},
        {'name': 'Hdo', 'value': latestReport['hdo'] ?? 'N/A'},
        {'name': 'Hdo per', 'value': latestReport['hdo_per'] ?? 'N/A'}
      ]);
    }
    return sensorData;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> sensorData =
        _prepareSensorData(latestReport, telemetryType);
    return GridView.builder(
      itemCount: sensorData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final sensor = sensorData[index];
        return SensorTile(
          unitId: unitId,
          sensorName: sensor['name']!,
          value: sensor['value']!,
          reportDate: reportDate,
        );
      },
    );
  }
}
