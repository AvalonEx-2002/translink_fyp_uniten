import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translink/pages/ride_history.dart';

class MyDrawer extends StatelessWidget {
  // Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          children: [
            ListTile(
              title: const Text('Ride History'),
              leading: Image.asset(
                'lib/images/ride_history_icon.png', // Path to your image asset
                width: 25.0, // Width of the image
              ),
              onTap: () {
                // Pop the drawer
                Navigator.pop(context);

                // Go to passenger Ride History page
                Navigator.pushNamed(context, "/ride_history");
              },
            ),
            ListTile(
              title: const Text('Report Complaint'),
              leading: Image.asset(
                'lib/images/complaint_icon.png', // Path to your image asset
                width: 25.0, // Width of the image
              ),
              onTap: () {
                // Pop the drawer
                Navigator.pop(context);

                // Navigate to complaint form page
                Navigator.pushNamed(context, "/report_complaint");
              },
            ),

            // Pushing the log out button to the bottom of drawer
            Expanded(child: Container()),

            // A divider to separate the log out button from the rest
            const Divider(
              thickness: 2,
              color: Colors.black,
            ),

            ListTile(
              title: const Text(
                "LOG OUT",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Image.asset(
                'lib/images/logout_icon.png', // Path to your image asset
                width: 25.0, // Width of the image
              ),
              onTap: () {
                // Call user log out method
                signUserOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
