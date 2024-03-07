import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'unit_detail_screen.dart';
import '../services/api_services.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Map<String, dynamic> projectData = {};
  List units = [];
  bool isLoading = true;
  dynamic projectData;
  final _projectApiService = ProjectApi(storage: const FlutterSecureStorage());
  final _unitApiService = UnitApi(storage: const FlutterSecureStorage());
  Map<int, dynamic> unitDetailsMap = {};
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
      var task =
          _unitApiService.fetchUnitDetails(unitId.toString()).then((result) {
        Map<String, dynamic> details = result['unitDetails'];
        Map<String, dynamic> latestReport = result['latestReport'];

        unitDetailsMap[unitId] = details;
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
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          int unitId = units[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            color: const Color.fromARGB(220, 255, 255, 255),
                            elevation: 4,
                            shadowColor: darkBlue,
                            margin: const EdgeInsets.all(7),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(_createRoute(unitId));
                              },
                              child: Text("Unit ID \n $unitId ",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          );
                        })),
                
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          collectUnitLocations();

          if (unitLocations.isNotEmpty) {
            _openMapModal(context, unitLocations);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No location data is available.')),
            );
          }
        },
        backgroundColor: lightBlue,
        elevation: 15,
        child: const Icon(Icons.map_outlined, color: darkBlue)
      ),
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
