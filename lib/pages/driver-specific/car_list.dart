import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translink/pages/driver-specific/car_registration.dart';
import 'package:translink/pages/driver-specific/edit_car_profile.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({
    super.key,
  });

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  // Get current user
  final _user = FirebaseAuth.instance.currentUser;

  // Delete car method
  Future<void> deleteCar(String carId) async {
    try {
      // Query the car collection to find the document with the provided carId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Cars')
          .where('Car ID', isEqualTo: carId)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document found (assuming there's only one with the given carId)
        DocumentSnapshot carDoc = querySnapshot.docs.first;

        // Get a reference to the car document
        DocumentReference carRef =
            FirebaseFirestore.instance.collection('Cars').doc(carDoc.id);

        // Delete the document
        await carRef.delete();

        // Show a success message or perform any other actions upon successful deletion
        print('Car deleted successfully');
      } else {
        print('No car found with the provided ID: $carId');
      }
    } catch (e) {
      // Handle any errors that occur during deletion
      print('Error deleting car: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Cars')
                  .where('Owner ID', isEqualTo: _user?.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No cars registered',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                      padding: const EdgeInsets.fromLTRB(5, 15, 0, 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey,
                            shape: BoxShape.rectangle,
                            image: data["Car Picture URL"].isEmpty
                                ? const DecorationImage(
                                    image: AssetImage(
                                        'lib/images/car_icon.png'),
                                  )
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        Image.network(data["Car Picture URL"])
                                            .image),
                          ),
                        ),
                        title: Text(
                          data['Car Brand'] + ' ' + data['Car Model'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Text(
                              'Car Plate : ',
                            ),
                            Text(
                              '${data['Plate Number']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red[600],
                              onPressed: () {
                                // Implement delete functionality
                                // Delete car info from Firebase
                                deleteCar(data["Car ID"]);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Colors.blueAccent[400],
                              onPressed: () {
                                // Navigate to edit car profile page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCarProfile(
                                      carID: data["Car ID"],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement register new car functionality
                      // Navigate to register car page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CarRegistration()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // Background color
                      backgroundColor: Colors.deepPurple[300],

                      // Button padding
                      padding: const EdgeInsets.all(20),

                      side: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      "Register New Car",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
