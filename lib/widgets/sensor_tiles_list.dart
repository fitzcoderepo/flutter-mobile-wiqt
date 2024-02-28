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
      {'name': 'vport2', 'value': latestReport['vport2'] ?? 'N/A'},
      {'name': 'vport1', 'value': latestReport['vport1'] ?? 'N/A'},
      // Add other sensors...
    ];
    // Optionally, add more sensors based on telemetryType
    if (telemetryType == 'telemetry_monitoring' ||
        telemetryType == 'monitoring_only') {
      sensorData.addAll([
        {
          'name': 'Temp',
          'value': '${latestReport['temp']?.toString() ?? 'N/A'}°C'
        },
        {
          'name': 'pH',
          'value': '${latestReport['pH']?.toString() ?? 'N/A'} units'
        },
        {
          'name': 'Orp',
          'value': '${latestReport['orp']?.toString() ?? 'N/A'} (mV)'
        },
        {
          'name': 'Spcond',
          'value': '${latestReport['spcond']?.toString() ?? 'N/A'} (µS/cm)'
        },
        {
          'name': 'Turb',
          'value': '${latestReport['turb']?.toString() ?? 'N/A'} (FNU)'
        },
        {
          'name': 'Chl',
          'value': '${latestReport['chl']?.toString() ?? 'N/A'} (µg/L)'
        },
        {
          'name': 'Bg',
          'value': '${latestReport['bg']?.toString() ?? 'N/A'} (PPB)'
        },
        {'name': 'Hdo', 'value': latestReport['hdo']?.toString() ?? 'N/A'},
        {
          'name': 'Hdo per',
          'value': '${latestReport['hdo_per']?.toString() ?? 'N/A'}%'
        }
        // Add other sensor data...
      ]);
    }
    return sensorData;
  }

  @override
  Widget build(BuildContext context) {
    
    List<Map<String, String>> sensorData =
        _prepareSensorData(latestReport, telemetryType);
    String reportDate = _formatReportDate(latestReport['report_date']);

    return GridView.builder(
      itemCount: sensorData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sensorData.length < 4 ? 3 : 4,
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
