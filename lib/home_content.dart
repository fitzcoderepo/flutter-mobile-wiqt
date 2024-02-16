import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'unit_detail_screen.dart';
import 'base_scaffold.dart';
import 'services/api_service.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Map<String, dynamic> projectData = {};
  List units = [];
  bool isLoading = true;
  var projectData;
  final _apiService = ProjectApi(storage: const FlutterSecureStorage());

  Future<void> _fetchProjectData() async {
    try {
      var data = await _apiService.fetchProjectData();
      setState(() {
        projectData = data;
        units = projectData['units'] as List;
        isLoading = false;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectData();
  }

  // Future<void> _fetchProjectData() async {
  //   var baseUrl = BaseUrl.getBaseUrl();
  //   final token =
  //       await _storage.read(key: 'auth_token'); // Retrieve the stored token
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/api/v1/project-list'),
  //     headers: {'Authorization': 'Token $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       projectData = json.decode(response.body);
  //       units = projectData['units'] as List;
  //       isLoading = false;
  //     });
  //   } else {
  //     // Handle error
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return isLoading
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
                          color: const Color.fromARGB(220, 255, 255, 255),
                          elevation: 8,
                          shadowColor: darkBlue,
                          margin: const EdgeInsets.all(10),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(_createRoute(unitId));
                            },
                            child: Text("Unit ID \n $unitId ",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        );
                      }))
            ],
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
