import 'package:flutter/material.dart';

// Define the colors
const Color lightBlue = Color(0xFFD3E8F8);
const Color darkBlue = Color(0xFF17366D);

// Base navigation class for all views
class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final BottomNavigationBar? bottomNavigationBar;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
  });

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
            // Text(title, style: const TextStyle(fontSize:15, color: Colors.white)),
          ],
        ),
        centerTitle: true, // Centers the column (title and image) in the AppBar
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
