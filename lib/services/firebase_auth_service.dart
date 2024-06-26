import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteUser() async {
    User? user = _auth.currentUser;
    await user?.delete();
  }
}
