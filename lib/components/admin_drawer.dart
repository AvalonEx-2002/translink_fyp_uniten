import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  // Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          children: [
            ListTile(
              title: const Text('View Complaints'),
              leading: Image.asset(
                'lib/images/view_complaints.png', // Path to your image asset
                width: 25.0, // Width of the image
              ),
              onTap: () {
                // Pop the drawer
                Navigator.pop(context);

                // Navigate to complaint form page
                Navigator.pushNamed(context, "/review_complaints");
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
            )
          ],
        ),
      ),
    );
  }
}
