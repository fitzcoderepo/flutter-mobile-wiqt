import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'unit_detail_screen.dart';
import '../services/api_services.dart';
import '../widgets/drawer.dart';


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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    )

    ); // Centers the column (title and image) in the AppBar
    
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
