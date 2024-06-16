import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideOrderFormPage extends StatefulWidget {
  const RideOrderFormPage({super.key});

  @override
  State<RideOrderFormPage> createState() => _RideOrderFormPageState();
}

class _RideOrderFormPageState extends State<RideOrderFormPage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  int _passengers = 1;

  void submitRideOrder() async {
    String pickup = _pickupController.text.trim();
    String destination = _destinationController.text.trim();
    String date = _parseDate(_dateController.text.trim());
    String time = _timeController.text.trim();
    int passengers = _passengers;
    String comments = _commentsController.text.trim();

    // Get current user instance
    User? user = FirebaseAuth.instance.currentUser;

    // Validate input
    if (pickup.isEmpty ||
        destination.isEmpty ||
        date.isEmpty ||
        time.isEmpty ||
        passengers.toString().isEmpty) {
      print(pickup +
          " " +
          destination +
          " " +
          date +
          " " +
          time +
          " " +
          passengers.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Error !',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Please fill in all required fields'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Submit ride order to Firestore
    try {
      // Get the count of documents in the 'Rides' collection
      int documentCount =
          (await FirebaseFirestore.instance.collection('Rides').get())
              .docs
              .length;
      documentCount = documentCount + 1;

      String rideId = "UNI10 RDE $documentCount";

      // Create the ride document data
      Map<String, dynamic> rideData = {
        'Pickup': pickup,
        'Destination': destination,
        'Date': date,
        'Time': time,
        'Passenger Pax': passengers,
        'Comments': comments,
        'Ride Status': 'Initiated',
        'Passenger ID': user?.uid,
        'Driver ID': '',
        'Ride ID': rideId, // Include the Ride ID in the document data
      };

      // Set the document with the calculated ID
      await FirebaseFirestore.instance
          .collection('Rides')
          .doc(rideId)
          .set(rideData);

      // Navigate back to previous page
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to submit ride order'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void incrementPassenger() {
    setState(() {
      _passengers++;
    });
  }

  void decrementPassenger() {
    setState(() {
      if (_passengers > 1) {
        _passengers--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Set initial values to current date and time
    _dateController.text = _formatDate(DateTime.now());
    _timeController.text = _formatTime(TimeOfDay.now());
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  String _parseDate(String dateString) {
    final DateFormat format = DateFormat('dd/MM/yyyy');
    final DateTime parsedDate = format.parse(dateString);
    return _formatDate(parsedDate);
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Ride Order Form',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            height: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _pickupController,
              decoration: const InputDecoration(
                labelText: 'Pickup Location',
                prefixIcon: Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16.0,
            ),

            // Date & time controller
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      // Show date picker
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      // Show time picker
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _timeController.text = _formatTime(pickedTime);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16.0,
            ),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller:
                        TextEditingController(text: _passengers.toString()),
                    decoration: const InputDecoration(
                      labelText: 'Number of Passengers',
                      prefixIcon: Icon(
                        Icons.people_alt_sharp,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: decrementPassenger,
                  child: Icon(Icons.remove),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  onPressed: incrementPassenger,
                  child: const Icon(Icons.add),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16.0,
            ),

            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),

            const SizedBox(
              height: 20.0,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    // Background color
                    backgroundColor: Colors.red,

                    // Button padding
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),

                    side: const BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 30,
                ),

                // Submit button
                ElevatedButton(
                  onPressed: submitRideOrder,
                  style: ElevatedButton.styleFrom(
                    // Background color
                    backgroundColor: Colors.greenAccent,

                    // Button padding
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),

                    side: const BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
