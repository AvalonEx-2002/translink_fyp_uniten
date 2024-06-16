import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:translink/pages/driver-specific/driver_ride_offer_form.dart';

class RideOrdersPage extends StatefulWidget {
  const RideOrdersPage({super.key});

  @override
  State<RideOrdersPage> createState() => _RideOrdersPageState();
}

class _RideOrdersPageState extends State<RideOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 8),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange[700],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                "Available Ride Requests",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Expanded(
            child: RideOrderList(),
          ),
        ],
      ),
    );
  }
}

class RideOrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Rides')
          .where('Ride Status', isEqualTo: 'Initiated')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<DocumentSnapshot> rideOrderDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: rideOrderDocs.length,
          itemBuilder: (context, index) {
            final rideOrderData =
                rideOrderDocs[index].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: RideOrderItem(rideOrderData: rideOrderData),
            );
          },
        );
      },
    );
  }
}

class RideOrderItem extends StatelessWidget {
  final Map<String, dynamic> rideOrderData;

  // Get current user ID
  String userID = FirebaseAuth.instance.currentUser!.uid;

  RideOrderItem({required this.rideOrderData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _fetchRideInfo(
              rideOrderData), // Future to fetch ride and passenger info
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                  'Loading...'); // Placeholder while data is being fetched
            }
            if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Display error if fetch fails
            }
            final Map<String, dynamic> rideInfo = snapshot.data!['ride'] ?? {};
            final Map<String, dynamic> passengerInfo =
                snapshot.data!['passenger'] ?? {};
            return _buildTitle(rideInfo,
                passengerInfo); // Build title using ride and passenger info
          },
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15),
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
                      "Date : ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(rideOrderData["Date"]),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(rideOrderData["Time"]),
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
                      "Number of Passengers : ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(rideOrderData["Passenger Pax"].toString()),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Comments : ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  width: 1000,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  child: Text((rideOrderData["Comments"] == "")
                      ? "No comments available"
                      : rideOrderData["Comments"]),
                ),
              ],
            ),
          ),
          ListTile(
            title: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Fare Offers')
                  .where('Ride ID', isEqualTo: rideOrderData["Ride ID"])
                  .where('Driver ID', isEqualTo: userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.data!.docs.isNotEmpty) {
                  // Offer exists for the current user, display offer details
                  final offerData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final fareOffer = offerData['Fare Offer'] as String;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "You have offered : ",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "RM $fareOffer",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // No offer exists for the current user, display "Make an Offer" button
                  return TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DriverRideOfferForm(
                            rideOrderID: rideOrderData["Ride ID"],
                            driverID: userID,
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Make an Offer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchRideInfo(
      Map<String, dynamic> rideOrderData) async {
    // Fetch user info from Firebase
    final String passengerID = rideOrderData["Passenger ID"];
    final passengerDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(passengerID)
        .get();
    final passengerInfo = passengerDoc.data() as Map<String, dynamic>;

    // Combine and return ride and passenger info
    return {
      'ride': rideOrderData,
      'passenger': passengerInfo,
    };
  }

  Widget _buildTitle(
      Map<String, dynamic> rideInfo, Map<String, dynamic> passengerInfo) {
    final String ridePickup = rideInfo['Pickup'] ?? 'Unknown Pickup';
    final String rideDestination =
        rideInfo['Destination'] ?? 'Unknown Destination';
    final String passengerName =
        passengerInfo['Full Name'] ?? 'Unknown Passenger';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 70, // Adjusted height to account for border and padding
          child: Container(
            padding: const EdgeInsets.all(
                3), // Space between CircleAvatar and border
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black, // Border color
                width: 2, // Border width
              ),
            ),
            child: CircleAvatar(
              radius: 27, // Adjusted radius to account for border and padding
              backgroundColor: Colors.transparent,
              backgroundImage: passengerInfo["Profile Picture URL"].isEmpty
                  ? (passengerInfo["Gender"] == "Male"
                      ? Image.asset("lib/images/profile_pic.png").image
                      : Image.asset("lib/images/profile_pic_female.png").image)
                  : NetworkImage(passengerInfo["Profile Picture URL"]),
            ),
          ),
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  "Name : ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  passengerName,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                const SizedBox(
                  width: 3,
                ),
                const Text(
                  "Pickup : ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  ridePickup,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                const SizedBox(
                  width: 3,
                ),
                const Text(
                  "Destination : ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  rideDestination,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
