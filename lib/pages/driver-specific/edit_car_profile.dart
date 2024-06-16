import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translink/components/my_textfield_v2.dart';
import 'dart:io';

class EditCarProfile extends StatefulWidget {
  final String carID;

  const EditCarProfile({
    super.key,
    required this.carID,
  });

  @override
  State<EditCarProfile> createState() => _EditCarProfileState();
}

class _EditCarProfileState extends State<EditCarProfile> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carPicController = TextEditingController();

  // Variables with values
  List<String> carStatus = ["Active", "Inactive"];
  String selectedCarStatus = "Inactive";
  File? carPicImageFile;

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

  // Method to update car profile in Firebase
  Future<void> _updateCarProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //_uploadImage();
      FirebaseFirestore.instance.collection('Cars').doc(widget.carID).update({
        'Car Brand': _brandController.text,
        'Car Model': _modelController.text,
        'Plate Number': _plateNumberController.text.toString().toUpperCase(),
        'Car Status': selectedCarStatus,
        'Car Color': _carColorController.text,
      }).then((_) {
        // Profile updated successfully
        Navigator.pop(context);
      }).catchError((error) {
        // Handle error
        print("Failed to update car : $error");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.purple[300],
              title: Center(
                child: Text(
                  "Error : $error",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  /*
  // These methods are to handle car image uploading
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        carPicImageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Upload picture button will trigger this method
  Future<void> _uploadImage() async {
    if (carPicImageFile != null) {
      String imageUrl = await uploadImageToStorage(
          carPicImageFile!, _profilePicController.text);
      updateProfileWithImageUrl(imageUrl);
    }
  }

  void updateProfileWithImageUrl(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('Car')
          .doc(widget.carID)
          .update({
        'Car Picture URL': imageUrl,
      });
      print('Profile picture updated successfully.');
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<String> uploadImageToStorage(
      File imageFile, String? previousImageUrl) async {
    try {
      // Delete previous profile picture if it exists
      if (previousImageUrl != null || previousImageUrl != "") {
        await FirebaseStorage.instance.refFromURL(previousImageUrl!).delete();
      }

      // Upload new profile picture
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Profile Pictures')
          .child('$userID.jpg');
      await ref.putFile(imageFile);
      return ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }
  */

  @override
  void initState() {
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Cars')
          .doc(widget.carID)
          .get();
      Map<String, dynamic> userData = snapshot.data()!;
      setState(() {
        _brandController.text = userData["Car Brand"];
        _modelController.text = userData["Car Model"];
        _plateNumberController.text = userData["Plate Number"];
        _carColorController.text = userData["Car Color"];
        _carPicController.text = userData["Car Picture URL"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Edit Car Details',
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
                      // Update car data to Firestore
                      _updateCarProfile();
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
                    "Save",
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
