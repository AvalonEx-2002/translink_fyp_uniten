import 'package:bottom_bar/bottom_bar.dart';
import 'package:cool_nav/cool_nav.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/my_app_bar.dart';
import 'package:translink/components/my_drawer.dart';
import 'package:translink/pages/chat_rooms_list.dart';
import 'package:translink/pages/current_ride_order.dart';
import 'package:translink/pages/home_display_page.dart';
import 'package:translink/pages/user_profile.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    // Home page
    HomeDisplayPage(),

    // Order a ride page
    CurrentRideOrderPage(),

    // Chat page
    ChatRoomsPage(),

    // Profile page
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: _pages[_selectedIndex],

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
            icon: Icon(Icons.hail),
            title: Text('Order a Ride'),
            activeColor: Colors.red,
          ),
          BottomBarItem(
            icon: const Icon(Icons.chat),
            title: const Text('Chat'),
            activeColor: Colors.greenAccent.shade700,
          ),
          const BottomBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
            activeColor: Colors.orange,
          ),
        ],
      ),

      /*
      bottomNavigationBar: FlipBoxNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          verticalPadding: 20.0,
          items: <FlipBoxNavigationBarItem>[
            FlipBoxNavigationBarItem(
              name: 'Home',
              selectedIcon: Icons.home,
              selectedBackgroundColor: Colors.deepPurpleAccent[200]!,
              unselectedBackgroundColor: Colors.deepPurpleAccent[100]!,
            ),
            FlipBoxNavigationBarItem(
              name: 'Order a Ride',
              selectedIcon: Icons.hail,
              unselectedIcon: Icons.hail_outlined,
              selectedBackgroundColor: Colors.indigoAccent[200]!,
              unselectedBackgroundColor: Colors.indigoAccent[100]!,
            ),
            FlipBoxNavigationBarItem(
              name: 'Chat',
              selectedIcon: Icons.chat,
              unselectedIcon: Icons.chat_outlined,
              selectedBackgroundColor: Colors.blueAccent[200]!,
              unselectedBackgroundColor: Colors.blueAccent[100]!,
            ),
            FlipBoxNavigationBarItem(
              name: 'Profile',
              selectedIcon: Icons.person,
              unselectedIcon: Icons.person_outline,
              selectedBackgroundColor: Colors.blueAccent[200]!,
              unselectedBackgroundColor: Colors.blueAccent[100]!,
            ),
          ]
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hail),
            label: 'Order a Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

        // Call the method to switch between pages
        onTap: _navigateBottomBar,
        currentIndex: _selectedIndex,

        // Selected item UI / UX
        selectedItemColor: Colors.blue,
        selectedIconTheme: const IconThemeData(
          color: Colors.blue,
          size: 25,
        ),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedFontSize: 15,

        // Unselected item UI / UX
        unselectedItemColor: Colors.grey,

        // Other BottomNavigationBar elements UI / UX
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[300],
        mouseCursor: SystemMouseCursors.grab,
        elevation: 25,
      ),
      */

      // App drawer
      drawer: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: const MyDrawer(),
      ),
    );
  }
}
