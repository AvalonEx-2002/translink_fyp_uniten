import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/profile_avatar.dart';
import 'package:translink/pages/accepted_offer_widget.dart';
import 'package:translink/pages/received_offers_widget.dart';
import 'package:translink/pages/ride_order_form_page.dart';
import 'package:translink/services/userData_service.dart';
import 'package:translink/services/util_function_services.dart';

class CurrentRideOrderPage extends StatefulWidget {
  const CurrentRideOrderPage({super.key});

  @override
  State<CurrentRideOrderPage> createState() => _CurrentRideOrderPageState();
}

class _CurrentRideOrderPageState extends State<CurrentRideOrderPage> {
  // Get current user instance
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileField();
  }

  Future<void> _fetchUserProfileField() async {
    try {
      profilePic =
          await fetchUserProfileField(user!.uid, "Profile Picture URL");
      gender = await fetchUserProfileField(user!.uid, "Gender");
      name = await fetchUserProfileField(user!.uid, "Full Name");

      // Update the state to trigger a rebuild with the fetched data
      setState(() {});
    } catch (error) {
      // Handle error
      print("Error fetching user data: $error");
    }
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (rideData != null && rideData?["Ride Status"] != "") {
      // If there's already a ride order, return null to disable the button
      return null;
    } else {
      // If no ride order, return the FloatingActionButton
      return Tooltip(
        message: 'Create a new ride order',
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RideOrderFormPage()),
            );
          },
          backgroundColor: Colors.greenAccent, // Button background color
          elevation: 4, // Elevation of the button
          child: const Icon(Icons.add_location_alt), // Button icon
        ),
      );
    }
  }

  // Data variables
  String profilePic = "";
  String name = "";
  String gender = "";
  Map<String, dynamic>? rideData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Rides')
            .where('Passenger ID', isEqualTo: user?.uid)
            .where('Ride Status', whereIn: ['Initiated', 'In Progress'])
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                child: const Text(
                  'Oh no ... It seems that you have no ongoing ride request!',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }

          // Retrieve the data from the first document
          final rideDocument = snapshot.data!.docs.first;
          rideData = rideDocument.data() as Map<String, dynamic>;

          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Current Ride Request",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile picture component
                          ProfileAvatar(profilePic: profilePic, gender: gender),

                          const SizedBox(width: 10),

                          // Upper component of current ride request
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Name: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(name),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'From: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(UtilityFunction.truncateText(
                                      rideData?["Pickup"] ?? '', 30)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 25,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'To: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(UtilityFunction.truncateText(
                                      rideData?["Destination"], 30)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Line divider
                      const SizedBox(height: 10),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Other ride details
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 10),
                          const Text(
                            "Date & Time : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(rideData?["Date"]),
                          Text(" at " + rideData?["Time"]),
                        ],
                      ),
                      const SizedBox(height: 3),

                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 10),
                          const Text(
                            "Number of Passengers : ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(rideData?["Passenger Pax"]?.toString() ??
                              "No data specified"),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 8),
                          SizedBox(width: 10),
                          Text(
                            "Comments :",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 3,
                        ),
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black,
                          ),
                        ),
                        child: Text(rideData?["Comments"]?.isEmpty ?? true
                            ? "No comments"
                            : rideData!["Comments"]),
                      ),
                    ],
                  ),
                ),

                // Received driver offers section
                const SizedBox(height: 20),
                if (rideData != null && rideData?["Ride Status"] == "Initiated")
                  Expanded(
                    child: ReceivedOffersWidget(rideId: rideDocument.id),
                  ),

                // Accepted driver offer section
                if (rideData != null &&
                    rideData?["Ride Status"] == "In Progress")
                  Expanded(
                    child: AcceptedOffersWidget(
                      rideId: rideDocument.id,
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // Action button to navigate to Ride Order Form
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }
}
