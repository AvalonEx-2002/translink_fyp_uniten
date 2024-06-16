import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:translink/authentication/auth_page.dart';
import 'package:translink/pages/admin-specific/review_complaints.dart';
import 'package:translink/pages/driver-specific/driver_ride_earnings.dart';
import 'package:translink/pages/driver-specific/driver_ride_history.dart';
import 'package:translink/pages/report_complaint.dart';
import 'package:translink/pages/ride_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBKWcvidHcVddGCm2a0s9L8tFQSKjpJlZg",
      appId: "1:23346528162:android:d9eda0409b7bc965873cfb",
      messagingSenderId: "23346528162",
      projectId: "translink-64a22",
      authDomain: "translink-64a22.firebaseapp.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TransLink Mobile App",
      home: const AuthPage(),
      routes: {
        "/ride_history": (context) => RideHistoryPage(),
        "/report_complaint": (context) => const ReportComplaint(),
        "/driver_earnings": (context) => DriverEarningsPage(),
        "/driver_ride_history": (context) => DriverRideHistoryPage(),
        "/review_complaints": (context) => const ReviewComplaintsPage(),
      },
    );
  }
}
