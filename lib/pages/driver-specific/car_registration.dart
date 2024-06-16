import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:translink/components/my_textfield_v2.dart';

class CarRegistration extends StatefulWidget {
  const CarRegistration({super.key});

  @override
  State<CarRegistration> createState() => _CarRegistrationState();
}

class _CarRegistrationState extends State<CarRegistration> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();

  // Variables with values
  List<String> carStatus = ["Active", "Inactive"];
  String selectedCarStatus = "Inactive";

  // A boolean value for validation checking
  bool validateCarRegistrationFields({
    required String brand,
    required String model,
    required String plateNumber,
    required String carColor,
  }) {
    if (brand.isEmpty ||
        model.isEmpty ||
        plateNumber.isEmpty ||
        carColor.isEmpty) {
      // At least one field is empty
      return false;
    }
    // All fields are filled
    return true;
  }

  // Incomplete field message
  void incompleteForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.purple[300],
          title: const Center(
            child: Text(
              "Please fill in all form fields !",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Car Registration Form',
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
            MyTextFieldV2(
              controller: _brandController,
              hintText: "Car Brand",
              obscureText: false,
            ),
            const SizedBox(
              height: 16,
            ),
            MyTextFieldV2(
              controller: _modelController,
              hintText: "Car Model",
              obscureText: false,
            ),
            const SizedBox(
              height: 16,
            ),
            MyTextFieldV2(
              controller: _carColorController,
              hintText: "Car Color",
              obscureText: false,
            ),
            const SizedBox(
              height: 16,
            ),
            MyTextFieldV2(
              controller: _plateNumberController,
              hintText: "Plate Number",
              obscureText: false,
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCarStatus,
                onChanged: (newValue) {
                  setState(() {
                    selectedCarStatus = newValue!;
                  });
                },
                items: carStatus.map(
                  (option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            option == 'Active'
                                ? Icons.gpp_good_rounded
                                : Icons.gpp_bad_rounded,
                            color: option == 'Inactive'
                                ? Colors.red
                                : Colors.greenAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(option),
                        ],
                      ),
                    );
                  },
                ).toList(),
                decoration: InputDecoration(
                  labelText: "Car Status",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                '* Only a maximum of one "Active" car will be shown to Passengers',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
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
                  width: 20,
                ),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (validateCarRegistrationFields(
                      brand: _brandController.text,
                      model: _modelController.text,
                      plateNumber: _plateNumberController.text,
                      carColor: _carColorController.text,
                    )) {
                      // Add car data to Firestore
                      _addCarToFirestore();

                      // Navigate back to car list page
                      Navigator.pop(context);
                    } else {
                      // Show an error message or handle the incomplete fields
                      incompleteForm();
                    }
                  },
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

  void _addCarToFirestore() async {
    // Get the current user's ID
    final String userID = FirebaseAuth.instance.currentUser!.uid;

    // Get a reference to the 'Cars' collection
    CollectionReference carCollection =
        FirebaseFirestore.instance.collection('Cars');

    // Check if a car with the same plate number already exists
    QuerySnapshot querySnapshot = await carCollection
        .where('Plate Number',
            isEqualTo: _plateNumberController.text.toUpperCase())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Show an error dialog if a car with the same plate number exists
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.purple[300],
            title: const Center(
              child: Text(
                "Car with this plate number already exists !",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      );
      return; // Exit the function to prevent adding the car
    }

    // Get the count of documents in the 'Cars' collection
    int documentCount = (await carCollection.get()).docs.length;
    documentCount = documentCount + 1;

    String carId = "UNI10 VHCL $documentCount";

    // Prepare car data to be added to Firestore
    Map<String, dynamic> carData = {
      'Car Brand': _brandController.text,
      'Car Model': _modelController.text,
      'Owner ID': userID,
      'Plate Number': _plateNumberController.text.toString().toUpperCase(),
      'Car Status': selectedCarStatus,
      'Car Color': _carColorController.text,
      'Car Picture URL': "",
      'Car ID': carId, // Include the Car ID in the document data
    };

    // Set the document with the calculated ID
    await carCollection.doc(carId).set(carData);
  }
}
