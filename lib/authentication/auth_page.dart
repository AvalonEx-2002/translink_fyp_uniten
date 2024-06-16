import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translink/authentication/login_or_register.dart';
import 'package:translink/pages/admin-specific/admin_home_page.dart';
import 'package:translink/pages/driver-specific/drivers_home_page.dart';
import 'package:translink/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if user is logged in
          if (snapshot.hasData) {
            // Access Firestore to get the field value
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Loading state
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (userSnapshot.hasError) {
                  // Handle error
                  return const LoginOrRegisterPage();
                } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  var fieldValue = userSnapshot.data!['Role'];
                  // Return different home pages based on the field value
                  if (fieldValue == 'Driver') {
                    return const DriverHomePage();
                  } else if (fieldValue == 'Admin') {
                    return const AdminHomePage();
                  } else {
                    return HomePage();
                  }
                } else {
                  // Handle missing data
                  return const LoginOrRegisterPage();
                }
              },
            );
          } else {
            // User is not logged in, show login/register page
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
