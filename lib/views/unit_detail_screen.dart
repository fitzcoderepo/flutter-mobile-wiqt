import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../services/api_services.dart';
import '../widgets/sensor_tiles_list.dart';
import '../widgets/detail_row_list.dart';
import '../widgets/drawer.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset(
                'assets/images/wiqt_crop.png',
                filterQuality: FilterQuality.none,
                height: 45,
              ),
            ),
          ],
        ),
        centerTitle: true, // Centers the column (title and image) in the AppBar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                    const Text('Unit Details',
                        style: TextStyle(
                          fontSize: 30,
                          color: darkBlue,
                        )),
                   
                    DetailRowsList(unitDetails: unitDetails),
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
          // height: MediaQuery.of(context).size.height *
          // 0.75, // Adjust the size as needed
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, long),
              zoom: 0.0,
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
