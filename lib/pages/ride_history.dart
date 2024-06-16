import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translink/components/my_app_bar.dart';

class RideHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                "Ride History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Expanded(
            child: RideHistoryList(),
          ),
        ],
      ),
    );
  }
}

class RideHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text('Error: User not logged in'),
          );
        }
        final user = snapshot.data!;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Rides')
              .where('Passenger ID', isEqualTo: user.uid)
              .where("Ride Status", isEqualTo: "Completed")
              .snapshots(),
          builder: (context, rideSnapshot) {
            if (rideSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (rideSnapshot.hasError) {
              return Center(child: Text('Error: ${rideSnapshot.error}'));
            }
            final List<QueryDocumentSnapshot> rideDocs =
                rideSnapshot.data!.docs;
            return ListView.builder(
              itemCount: rideDocs.length,
              itemBuilder: (context, index) {
                final rideData = rideDocs[index].data() as Map<String, dynamic>;
                final driverId = rideData['Driver ID'];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(driverId)
                      .get(),
                  builder: (context, driverSnapshot) {
                    if (driverSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (driverSnapshot.hasError) {
                      return Text('Error: ${driverSnapshot.error}');
                    }
                    final driverData =
                        driverSnapshot.data!.data() as Map<String, dynamic>;
                    // Additional user info
                    final String profilePicUrl =
                        driverData['Profile Picture URL'];
                    final String driverName = driverData['Full Name'];

                    return Container(
                      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors
                                  .black, // Choose the color of the outline
                              width: 2, // Choose the width of the outline
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: profilePicUrl == ""
                                ? Image.asset(
                                        "lib/images/default_profile_pic.png")
                                    .image
                                : NetworkImage(
                                    profilePicUrl), // Placeholder image
                          ),
                        ),
                        /*
                        title: Row(
                          children: [
                            const Text(
                              'Ride ID: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              rideDocs[index].id.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        */
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Driver : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(driverName),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Date : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(rideData["Date"]),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Time : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(rideData["Time"]),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Ride Fare : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("RM " + rideData["Ride Fare"]),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "From : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(rideData["Pickup"]),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "To : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(rideData["Destination"]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
