import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/profile_avatar.dart';

class ReceivedOffersWidget extends StatelessWidget {
  final String rideId;

  const ReceivedOffersWidget({
    super.key,
    required this.rideId,
  });

  Future<Map<String, dynamic>> fetchDriverDetails(String driverId) async {
    DocumentSnapshot driverDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(driverId)
        .get();
    return driverDoc.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchCarDetails(String ownerId) async {
    QuerySnapshot carQuery = await FirebaseFirestore.instance
        .collection('Cars')
        .where('Owner ID', isEqualTo: ownerId)
        .where('Car Status', isEqualTo: 'Active')
        .limit(1)
        .get();

    if (carQuery.docs.isNotEmpty) {
      return carQuery.docs.first.data() as Map<String, dynamic>;
    }

    return {
      'Car Model': 'No car info available',
      'License Plate': 'N/A',
    };
  }

  // Functions to handle utility button logic
  Future<void> acceptOffer(
    BuildContext context,
    String offerId,
    String driverId,
    String rideId,
    String fareOffer,
  ) async {
    try {
      // Check if the driver is currently handling any ride request
      QuerySnapshot activeRideQuery = await FirebaseFirestore.instance
          .collection('Rides')
          .where('Driver ID', isEqualTo: driverId)
          .where('Ride Status', isEqualTo: 'In Progress')
          .get();

      if (activeRideQuery.docs.isNotEmpty) {
        // Driver is currently handling another ride request
        // Display error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Sorry !',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content:
                const Text('The Driver is busy handling another ride request'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return; // Exit the function
      }

      // Update other offers for the same ride request to 'Rejected'
      QuerySnapshot otherOffersQuery = await FirebaseFirestore.instance
          .collection('Fare Offers')
          .where('Ride ID', isEqualTo: rideId)
          .where('Driver ID', isNotEqualTo: driverId) // Exclude current offer
          .get();

      if (otherOffersQuery.docs.isNotEmpty) {
        for (DocumentSnapshot doc in otherOffersQuery.docs) {
          await doc.reference.update({'Offer Status': 'Rejected'});
        }
      }

      // Update the offer status to 'Accepted'
      await FirebaseFirestore.instance
          .collection('Fare Offers')
          .doc(offerId)
          .update({'Offer Status': 'Accepted'});

      // Update the ride request to include the driver and offer details
      await FirebaseFirestore.instance.collection('Rides').doc(rideId).update({
        'Driver ID': driverId,
        'Ride Status': 'In Progress',
        'Ride Fare': fareOffer,
      });
    } catch (e) {
      // Handle any errors that occur during Firestore operations
      print('Error accepting offer: $e');
      // You might want to show an error message to the user or log the error for further investigation
    }
  }

  Future<void> rejectOffer(String offerId) async {
    // Update the offer status to 'Cancelled'
    await FirebaseFirestore.instance
        .collection('Fare Offers')
        .doc(offerId)
        .update({'Offer Status': 'Rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Fare Offers')
                .where('Ride ID', isEqualTo: rideId)
                .where('Offer Status', isEqualTo: 'Submitted')
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
                      'No offers received yet',
                      style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                children: snapshot.data!.docs.map((offerDoc) {
                  final offerData = offerDoc.data() as Map<String, dynamic>;
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchDriverDetails(offerData['Driver ID']),
                    builder: (context, driverSnapshot) {
                      if (driverSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${driverSnapshot.error}'),
                        );
                      }

                      if (driverSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final driverData = driverSnapshot.data!;
                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchCarDetails(offerData['Driver ID']),
                        builder: (context, carSnapshot) {
                          if (carSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${carSnapshot.error}'),
                            );
                          }

                          if (carSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final carData = carSnapshot.data!;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: ProfileAvatar(
                                    profilePic:
                                        driverData["Profile Picture URL"],
                                    gender: driverData["Gender"],
                                  ),
                                  title: Text(
                                    '${driverData["Full Name"] ?? "Unknown"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (carData["Car Brand"] == null)
                                        Text(
                                          'No car info available',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[500],
                                          ),
                                        )
                                      else
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'Car Model : ',
                                                ),
                                                Text(
                                                  '${carData["Car Brand"]} ${carData["Car Model"]}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Plate Number : ',
                                                ),
                                                Text(
                                                  carData["Plate Number"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Text(
                                            'Offer Amount : ',
                                          ),
                                          Text(
                                            'RM ${offerData["Fare Offer"]}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Driver Rating : "),
                                          Text(
                                            driverData["Star Rating"] == 0
                                                ? "Not Available"
                                                : "${driverData["Star Ratings"] / driverData["Completed Rides"]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  driverData["Star Rating"] == 0
                                                      ? Colors.red[800]
                                                      : null,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          if (driverData["Star Rating"] != 0)
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.star_rounded,
                                                color: Colors.yellow[600],
                                                size: 17,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Line divider
                                const SizedBox(height: 3),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 3),

                                // Utility buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Tooltip(
                                      message: 'Decline Offer',
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Handle delete action
                                          rejectOffer(offerDoc.id);
                                        },
                                      ),
                                    ),
                                    Tooltip(
                                      message: 'Accept Offer',
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          // Handle accept action
                                          acceptOffer(
                                            context,
                                            offerDoc.id,
                                            offerData["Driver ID"],
                                            rideId,
                                            offerData["Fare Offer"],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
