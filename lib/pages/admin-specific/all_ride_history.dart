import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translink/services/util_function_services.dart';

class AdminRideHistoryPage extends StatefulWidget {
  const AdminRideHistoryPage({super.key});

  @override
  _AdminRideHistoryPageState createState() => _AdminRideHistoryPageState();
}

class _AdminRideHistoryPageState extends State {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Function to get user's full name based on user ID
  Future<String?> getUserName(String userId) async {
    try {
      // Retrieve user data from Firestore using the provided user ID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      // Check if user exists
      if (userSnapshot.exists) {
        // Extract user data as Map<String, dynamic>
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        // Get the user's full name from user data
        String? fullName = userData['Full Name'] as String?;
        return fullName;
      } else {
        // Handle case where user does not exist
        print('User not found');
        return null; // Return null to indicate user not found
      }
    } catch (e) {
      // Handle any errors that occur
      print('Error getting user\'s full name: $e');
      return null; // Return null to indicate error
    }
  }

  // Function to search for user ID based on partial name match
  Future<List<String>> _searchUserIds(String partialName) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('Full Name', isGreaterThanOrEqualTo: partialName)
        .where('Full Name',
            isLessThan:
                partialName + 'z') // Assume 'z' is the highest character
        .get();

    List<String> userIds = [];
    for (var userDoc in usersSnapshot.docs) {
      userIds.add(userDoc.id);
    }

    return userIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.red[400],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 15),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by a user's name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) async {
                List<String> userIds = await _searchUserIds(value);
                if (userIds.isNotEmpty) {
                  setState(() {
                    _searchQuery = userIds.first;
                  });
                } else {
                  setState(() {
                    _searchQuery = '';
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('User Not Found'),
                      content:
                          const Text('No user found with the entered name.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Rides').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final List<DocumentSnapshot> rideDocs = snapshot.data!.docs;
                final filteredRideDocs = rideDocs.where((rideDoc) {
                  final rideData = rideDoc.data() as Map<String, dynamic>;
                  final userId =
                      rideData['Passenger ID'].toString().toLowerCase();
                  final rideId = rideDoc.id.toString().toLowerCase();
                  return userId.contains(_searchQuery) ||
                      rideId.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredRideDocs.length,
                  itemBuilder: (context, index) {
                    final rideData =
                        filteredRideDocs[index].data() as Map<String, dynamic>;
                    final passengerId = rideData['Passenger ID'];
                    final driverId = rideData['Driver ID'];

                    return FutureBuilder(
                      future: Future.wait([
                        getUserName(passengerId),
                        getUserName(driverId),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<String?>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final List<String?> names = snapshot.data!;
                          final passengerName = names[0];
                          final driverName = names[1];

                          return Card(
                            color: Colors.grey[100],
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 25),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                width: 2,
                                color: Colors.black,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.content_paste_search,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Ride ID : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(filteredRideDocs[index].id),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.local_taxi,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Driver : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      driverName != null
                                          ? Text(driverName)
                                          : const Text('Not Yet Available'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.hail_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Passenger : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('$passengerName'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range_sharp,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Date : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(rideData['Date']),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_filled,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Time : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(rideData['Time']),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.money,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Fare : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      rideData["Ride Fare"] != null
                                          ? Text('RM ' + rideData['Ride Fare'])
                                          : const Text('Not Yet Available'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.comment,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Comment : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      rideData["Comments"] != null
                                          ? Text(rideData['Comments'])
                                          : const Text('Not Available'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'From : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(UtilityFunction.truncateText(
                                          rideData["Pickup"], 40)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'To : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(UtilityFunction.truncateText(
                                          rideData["Destination"], 40)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.summarize,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Status : ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(rideData["Ride Status"]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
