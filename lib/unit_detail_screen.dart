import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'parameter_chart_screen.dart';
import 'dart:io' show Platform;
import 'base_scaffold.dart';
import 'package:intl/intl.dart';

class UnitDetailScreen extends StatefulWidget {
  final int unitId;
  final String title;

  const UnitDetailScreen({Key? key, required this.unitId, required this.title})
      : super(key: key);

  @override
  _UnitDetailScreenState createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  Map<String, dynamic> unitDetails = {};
  Map<String, dynamic> latestReport = {};
  bool isLoading = true;
  final bool _isLocalIphone = false;
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

  Widget _buildDetailRow(
    String label,
    String? value,
    
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: darkBlue,)),
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

  Future<void> _fetchUnitDetails() async {
    const storage = FlutterSecureStorage();
    final token =
        await storage.read(key: 'auth_token'); // Retrieve the stored token
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

        if (unitReportData['results'] is List && unitReportData['results'].isNotEmpty) 
        {
            // Select the last item in the list
            latestReport = unitReportData['results'].last;
        } 
        else 
        {
          latestReport = <String, dynamic>{};
        }

        isLoading = false;
      });
    } 
    else 
    {
      // Handle error
    }
  }

  List<Widget> _buildSensorTiles(String telemetryType) {
    List<Widget> tiles = [];

    String reportDate = latestReport['report_date'] != null
        ? DateFormat.yMd().add_jm().format(DateTime.parse(latestReport['report_date']).toLocal()) : 'N/A';

    // Add common tiles for both telemetry types
    tiles.add(_buildSensorTile('cport2', latestReport['cport2'] ?? 'N/A', reportDate));
    tiles.add(_buildSensorTile('vport2', latestReport['vport2'] ?? 'N/A', reportDate));
    tiles.add(_buildSensorTile('vport1', latestReport['vport1'] ?? 'N/A', reportDate));

    // Add additional tiles for 'telemetry_monitoring'
    if (telemetryType == 'telemetry_monitoring' || telemetryType == 'monitoring_only') {
      tiles.addAll([
        _buildSensorTile('Temp', '${latestReport['temp']?.toString() ?? 'N/A'}°C', reportDate),
        _buildSensorTile('pH', '${latestReport['ph']?.toString() ?? 'N/A'} units', reportDate),
        _buildSensorTile('Orp', '${latestReport['orp']?.toString() ?? 'N/A'} (mV)', reportDate),
        _buildSensorTile('Spcond', '${latestReport['spcond']?.toString() ?? 'N/A'} (µS/cm)', reportDate),
        _buildSensorTile('Turb', '${latestReport['turb']?.toString() ?? 'N/A'} (FNU)', reportDate),
        _buildSensorTile('Chl', '${latestReport['chl']?.toString() ?? 'N/A'} (µg/L)', reportDate),
        _buildSensorTile('Bg', '${latestReport['bg']?.toString() ?? 'N/A'} (PPB)', reportDate),
        _buildSensorTile('Hdo',  '${latestReport['hdo']?.toString() ?? 'N/A'} ', reportDate),
        _buildSensorTile('Hdo per', '${latestReport['hdo_per']?.toString() ?? 'N/A'} %', reportDate),
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

  @override
  Widget build(BuildContext context) {
    String telemetryType = unitDetails['type'] ?? '';
    
    String reportDate = unitDetails['last_reported'] != null
        ? DateFormat.yMd().add_jm().format(DateTime.parse(unitDetails['last_reported']).toLocal()) : 'N/A';

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
                    _buildDetailRow('Battery Choice',unitDetails['battery_choice']?.toString()),
                    _buildDetailRow('Battery Type', unitDetails['battery_type']),
                    _buildDetailRow('Latest Report', reportDate,),
                    _buildDetailRow('Health Index', unitDetails['health_index']),
                    _buildDetailRow('Latitude', unitDetails['lat']),
                    _buildDetailRow('Longitude', unitDetails['long']),
                    // ... Continue for other fields ...

                    GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
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
