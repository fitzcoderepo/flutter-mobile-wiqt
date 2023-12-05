import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'unit_detail_screen.dart';
import 'dart:convert';
import 'dart:io' show Platform;

// Define the colors
const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterIQ Cloud',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: darkBlue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = FlutterSecureStorage();
  Map<String, dynamic> projectData = {};
  List units = [];
  bool isLoading = true;
  bool _isLocalIphone = false;
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
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

  void _logout() async {
    await _storage.delete(
        key: 'auth_token'); // Delete the token from secure storage

    // Navigate back to the LoginScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightBlue,
          title: Text(widget.title),
          leading: Builder(
            // Use Builder here
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: darkBlue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle the tap
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Handle the tap
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  _logout(); // Call the logout method
                },
              ),
              // Add more ListTile widgets if needed
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Project: ${projectData['name'] ?? ''}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Location: ${projectData['location'] ?? ''}'),
                      Divider(),
                      Text(
                        'Units:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          int unitId = units[index];
                          return ListTile(
                            title: Text('Unit - ID: $unitId'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // TODO: Navigate to the unit detail page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UnitDetailScreen(unitId: unitId),
                                ),
                              );
                            },
                            // tileColor:
                            //     Colors.lightBlue[50], // Light background color
                            // selectedTileColor: Colors.lightBlue[100],
                          );
                        },
                      )
                    ]),
              ));
  }
}
