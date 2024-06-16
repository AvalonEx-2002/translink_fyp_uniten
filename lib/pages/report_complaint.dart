import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:translink/components/my_alert_dialog.dart';
import 'package:translink/components/my_app_bar.dart';

class ReportComplaint extends StatefulWidget {
  const ReportComplaint({super.key});

  @override
  State<ReportComplaint> createState() => _ReportComplaintState();
}

class _ReportComplaintState extends State<ReportComplaint> {
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Get user instance from Firebase
  User? user = FirebaseAuth.instance.currentUser;

  File? _imageFile;

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

  String _formatTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    // Upload image to Firebase Storage
    String imageUrl = "";
    if (_imageFile != null) {
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('complaint_images')
          .child(DateTime.now().toString() + '.jpg');
      await storageRef.putFile(_imageFile!);
      imageUrl = await storageRef.getDownloadURL();
    }

    // Submit complaint to Firebase Firestore
    var complaintData = {
      'Complaint Description': _complaintController.text,
      'Supporting Picture URL': imageUrl,
      'Date': _dateController.text, // Fixed: Store date as text
      'Time': _timeController.text, // Fixed: Store time as text
      'Sender ID': user?.uid,
      'Resolution Status': 'Pending',
    };

    // Query to get the count of documents in the collection
    var querySnapshot =
        await FirebaseFirestore.instance.collection('Complaints').get();

    // Calculate the new document ID
    int count = querySnapshot.docs.length;
    String complaintsNumber = (count + 1).toString();
    String customComplaintId = "UNI10 CMPLNT $complaintsNumber";

    // Firestore submission logic with custom document ID
    await FirebaseFirestore.instance
        .collection('Complaints')
        .doc(customComplaintId) // Set custom document ID
        .set(complaintData);

    // Clear form
    _complaintController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _imageFile = null;
    });

    // Show success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const MyAlertDialog(
          title: 'Complaint submitted successfully',
          buttonText: 'OK',
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  "Complaint Form",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // Date & time controller
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Incident Date',
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    onTap: () async {
                      // Show date picker
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        // Allow picking dates from 30 days ago
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        // Set the last date to be the current date
                        lastDate: DateTime.now(),
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
                      labelText: 'Incident Time',
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Colors.deepPurple,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
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
              height: 16,
            ),

            TextFormField(
              controller: _complaintController,
              decoration: const InputDecoration(
                labelText: "Incident Description",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your complaint';
                }
                return null;
              },
            ),

            const SizedBox(
              height: 5.0,
            ),

            Text(
              "* Please include as much details as possible, such as Driver's / Passenger's name",
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(
              height: 20.0,
            ),

            _imageFile != null
                ? Image.file(_imageFile!)
                : ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      // Button padding
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 25,
                      ),

                      side: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'Select Image',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

            const SizedBox(
              height: 50.0,
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
                  width: 25,
                ),

                // Submit button
                ElevatedButton(
                  onPressed: _submitComplaint,
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
