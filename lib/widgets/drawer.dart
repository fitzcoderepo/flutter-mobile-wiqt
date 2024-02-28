import 'package:flutter/material.dart';
import '../services/auth_utils.dart';

const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: darkBlue,
            ),
            child: Text(
              'WaterIQ Technologies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthUtils.logout(context);
            },
          ),
        
        ],
      ),
      
    );
    
  }
}
