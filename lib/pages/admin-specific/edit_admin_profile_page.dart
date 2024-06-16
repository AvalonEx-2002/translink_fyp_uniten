import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translink/components/my_alert_dialog.dart';
import 'package:translink/components/my_textfield_v2.dart';

class EditAdminProfilePage extends StatefulWidget {
  const EditAdminProfilePage({super.key});

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _studentIDController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();

  // Controllers for password change
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables with values
  String selectedGender = "Male";
  List<String> genderOptions = ["Male", "Female"];
  File? _profilePicImageFile;
  String? userID;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Give current user ID to a variable
    userID = user?.uid;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user.uid)
          .get();
      Map<String, dynamic> userData = snapshot.data()!;
      setState(() {
        _nameController.text = userData["Full Name"];

        // Formatting the phone number stored in Firebase
        userData["Contact Number"] = userData["Contact Number"].toString();
        if (userData["Contact Number"][0] != "0") {
          _phoneNumberController.text = "0" + userData["Contact Number"];
        } else {
          _phoneNumberController.text = userData["Contact Number"];
        }

        _studentIDController.text = userData["Student ID"];
        _profilePicController.text = userData["Profile Picture URL"];
        selectedGender = userData["Gender"];
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profilePicImageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Upload picture button will trigger this method
  Future<void> _uploadImage() async {
    if (_profilePicImageFile != null) {
      String imageUrl = await uploadImageToStorage(
          _profilePicImageFile!, _profilePicController.text);
      updateProfileWithImageUrl(imageUrl);
    }
  }

  void updateProfileWithImageUrl(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userID).update({
        'Profile Picture URL': imageUrl,
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

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uploadImage();
      FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'Full Name': _nameController.text.trim(),
        'Contact Number': int.parse(_phoneNumberController.text.trim()),
        'Student ID': _studentIDController.text.trim().toUpperCase(),
        'Gender': selectedGender,
      }).then((_) {
        // Profile updated successfully
        Navigator.pop(context);
      }).catchError((error) {
        // Handle error
        print("Failed to update user: $error");
      });
    }
  }

  // Password change function

  Future<void> _changePassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Re-authenticate the user
        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: _oldPasswordController.text.trim(),
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        if (_newPasswordController.text.trim() ==
            _confirmPasswordController.text.trim()) {
          await user.updatePassword(_newPasswordController.text.trim());

          // Alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MyAlertDialog(
                title: 'Password changed successfully',
                buttonText: 'OK',
              );
            },
          );
        } else {
          // Alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MyAlertDialog(
                title: 'Passwords do not match!',
                buttonText: 'OK',
              );
            },
          );
        }
      } catch (e) {
        print('Error changing password: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MyAlertDialog(
              title: 'Error : $e',
              buttonText: 'OK',
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Edit Profile Details',
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          child: Column(
            children: [
              MyTextFieldV2(
                  controller: _studentIDController,
                  hintText: "Student ID",
                  obscureText: false),

              const SizedBox(
                height: 20,
              ),

              MyTextFieldV2(
                controller: _nameController,
                hintText: "Full Name",
                obscureText: false,
              ),

              const SizedBox(
                height: 20,
              ),

              MyTextFieldV2(
                controller: _phoneNumberController,
                hintText: "Contact Number",
                obscureText: false,
              ),

              const SizedBox(
                height: 30,
              ),

              // Gender text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  items: genderOptions.map(
                    (option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              option == 'Male' ? Icons.male : Icons.female,
                              color:
                                  option == 'Male' ? Colors.blue : Colors.pink,
                            ),
                            const SizedBox(width: 10),
                            Text(option),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: "Select Gender",
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
                height: 30,
              ),

              /*
              Container(
                height: 200, // Adjust the height as needed
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _profilePicImageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_profilePicImageFile!,
                      fit: BoxFit.cover),
                )
                    : const Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

               */

              _profilePicImageFile != null
                  ? Image.file(_profilePicImageFile!)
                  : ElevatedButton(
                      onPressed: _selectImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 130,
                        ),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Select Profile Picture',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(
                height: 30,
              ),

              // Change Password Section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.black,
                  ),
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.shield,
                        color: Colors.blue[900],
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.password,
                        color: Colors.blue[900],
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _oldPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Old Password',
                              labelStyle: TextStyle(
                                fontSize: 13,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                fontSize: 13,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm New Password',
                              labelStyle: TextStyle(
                                fontSize: 13,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 130,
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Change Password',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 5.0,
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "* Only change account password if you need to",
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

              // Cancel & Save button

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
                      _updateProfile();
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
      ),
    );
  }
}
