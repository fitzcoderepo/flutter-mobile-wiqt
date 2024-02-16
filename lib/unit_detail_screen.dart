import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'parameter_chart_screen.dart';
import 'base_scaffold.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

class UnitDetailScreen extends StatefulWidget {
  final int unitId;
  final String title;

  const UnitDetailScreen(
      {super.key, required this.unitId, required this.title});

  @override
  _UnitDetailScreenState createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  Map<String, dynamic> unitDetails = {};
  Map<String, dynamic> latestReport = {};
  bool isLoading = true;

  final _apiService = UnitApi(storage: const FlutterSecureStorage());

  @override
  void initState() {
    super.initState();
    _fetchUnitDetails();
  }

  Future<void> _fetchUnitDetails() async {
    try {
      final results =
          await _apiService.fetchUnitDetails(widget.unitId.toString());
      setState(() {
        unitDetails = results['unitDetails'];
        latestReport = results['latestReport'];
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      throw Exception(e);
    }
  }


  Widget _buildDetailRow(
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: darkBlue,
              )),
          Text(value ?? 'N/A', style: const TextStyle(color: darkBlue)),
        ],
      ),
    );
  }

  Widget _buildSensorTile(String sensorName, String value, String? date) {
    return Card(
      color: darkBlue,
      elevation: 10.0,
      shadowColor: darkBlue,
      margin: const EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ParameterChartScreen(
                unitId: widget.unitId,
                parameterName: sensorName.toLowerCase(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(sensorName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: .5,
                      fontSize: 22,
                      color: Colors.white)),
              const SizedBox(height: 5), // spacing
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5), // spacing
              Text(
                'Last Reported:\n$date',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<Widget> _buildSensorTiles(String telemetryType) {
    List<Widget> tiles = [];

    String reportDate = latestReport['report_date'] != null
        ? DateFormat.yMd()
            .add_jm()
            .format(DateTime.parse(latestReport['report_date']).toLocal())
        : 'N/A';

    // Add common tiles for both telemetry types
    tiles.add(_buildSensorTile(
        'cport2', latestReport['cport2'] ?? 'N/A', reportDate));
    tiles.add(_buildSensorTile(
        'vport2', latestReport['vport2'] ?? 'N/A', reportDate));
    tiles.add(_buildSensorTile(
        'vport1', latestReport['vport1'] ?? 'N/A', reportDate));

    // Add additional tiles for 'telemetry_monitoring'
    if (telemetryType == 'telemetry_monitoring' ||
        telemetryType == 'monitoring_only') {
      tiles.addAll([
        _buildSensorTile('Temp',
            '${latestReport['temp']?.toString() ?? 'N/A'}°C', reportDate),
        _buildSensorTile('pH',
            '${latestReport['ph']?.toString() ?? 'N/A'} units', reportDate),
        _buildSensorTile('Orp',
            '${latestReport['orp']?.toString() ?? 'N/A'} (mV)', reportDate),
        _buildSensorTile(
            'Spcond',
            '${latestReport['spcond']?.toString() ?? 'N/A'} (µS/cm)',
            reportDate),
        _buildSensorTile('Turb',
            '${latestReport['turb']?.toString() ?? 'N/A'} (FNU)', reportDate),
        _buildSensorTile('Chl',
            '${latestReport['chl']?.toString() ?? 'N/A'} (µg/L)', reportDate),
        _buildSensorTile('Bg',
            '${latestReport['bg']?.toString() ?? 'N/A'} (PPB)', reportDate),
        _buildSensorTile(
            'Hdo', '${latestReport['hdo']?.toString() ?? 'N/A'} ', reportDate),
        _buildSensorTile('Hdo per',
            '${latestReport['hdo_per']?.toString() ?? 'N/A'} %', reportDate),
        // ... add other tiles as needed ...
      ]);
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    String telemetryType = unitDetails['type'] ?? '';

    String reportDate;
    if (unitDetails['last_reported'] != null) {
      reportDate = DateFormat.yMd()
          .add_jm()
          .format(DateTime.parse(unitDetails['last_reported']).toLocal());
    } else {
      reportDate = 'N/A';
    }
   
    return BaseScaffold(
      title: 'Unit Details',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Display unit details here
                    _buildDetailRow('System', unitDetails['system']),
                    _buildDetailRow('Head', unitDetails['head']),
                    _buildDetailRow('Type', unitDetails['type']),
                    _buildDetailRow('Battery Choice',
                        unitDetails['battery_choice']?.toString()),
                    _buildDetailRow(
                        'Battery Type', unitDetails['battery_type']),
                    _buildDetailRow(
                      'Latest Report',
                      reportDate,
                    ),
                    _buildDetailRow(
                        'Health Index', unitDetails['health_index']),
                    _buildDetailRow('Latitude', unitDetails['lat']),
                    _buildDetailRow('Longitude', unitDetails['long']),
                    // ... Continue for other fields ...

                    GridView.count(
                        shrinkWrap: true,
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 4 : 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: _buildSensorTiles(telemetryType)),
                  ],
                ),
              ),
            ),
    );
  }
}
