import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translink/services/firebase_auth_service.dart';

class FirebaseAuthStateListener extends StatefulWidget {
  final Widget child;
  final FirebaseAuthService authService;

  const FirebaseAuthStateListener({
    required this.child,
    required this.authService,
  });

  @override
  _FirebaseAuthStateListenerState createState() =>
      _FirebaseAuthStateListenerState();
}

class _FirebaseAuthStateListenerState extends State<FirebaseAuthStateListener> {
  @override
  void initState() {
    super.initState();
    // Add Firebase Authentication state listener
    widget.authService.authStateChanges.listen((user) {
      if (user == null) {
        // User is logged out (authentication state invalidated)
        // Perform logout actions here
        // For example:
        Navigator.of(context).pushReplacementNamed('/login');
        // Display a notification to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your account has been banned. Please log in again.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
