import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wateriqcloud_mobile/services/storage_services/storage_manager.dart';
import '../models/wiqc_notifications.dart';
import 'unit_detail_screen.dart';
import '../services/wiqc_api_services/api_services.dart';
import '../widgets/drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
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
              child: SvgPicture.asset(
                'assets/images/CircleLogo.svg',
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
                const SizedBox(height: 25),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${projectData['name'] ?? ''}\n',
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${projectData['location'] ?? ''}',
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                const SizedBox(height: 25),
                Expanded(
                  // child: GridView.builder(
                  //     gridDelegate:
                  //         const SliverGridDelegateWithFixedCrossAxisCount(
                  //             crossAxisCount: 1),
                  //     itemCount: units.length,
                  //     itemBuilder: (context, index) {
                  //       final unitId = units[index];
                  //       final unitDetails = unitDetailsMap[unitId.toString()];
                  // final unitReports = unitReportsMap[unitId.toString()];

                  // final ssid = unitDetails?['ssid'] ?? 'Unknown SSID';
                  child: ReorderableListView.builder(
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        final unitId = units[index];
                        final unitDetails = unitDetailsMap[unitId.toString()];
                        final ssid = unitDetails?['ssid'] ?? 'Unknown SSID';
                        return Card(
                          // Key used for each unit for reorderableListView
                          key: ValueKey(unitId),
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 7.0),

                          child: ListTile(
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                            enableFeedback: true,
                            leading: Container(
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: 1.0, color: darkBlue))),
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
                                Text("ID ${unitId.toString()}",
                                    style: const TextStyle(
                                        color: darkBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10))
                              ],
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right,
                                color: darkBlue, size: 40.0),
                            onTap: () {
                              Navigator.of(context).push(_createRoute(unitId));
                            },
                            tileColor: const Color.fromARGB(255, 233, 234, 235),
                          ),
                          // trailing: Text(notification.payload.toString()),
                        );

                        // Card(
                        //   clipBehavior: Clip.antiAlias,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(35),
                        //   ),
                        //   color: const Color.fromARGB(255, 255, 255, 255),
                        //   elevation: 8,
                        //   shadowColor: Colors.grey.withOpacity(0.5),
                        //   child: InkWell(
                        //     onTap: () {
                        //       Navigator.of(context)
                        //           .push(_createRoute(unitId));
                        //     },
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Column(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: <Widget>[
                        //           Text(
                        //             '$ssid',
                        //             style: const TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: darkBlue),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //           Text(
                        //             "ID $unitId",
                        //             style: const TextStyle(
                        //                 fontSize: 8,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: darkBlue),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final unitId = units.removeAt(oldIndex);
                        units.insert(newIndex, unitId);
                        try {
                          print('Attempting to save unit order');
                          saveUnitOrder(units);
                        } catch (e) {
                          print('Failed to save unit order $e');
                        }
                      }),
                )
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
