import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wateriqcloud_mobile/services/data_service/data_services.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_services.dart';
import 'package:wateriqcloud_mobile/views/unit_detail_screen.dart';
import 'package:wateriqcloud_mobile/widgets/drawer.dart';
import 'package:wateriqcloud_mobile/widgets/home_page/dashboard_cards.dart';
import 'package:wateriqcloud_mobile/widgets/home_page/unit_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataService _dataService = DataService();

  List<dynamic> units = [];
  List<LatLng> unitLocations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> fetchedUnits = await _dataService.loadInitialData(context);
    setState(() {
      units = fetchedUnits;
      collectUnitLocations(units, unitLocations);
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    var logo = 'assets/images/CircleLogo.svg';

    if (isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: SvgPicture.asset(
                  logo,
                  height: 45,
                ),
              ),
            ]),
            centerTitle: true,
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ));
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: SvgPicture.asset(
              logo,
              height: 45,
            ),
          ),
        ]),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              child: Column(
                  children: <Widget>[
                    const SizedBox(height: 5),
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        DashboardCards(
                          title: 'Total Units',
                          count: units.length.toString(),
                          icon: Icons.hub,
                          color: darkBlue,
                          tooltipMessage:
                              'Total number of units in your dashboard',
                        ),
                        DashboardCards(
                          title: 'Active',
                          count: _countActiveUnits().toString(),
                          icon: Icons.cloud_outlined,
                          color: Colors.blue,
                          tooltipMessage: 'Number of units currently active',
                        ),
                        DashboardCards(
                          title: 'Inactive',
                          count: _countInactiveUnits().toString(),
                          icon: Icons.cloud_off_rounded,
                          color: const Color.fromARGB(252, 178, 178, 178),
                          tooltipMessage:
                              'Number of units that are not active',
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                      // call unit list widget
                    UnitList(units: units,isLoading: isLoading),
                    
                  ],
                ),
              ),
      ),
      
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (unitLocations.isNotEmpty) {
              _openMapModal(context, units, unitLocations);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No location data is available.')),
              );
            }
          },
          mini: true,
          splashColor: Colors.blue,
          elevation: 15,
          child: const Icon(Icons.map_outlined, color: darkBlue)),
    );
  }

  int _countActiveUnits() {
    // count active units
    return units
        .where((unit) =>
            unit['installed'] == true && unit['decommissioned'] == false)
        .length;
  }

  int _countInactiveUnits() {
    // count inactive units
    return units
        .where((unit) =>
            unit['decommissioned'] == true && unit['installed'] == true || unit['decommissioned'] == true && unit['installed'] == false)
        .length;
  }

// function to parse to double
  double? tryParseToDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

// Function to get unit coordinates
  void collectUnitLocations(List<dynamic> units, List<LatLng> unitLocations) {
    unitLocations.clear();

    for (dynamic value in units) {
      double? lat = tryParseToDouble(value['lat']);
      double? long = tryParseToDouble(value['long']);
      if (lat != null && long != null) {
        unitLocations.add(LatLng(lat, long));
      }
    }
  }

// custom map markers to display the unit id and ssid
  Set<Marker> _createMarkers(List<dynamic> units, List<LatLng> unitLocations) {
    return unitLocations.map((location) {
      var unit = units.firstWhere(
          (unit) =>
              tryParseToDouble(unit['lat']) == location.latitude &&
              tryParseToDouble(unit['long']) == location.longitude,
          orElse: () => null);

      return Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: InfoWindow(
          title:
              'Unit: ${unit != null ? unit['unit_id'].toString() : 'Unknown'}',
          snippet: 'ID: ${unit != null ? unit['id'] : 'Unknown'}',
        ),
      );
    }).toSet();
  }

// google maps function
  void _openMapModal(
      BuildContext context, List<dynamic> units, List<LatLng> unitLocations) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            body: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition:
                  CameraPosition(target: unitLocations.first, zoom: 2.0),
              markers: _createMarkers(units, unitLocations),
              myLocationEnabled: true,
            ),
          );
        });
  }
}
