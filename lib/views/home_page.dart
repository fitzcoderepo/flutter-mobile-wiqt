import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wateriqcloud_mobile/core/theme/app_pallete.dart';
import 'package:wateriqcloud_mobile/services/storage/storage_manager.dart';
import 'package:wateriqcloud_mobile/services/wiqc_api_services/api_services.dart';
import 'unit_detail_screen.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> units = [];
  bool isLoading = true;
  dynamic projectData;
  final _projectApiService = ProjectApi(storage: SecureStorageManager.storage);
  final _unitApiService = UnitApi(storage: SecureStorageManager.storage);
  List<LatLng> unitLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchProjectData().then((_) {
      _fetchAllUnitDetails();
      collectUnitLocations();
    });
  }

  Future<void> _fetchProjectData() async {
    try {
      Map<String, dynamic> data = await _projectApiService.fetchProjectData();
      setState(() {
        projectData = data;
        units = projectData['units'];
        isLoading = false;
      });
      _fetchAllUnitDetails(); // fetch unit details after project data is loaded
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load project data. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      // throw Exception(e);
    }
  }

  Future<void> _fetchAllUnitDetails() async {
    setState(() {
      isLoading = true;
    });
    isLoading = true;
    List<Future> fetchTasks = [];
    for (var unit in units) {
      var unitId = unit['id'];
      if (unitId == null) continue;
      var task = _unitApiService
          .fetchUnitDetails(unitId.toString())
          .then((result) {})
          .catchError((e) {
        // Handle error
      });

      fetchTasks.add(task);
    }
    await Future.wait(fetchTasks);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _fetchProjectData();
    await _fetchAllUnitDetails();
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

    for (dynamic value in units) {
      double? lat = tryParseToDouble(value['lat']);
      double? long = tryParseToDouble(value['long']);
      if (lat != null && long != null) {
        unitLocations.add(LatLng(lat, long));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // keep loading indicator up while still gathering data
    if (isLoading) {
      return Scaffold(
          appBar: AppBar(
            title: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                decoration: const BoxDecoration(
                    color: AppPallete.whiteColor, shape: BoxShape.circle),
                child: SvgPicture.asset(
                  'assets/images/CircleLogo.svg',
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
    // when all data has been fetched, show home page
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.darkBlue,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            decoration: const BoxDecoration(
                color: AppPallete.whiteColor, shape: BoxShape.circle),
            child: SvgPicture.asset(
              'assets/images/CircleLogo.svg',
              height: 45,
            ),
          ),
        ]),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Text('My Dashboard',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 3, bottom: 20),
          ),
          Expanded(
              child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        var unit = units[index];
                        var serverId = unit['id'].toString();
                        var unitId = unit['unit_id'].toString();
                        return Card(
                            elevation: 4,
                            shadowColor: darkBlue,
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
                              title: Text(unitId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 5, 113, 196))),
                              subtitle: Row(
                                children: <Widget>[
                                  Text(serverId,
                                      style: const TextStyle(
                                          color: AppPallete.darkBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10))
                                ],
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right,
                                  color: Color.fromARGB(255, 5, 113, 196),
                                  size: 40.0),
                              tileColor:
                                  const Color.fromARGB(255, 236, 236, 236),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UnitDetailScreen(
                                      unitId: int.parse(unit['id'].toString()),
                                      title: '',
                                    ),
                                  ),
                                );
                              },
                            ));
                      })))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
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

void _openMapModal(BuildContext context, List<LatLng> unitLocations) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          // height: MediaQuery.of(context).size.height *
          // 0.75, // Adjust the size as needed
          body: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
                target: unitLocations
                    .first, // Initial position to the first unit location
                zoom: 2.0),
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
