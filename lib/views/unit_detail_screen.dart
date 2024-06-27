import 'dart:convert';

import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import '../services/wiqc_api_services/api_services.dart';
import '../widgets/units_sensors/sensor_tiles_list.dart';
import '../widgets/drawer.dart';

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
  String reportDate = '';
  bool isLoading = true;
  final _unitApiService = UnitApi(storage: SecureStorageManager.storage);

  @override
  void initState() {
    super.initState();
    _fetchUnitDetails();
  }

  Future<void> _fetchUnitDetails() async {
    try {
      final results =
          await _unitApiService.fetchUnitDetails(widget.unitId.toString());
      setState(() {
        unitDetails = results['unitDetails'] ?? {};
        latestReport = results['latestReport'] ?? {};
        reportDate = unitDetails['last_reported'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching unit details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic crossAxisCount based on screen width
    int crossAxisCount = MediaQuery.of(context).size.width > 800
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;

    // Adjust childAspectRatio based on device orientation and size
    double aspectRatio =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? 3 / 1
            : 3 / 1;
    String ssid = unitDetails['ssid'] ?? 'Unit Details';
    dynamic lastReported = unitDetails['last_reported'] ?? '';
    String telemetryType = unitDetails['type'] ?? '';
    double? lat = double.tryParse(unitDetails['lat']?.toString() ?? '');
    double? long = double.tryParse(unitDetails['long']?.toString() ?? '');

    if (unitDetails['last_reported'] != null) {
      reportDate = DateFormat.yMd()
          .add_jm()
          .format(DateTime.parse(unitDetails['last_reported']).toLocal());
    } else {
      reportDate = 'N/A';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Column(
          mainAxisSize:
              MainAxisSize.min, // Makes column fit its children's size
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: darkBlue),
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/CircleLogo.svg',
                height: 45,
              ),
            ),
          ],
        ),
        centerTitle: true, // Centers the column (title and image) in the AppBar
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUnitDetails,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(children: [
                      Text(ssid,
                          style: const TextStyle(
                            fontSize: 30,
                            color: darkBlue,
                          )),

                      Card(
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: selectedKeys
                              .where((key) => unitDetails.containsKey(key))
                              .map((key) =>
                                  _buildRow(context, key, unitDetails[key]))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Display sensor data tiles
                      SensorTilesList(
                        unitId: widget.unitId,
                        reportDate: reportDate,
                        latestReport: latestReport,
                        telemetryType: telemetryType,
                      )
                    ])),
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (lat != null && long != null) {
              _openMapModal(
                context,
                lat,
                long,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Location data is not available for this unit.')),
              );
            }
          },
          backgroundColor: lightBlue,
          elevation: 15,
          child: const Icon(Icons.map_outlined, color: darkBlue)),
    );
  }
}

void _openMapModal(BuildContext context, lat, long) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, long),
              zoom: 6.0,
            ),
            myLocationEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('unitLocation'),
                position: LatLng(lat, long),
              ),
            },
          ),
        );
      });
}

Widget _buildRow(BuildContext context, String key, dynamic value) {
  Widget displayWidget = Text('N/A',
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue));

  // Handle as text for all keys values
  String displayValue = value?.toString() ?? 'N/A';
  displayWidget = Text(displayValue.toUpperCase(),
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue));

  if (key == 'last_reported') {
    if (value != null) {
      try {
        DateTime dateTime = DateTime.parse(value);
        String formattedDate =
            DateFormat.yMd().add_jm().format(dateTime.toLocal());
        displayWidget = Text(
          formattedDate,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600 ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        );
      } catch (e) {
        print('Error formatting last_reported: $e');
      }
    }
  }

  return Container(
    padding: const EdgeInsets.all(4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          key.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 12,
            decoration: TextDecoration.underline,
            decorationThickness: 1,
          ),
        ),
        const SizedBox(height: 4), // Add some spacing
        displayWidget,
      ],
    ),
  );
}

const selectedKeys = [
  'last_reported',
  'system',
  'head',
  'type',
  'battery_choice',
  'battery_type',
  'health_index',
  'signal_strength',
];

bool _isJsonString(String str) {
  try {
    json.decode(str);
  } catch (e) {
    return false;
  }
  return true;
}
