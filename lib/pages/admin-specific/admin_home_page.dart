import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/admin_drawer.dart';
import 'package:translink/components/my_app_bar.dart';
import 'package:translink/pages/admin-specific/admin_profile_page.dart';
import 'package:translink/pages/admin-specific/all_ride_history.dart';
import 'package:translink/pages/admin-specific/all_users_list.dart';
import 'package:translink/pages/chat_rooms_list.dart';
import 'package:translink/pages/home_display_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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

    // All ride history page (index 1)
    AdminRideHistoryPage(),

    // All user list page (index 2)
    AllUsersPage(),

    // Chat page (index 3)
    ChatRoomsPage(),

    // Profile page (index 4)
    AdminProfilePage(),
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
            title: Text('Ride History'),
            activeColor: Colors.red,
          ),
          const BottomBarItem(
            icon: Icon(Icons.person_search),
            title: Text('User List'),
            activeColor: Colors.purple,
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

      // App drawer
      drawer: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: const AdminDrawer(),
      ),
    );
  }
}
