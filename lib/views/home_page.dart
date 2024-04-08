import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wateriqcloud_mobile/core/theme/app_pallete.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_services.dart';
import 'unit_detail_screen.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List units = [];
  bool isLoading = true;
  dynamic projectData;
  final _projectApiService = ProjectApi(storage: SecureStorageManager.storage);
  final _unitApiService = UnitApi(storage: SecureStorageManager.storage);
  Map<String, dynamic> unitDetailsMap = {};
  Map<String, dynamic> unitReportsMap = {};
  List<LatLng> unitLocations = [];
  

  Future<void> _fetchProjectData() async {
    try {
      var data = await _projectApiService.fetchProjectData();
      setState(() {
        projectData = data;
        units = projectData['units'] as List;
        isLoading = false;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _fetchAllUnitDetails() async {
    isLoading = true;
    List<Future> fetchTasks = [];
    for (var unitId in units) {
      if (unitId == null) continue;
      var task =
          _unitApiService.fetchUnitDetails(unitId.toString()).then((result) {
        Map<String, dynamic> details = result['unitDetails'];
        Map<String, dynamic> latestReport = result['latestReport'];

        unitDetailsMap[unitId.toString()] = details;
        unitReportsMap[unitId.toString()] = latestReport;
      }).catchError((e) {
        // Handle error
      });

      fetchTasks.add(task);
    }
    await Future.wait(fetchTasks);
    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchProjectData().then((_) {
      _fetchAllUnitDetails();
    });
  }


  Future<void> saveUnitOrder(List<dynamic> newOrder) async {
    var box = await Hive.openBox('unitListOrder');
    await box.put('unitsOrder', newOrder);
  }

  Future<void> loadUnitOrder() async {
    var box = await Hive.openBox('unitListOrder');
    var savedOrder = box.get('unitsOrder');
    if (savedOrder != null) {
      units = List<dynamic>.from(savedOrder);
    }
    _fetchProjectData().then((_) {
      _fetchAllUnitDetails();
    });
  }

  double? tryParseToDouble(dynamic value) {
    if (value == null) {
      return null;
    } // Return null immediately if value is null
    if (value is double) {
      return value; // If it's already a double, return it directly
    }
    if (value is int) {
      return value.toDouble(); // Convert int to double
    }
    if (value is String) {
      return double.tryParse(value); // Try parsing string to double
    }
    return null; // Return null for any other type that can't be handled
  }

  void collectUnitLocations() {
    unitLocations.clear();

    unitDetailsMap.forEach((unitId, unitDetails) {
      double? lat = tryParseToDouble(unitDetails['lat']);
      double? long = tryParseToDouble(unitDetails['long']);

      if (lat != null && long != null) {
        unitLocations.add(LatLng(lat, long));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.darkBlue,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            decoration: const BoxDecoration(
                color: AppPallete.whiteColor, shape: BoxShape.circle),
            child: SvgPicture.asset(
              'assets/images/CircleLogo.svg',
              height: 35,
            ),
          ),
        ]),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: Text('${projectData['name'] ?? ''}',
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 20),
            child: Text('${projectData['location'] ?? ''}',
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    int unitId = units[index];
                    final unitDetails = unitDetailsMap[unitId.toString()];
                    final latestReport = unitReportsMap[unitId.toString()];
                    final ssid = unitDetails['ssid'] ?? 'Unknown ssid';

                    return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(7),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enableFeedback: true,
                          leading: Container(
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: 1.0,
                                        color: AppPallete.darkBlue))),
                            child: const Icon(Icons.drag_indicator_rounded,
                                size: 30,
                                color: Color.fromARGB(255, 169, 177, 183)),
                          ),
                          title: Text(ssid,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 5, 113, 196))),
                          subtitle: Row(
                            children: <Widget>[
                              Text("ID $unitId",
                                  style: const TextStyle(
                                      color: AppPallete.darkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10))
                            ],
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right,
                              color: AppPallete.darkBlue, size: 40.0),
                          tileColor: const Color.fromARGB(255, 233, 234, 235),
                          onTap: () {
                            Navigator.of(context).push(_createRoute(unitId));
                          },
                        ));
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            collectUnitLocations();
            if (unitLocations.isNotEmpty) {
              _openMapModal(context, unitLocations);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No location data is available.')),
              );
            }
          },
          backgroundColor: lightBlue,
          elevation: 15,
          child: const Icon(Icons.map_outlined, color: darkBlue)),
    );
  }
}

Route _createRoute(unitId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => UnitDetailScreen(
      unitId: unitId,
      title: 'Unit details',
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void _openMapModal(BuildContext context, List<LatLng> unitLocations) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          // height: MediaQuery.of(context).size.height *
          // 0.75, // Adjust the size as needed
          body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: unitLocations
                  .first, // Initial position to the first unit location
              zoom: 2.0,
            ),
            markers: Set.from(unitLocations.map((location) => Marker(
                  // Generate a unique markerId for each location
                  markerId: MarkerId(location.toString()),
                  position: location,
                ))),
            myLocationEnabled: true,
          ),
        );
      });
}


