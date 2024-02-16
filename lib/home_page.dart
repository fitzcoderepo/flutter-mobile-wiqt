import 'package:flutter/material.dart';
import 'base_scaffold.dart';
import 'home_content.dart';
import 'services/auth_utils.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomeContent(),
  ];

  void _onNavItemTapped(int index) {
    if (index == 0) {
      const HomeContent();
    }
    if (index == 1) {
      AuthUtils.logout(context);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.title,
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navBarItems,
        onTap: _onNavItemTapped,
        backgroundColor: darkBlue,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}

const _navBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  // BottomNavigationBarItem(icon: Icon(Icons.hub), label: 'Project'),
  BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
];
