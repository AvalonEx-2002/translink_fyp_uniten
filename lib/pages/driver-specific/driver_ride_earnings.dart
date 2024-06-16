import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:translink/components/my_app_bar.dart';

class DriverEarningsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: EarningsList(),
    );
  }
}

class EarningsList extends StatelessWidget {
  // Get current user instance
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Rides')
          .where('Driver ID',
              isEqualTo: user?.uid) // Filter by current user UID
          .where('Ride Status', isEqualTo: 'Completed') // Filter by ride status
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<DocumentSnapshot> rideDocs = snapshot.data!.docs;
        final todayEarnings = calculateTodayEarnings(rideDocs);
        final weekEarnings = calculateWeekEarnings(rideDocs);
        final totalEarnings = calculateTotalEarnings(rideDocs);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  "Ride Earnings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 20, 15, 0),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Today's Earnings : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("RM $todayEarnings"),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "This Week's Earnings : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("RM $weekEarnings"),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Total Earnings : ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("RM $totalEarnings"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String getFormattedDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  double calculateTodayEarnings(List<DocumentSnapshot> rideDocs) {
    final now = DateTime.now();
    final today = getFormattedDate(now);
    double earnings = 0.0;
    for (final rideDoc in rideDocs) {
      final rideData = rideDoc.data() as Map<String, dynamic>;
      final rideDate = rideData['Date'];
      if (rideDate == today) {
        earnings += int.parse(rideData['Ride Fare']);
      }
    }
    return earnings;
  }

  double calculateWeekEarnings(List<DocumentSnapshot> rideDocs) {
    final now = DateTime.now();
    final today = getFormattedDate(now);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    double earnings = 0.0;
    for (final rideDoc in rideDocs) {
      final rideData = rideDoc.data() as Map<String, dynamic>;
      final rideDate = rideData['Date'];
      final rideDateTime = DateFormat('yyyy-MM-dd').parse(rideDate);
      if (rideDate.compareTo(today) >= 0 && rideDateTime.isAfter(weekStart)) {
        earnings += int.parse(rideData['Ride Fare']);
      }
    }
    return earnings;
  }

  double calculateTotalEarnings(List<DocumentSnapshot> rideDocs) {
    // Sum up earnings from all ride data
    double earnings = 0.0;
    for (final rideDoc in rideDocs) {
      final rideData = rideDoc.data() as Map<String, dynamic>;
      earnings += int.parse(rideData[
          'Ride Fare']); // Assuming fare is stored in each ride document
    }
    return earnings;
  }
}
