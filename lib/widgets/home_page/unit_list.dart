import 'package:flutter/material.dart';
import 'package:wateriqcloud_mobile/views/unit_detail_screen.dart';
import '../../main.dart';

class UnitList extends StatefulWidget {
  final List<dynamic> units;
  final bool isLoading;

  const UnitList({super.key, required this.units, required this.isLoading});

  @override
  _UnitListState createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {

  @override
  Widget build(BuildContext context) {
   if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
   } 

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.units.length,
        itemBuilder: (context, index) {
          var unit = widget.units[index];
          var serverId = unit['id'].toString();
          var unitId = unit['unit_id'].toString();
          var lat = double.parse(unit['lat']);
          var long = double.parse(unit['long']);
          var installed = unit['installed'];
          var decomm = unit['decommissioned'];
          dynamic active;
          if (installed == true && decomm == false) {
            active = const Icon(Icons.cloud_outlined, color: Colors.blue);
          } else if (installed == true && decomm == true) {
            active = const Icon(Icons.cloud_off_rounded,
                color: Color.fromARGB(252, 178, 178, 178));
          } else if (installed == false && decomm == false) {
            active = "Not Installed";
          }

          return Card(
            elevation: 6,
            margin: const EdgeInsets.all(7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.blue,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UnitDetailScreen(
                      unitId: int.parse(unit['id'].toString()),
                      lat: lat,
                      long: long,
                      title: '',
                    ),
                  ),
                );
              },
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enableFeedback: true,
                leading: Container(
                    padding: const EdgeInsets.only(right: 20.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 1.0, color: Colors.blue),
                      ),
                    ),
                    child: active),
                title: Text(
                  unitId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      serverId,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Color.fromARGB(255, 5, 113, 196),
                  size: 40.0,
                ),
                tileColor: const Color.fromARGB(255, 236, 236, 236),
              ),
            ),
          );
       },
      );
  }
}
