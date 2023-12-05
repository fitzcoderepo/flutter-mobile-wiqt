import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'parameter_chart_screen.dart';
import 'dart:io' show Platform;

class UnitDetailScreen extends StatefulWidget {
  final int unitId;

  UnitDetailScreen({Key? key, required this.unitId}) : super(key: key);

  @override
  _UnitDetailScreenState createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  Map<String, dynamic> unitDetails = {};
  Map<String, dynamic> latestReport = {};
  bool isLoading = true;
  bool _isLocalIphone = false;
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else if (_isLocalIphone) {
      return "http://192.168.1.139:8000";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildSensorTile(String sensorName, String value) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation to the chart page for this sensor
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(sensorName, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSensorTiles(String telemetryType) {
    List<Widget> tiles = [];

    // Add common tiles for both telemetry types
    tiles.add(_buildSensorTile('cport2', latestReport['cport2'] ?? 'N/A'));
    tiles.add(_buildSensorTile('vport2', latestReport['vport2'] ?? 'N/A'));
    tiles.add(_buildSensorTile('vport1', latestReport['vport1'] ?? 'N/A'));

    // Add additional tiles for 'telemetry_monitoring'
    if (telemetryType == 'telemetry_monitoring') {
      tiles.addAll([
        _buildSensorTile('Temp', latestReport['temp'] ?? 'N/A'),
        _buildSensorTile('Ph', latestReport['ph'] ?? 'N/A'),
        _buildSensorTile('Orp', latestReport['orp'] ?? 'N/A'),
        _buildSensorTile('Spcond', latestReport['spcond'] ?? 'N/A'),
        _buildSensorTile('Turb', latestReport['turb'] ?? 'N/A'),
        _buildSensorTile('Chl', latestReport['chl'] ?? 'N/A'),
        _buildSensorTile('Bg', latestReport['bg'] ?? 'N/A'),
        _buildSensorTile('Hdo', latestReport['hdo'] ?? 'N/A'),
        _buildSensorTile('Hdo per', latestReport['hdo_per'] ?? 'N/A'),
        // ... add other tiles as needed ...
      ]);
    }

    return tiles;
  }

  @override
  void initState() {
    super.initState();
    _fetchUnitDetails();
  }

  Future<void> _fetchUnitDetails() async {
    final _storage = FlutterSecureStorage();
    final token =
        await _storage.read(key: 'auth_token'); // Retrieve the stored token
    var baseUrl = getBaseUrl();
    final unitDetailResponse = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-detail/${widget.unitId}'),
      headers: {'Authorization': 'Token $token'},
    );

    final unitReportResponse = await http.get(
      Uri.parse('$baseUrl/api/v1/unit-reports-uid/${widget.unitId}'),
      headers: {'Authorization': 'Token $token'},
    );

    if (unitDetailResponse.statusCode == 200 &&
        unitReportResponse.statusCode == 200) {
      final unitReportData = json.decode(unitReportResponse.body);

      setState(() {
        unitDetails = json.decode(unitDetailResponse.body);
        // Assuming the latest report is the first item in the response array
        latestReport = (unitReportData['results'] is List &&
                unitReportData['results'].isNotEmpty)
            ? unitReportData['results'][0]
            : <String, dynamic>{};
        isLoading = false;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    String telemetryType = unitDetails['type'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Display unit details here
                  _buildDetailRow('System', unitDetails['system']),
                  _buildDetailRow('Head', unitDetails['head']),
                  _buildDetailRow('Battery Choice',
                      unitDetails['battery_choice']?.toString()),
                  _buildDetailRow('Battery Type', unitDetails['battery_type']),
                  // ... More details ...
                  _buildDetailRow(
                      'Last Reported', unitDetails['last_reported']),
                  _buildDetailRow('Health Index', unitDetails['health_index']),
                  _buildDetailRow('Latitude', unitDetails['lat']),
                  _buildDetailRow('Longitude', unitDetails['long']),
                  // ... Continue for other fields ...
                  GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: _buildSensorTiles(telemetryType))
                ],
              ),
            ),
    );
  }
}
