import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/widgets/unit_details/unit_details_card.dart';
import '../services/location_provider.dart';
import '../services/wiqc_api_services/api_services.dart';
import '../widgets/units_sensors/sensor_tiles_list.dart';
import '../widgets/drawer.dart';

class UnitDetailScreen extends StatefulWidget {
  final int unitId;
  final String title;
  final double lat;
  final double long;

  const UnitDetailScreen(
      {super.key,
      required this.unitId,
      required this.title,
      required this.lat,
      required this.long});

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
    // defer state updates until after widget build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .setUnitLocation(widget.lat, widget.long);
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // define/initialize vars
    String ssid = unitDetails['ssid'] ?? 'Unit Details';
    String telemetryType = unitDetails['type'] ?? '';
    dynamic dateReported = unitDetails['last_reported'];

    // check dateReported is not null before parsing
    String lastReported = dateReported != null ? DateFormat.yMd().add_jm().format(DateTime.parse(dateReported).toLocal()) : '--'; // value if dateReported is null

    double? lat = double.tryParse(unitDetails['lat']?.toString() ?? '');
    double? long = double.tryParse(unitDetails['long']?.toString() ?? '');
    // weather api vars
    final locationProvider = Provider.of<LocationProvider>(context);
    final weather = locationProvider.currentWeather;
    String? weatherArea = weather?.areaName;
    String? weatherTemp = weather?.temperature?.fahrenheit?.toStringAsFixed(1);
    String? weatherIcon = weather?.weatherIcon;
    String getWeatherIconUrl(String? iconCode) {
      return iconCode != null ? 'https://openweathermap.org/img/wn/$iconCode@2x.png' : ''; // empty string if iconCode is null
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
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUnitDetails,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            Text(
                              ssid,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(weatherArea!),
                            Container(
                              decoration: const BoxDecoration(
                                color: lightBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Image.network(
                                  getWeatherIconUrl(weatherIcon!),
                                  width: 50,
                                  height: 50),
                            ),
                            Text('${weatherTemp!} °F'),
                          ],
                        ),
                      ),

                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 6 / 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: selectedKeys
                            .where((key) => unitDetails.containsKey(key))
                            .map((key) => UnitDetailsCard(
                                detailsKey: key, value: unitDetails[key]))
                            .toList(),
                      ),

                      const SizedBox(height: 10),

                      // Display sensor data tiles
                      SensorTilesList(
                        unitId: widget.unitId,
                        reportDate: lastReported,
                        latestReport: latestReport,
                        telemetryType: telemetryType,
                      )
                    ],
                  ),
                ),
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
          mini: true,
          backgroundColor: lightBlue,
          elevation: 15,
          child: const Icon(Icons.map_outlined, color: darkBlue)),
    );
  }
}

void _openMapModal(BuildContext context, lat, long) {
  Provider.of<LocationProvider>(context, listen: false)
      .setUnitLocation(lat, long);
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
