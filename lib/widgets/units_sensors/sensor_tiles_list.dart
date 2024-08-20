import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sensor_tile.dart';

class SensorTilesList extends StatelessWidget {
  final Map<String, dynamic> latestReport;
  final Map<String, dynamic> unitDetails;
  final String telemetryType;
  final int unitId;
  final String reportDate;

  SensorTilesList({
    super.key,
    required this.latestReport,
    required this.unitDetails,
    required this.telemetryType,
    required this.unitId,
    required this.reportDate,
  });

  // Mapping sensor names to customer-friendly names
  final Map<String, String> sensorNameMapping = {
    'cport2': 'Sonification Counts 1',
    'vport2': 'Sonification Voltage 1',
    'vport1': 'System Output Voltage',
    'cport3': 'Sonification Counts 2',
    'vport3': 'Sonification Voltage 2',
    'temp': 'Temperature',
    'ph': 'pH Level',
    'orp': 'Oxygen Reduction Potential',
    'spcond': 'Specific Conductance',
    'turb': 'Turbidity',
    'chl': 'Chlorophyll A',
    'bg': 'Blue-Green Algae',
    'hdo': 'Dissolved Oxygen',
    'hdo_per': 'Oxygen Saturation',
  };

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
      {
        'name': sensorNameMapping['cport2'] ?? 'Sonification Counts 1',
        'internalName': 'cport2',
        'value': latestReport['cport2'] ?? 'N/A'
      },
      {
        'name': sensorNameMapping['vport2'] ?? 'Sonification Voltage 1',
        'internalName': 'vport2',
        'value': latestReport['vport2'] ?? 'N/A'
      },
      {
        'name': sensorNameMapping['vport1'] ?? 'System Output Voltage',
        'internalName': 'vport1',
        'value': latestReport['vport1'] ?? 'N/A'
      },
    ];
    // check for 2nd pulsar head
    if (unitDetails['head'] == 'dual') {
      sensorData.addAll([
        {
          'name': sensorNameMapping['cport3'] ?? 'Sonification Counts 2',
          'internalName': 'cport3',
          'value': latestReport['cport3'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['vport3'] ?? 'Sonification Voltage 2',
          'internalName': 'vport3',
          'value': latestReport['vport3'] ?? 'N/A'
        },
      ]);
    }
    // display more sensors based on telemetryType
    if (telemetryType == 'telemetry_monitoring' ||
        telemetryType == 'monitoring_only') {
      sensorData.addAll([
        {
          'name': sensorNameMapping['temp'] ?? 'temp',
          'internalName': 'temp',
          'value': latestReport['temp'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['ph'] ?? 'ph',
          'internalName': 'ph',
          'value': latestReport['ph'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['orp'] ?? 'orp',
          'internalName': 'orp',
          'value': latestReport['orp'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['spcond'] ?? 'spcond',
          'internalName': 'spcond',
          'value': latestReport['spcond'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['turb'] ?? 'turb',
          'internalName': 'turb',
          'value': latestReport['turb'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['chl'] ?? 'chl',
          'internalName': 'chl',
          'value': latestReport['chl'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['bg'] ?? 'bg',
          'internalName': 'bg',
          'value': latestReport['bg'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['hdo'] ?? 'hdo',
          'internalName': 'hdo',
          'value': latestReport['hdo'] ?? 'N/A'
        },
        {
          'name': sensorNameMapping['hdo_per'] ?? 'hdo_per',
          'internalName': 'hdo_per',
          'value': latestReport['hdo_per'] ?? 'N/A'
        }
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
          internalSensorName: sensor['internalName']!,
          value: sensor['value']!,
          reportDate: reportDate,
        );
      },
    );
  }
}
