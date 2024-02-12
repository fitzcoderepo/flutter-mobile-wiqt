import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'unit_detail_screen.dart';
import 'base_scaffold.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic> projectData = {};
  List units = [];
  bool isLoading = true;
  final bool _isLocalIphone = false;

  String getBaseUrl() {
    if (Platform.isAndroid) {
      // return "http://10.0.2.2:8000";
      return "http://192.168.1.202:8000";
    } else if (_isLocalIphone) {
      return "http://192.168.1.139:8000";
    } else if (Platform.isIOS) {
      return "http://127.0.0.1:8000";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProjectData();
  }

  Future<void> _fetchProjectData() async {
    var baseUrl = getBaseUrl();
    final token =
        await _storage.read(key: 'auth_token'); // Retrieve the stored token
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/project-list'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        projectData = json.decode(response.body);
        units = projectData['units'] as List;
        isLoading = false;
      });
    } else {
      // Handle error
    }
  }

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
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 20),
                child: Text('${projectData['location'] ?? ''}',
                    style: const TextStyle(
                      color: darkBlue,
                      fontSize: 24,
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
                                  fontSize: 20,
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
