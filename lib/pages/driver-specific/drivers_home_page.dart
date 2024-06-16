import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/driver_drawer.dart';
import 'package:translink/components/my_app_bar.dart';
import 'package:translink/pages/chat_rooms_list.dart';
import 'package:translink/pages/driver-specific/available_ride_orders.dart';
import 'package:translink/pages/driver-specific/car_list.dart';
import 'package:translink/pages/home_display_page.dart';
import 'package:translink/pages/user_profile.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  // Keeps track of the current page to display
  int _selectedIndex = 0;

  // This method updates the new selected page index
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // The list of pages available in the app
  final List _pages = [
    // Home page (index 0)
    HomeDisplayPage(),

    // Order a ride page (index 1)
    RideOrdersPage(),

    // Chat page (index 2)
    ChatRoomsPage(),

    // Car list page (for Drivers)
    CarListPage(),

    // Profile page (index 4)
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: _pages[_selectedIndex],

      // Bottom navigation bar
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: <BottomBarItem>[
          const BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.blue,
          ),
          const BottomBarItem(
            icon: Icon(Icons.list_alt),
            title: Text('Ride Requests'),
            activeColor: Colors.red,
          ),
          BottomBarItem(
            icon: const Icon(Icons.chat),
            title: const Text('Chat'),
            activeColor: Colors.greenAccent.shade700,
          ),
          const BottomBarItem(
            icon: Icon(Icons.car_crash),
            title: Text('Vehicle List'),
            activeColor: Colors.purple,
          ),
          const BottomBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
            activeColor: Colors.orange,
          ),
        ],
      ),

      // App drawer
      drawer: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: const DriverDrawer(),
      ),
    );
  }
}
