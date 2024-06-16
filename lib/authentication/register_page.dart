import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:translink/components/my_button.dart';
import 'package:translink/components/my_textfield.dart';
import 'package:translink/components/square_tile_v2.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final contactNumberController = TextEditingController();
  final studentIdController = TextEditingController();

  // Variables with values
  String selectedGender = "Male";
  String selectedRole = "Passenger";
  List<String> genderOptions = ["Male", "Female"];
  List<String> roleOptions = ["Driver", "Passenger"];

  // User sign-up method
  void signUserUp() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Pop the loading circle
    Navigator.pop(context);

    // Try creating the user
    try {
      // Check if password & confirm password match
      if (passwordController.text != confirmPasswordController.text) {
        // Show error message: passwords don't match
        mismatchedPasswordMessage();
        return; // Return to prevent further execution
      }

      // Create user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Call the addUser method
      await addUserDetails(
        fullNameController.text.trim(),
        emailController.text.trim(),
        int.parse(contactNumberController.text.trim()),
        studentIdController.text.trim().toUpperCase(),
        selectedGender,
        selectedRole,
      );

      // Navigate to the next screen or show a success message
      // Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      String errorMessage;
      if (e.code == "invalid-credential") {
        errorMessage = "Invalid login credentials !";
      } else if (e.code == "weak-password") {
        errorMessage = "Password must at least be 6 characters long !";
      } else if (e.code == "email-already-in-use") {
        errorMessage = "Your email address is already in use !";
      } else {
        errorMessage = e.message.toString();
      }
      invalidUserSignUpProcess(errorMessage);
    } catch (e) {
      // Handle unexpected errors
      invalidUserSignUpProcess(e.toString());
    }
  }

  Future addUserDetails(String fullName, String email, int contactNo,
      String studentID, String gender, String role) async {
    User? _user = FirebaseAuth.instance.currentUser;
    // Get a reference to the collection
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection("Users");

    // Query to get the number of documents in the collection
    QuerySnapshot snapshot = await usersCollection.get();

    // Calculate the new document ID
    int maxNum = snapshot.size + 1;
    String userId = "UNI10 USR $maxNum";

    if (role == "Driver") {
      await usersCollection.doc(_user!.uid).set({
        "User ID": userId,
        "Full Name": fullName,
        "Email": email,
        "Contact Number": contactNo,
        "Student ID": studentID,
        "Gender": gender,
        "Role": role,
        "Profile Picture URL": "",
        "Account Creation": DateTime.now(),
        "Completed Rides": 0,
        "Star Rating": 0,
      });
    } else {
      await usersCollection.doc(_user!.uid).set({
        "User ID": userId,
        "Full Name": fullName,
        "Email": email,
        "Contact Number": contactNo,
        "Student ID": studentID,
        "Gender": gender,
        "Role": role,
        "Profile Picture URL": "",
        "Account Creation": DateTime.now(),
      });
    }
  }

  void invalidUserSignUpProcess(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              "Error : $errorMessage",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900], // Customize button color as needed
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Incorrect password validation message pop-up
  void mismatchedPasswordMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error : Passwords don't match !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // Logo
              const SquareTile2(imagePath: "lib/images/register_icon.png"),

              const SizedBox(height: 25),

              // Register message
              const Text(
                "Let's create an account for you !",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Full name text field
              MyTextField(
                controller: fullNameController,
                hintText: "Full Name",
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Email text field
              MyTextField(
                controller: emailController,
                hintText: "Email Address",
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Contact number text field
              MyTextField(
                controller: contactNumberController,
                hintText: "Contact Number",
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Student ID text field
              MyTextField(
                controller: studentIdController,
                hintText: "Student ID",
                obscureText: false,
              ),

              const SizedBox(height: 25),

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
                height: 15,
              ),

              // User role text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  items: roleOptions.map(
                    (option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              option == 'Driver'
                                  ? Icons.drive_eta
                                  : Icons.person_pin_circle,
                              color: option == 'Driver'
                                  ? Colors.orange
                                  : Colors.cyan,
                            ),
                            const SizedBox(width: 10),
                            Text(option),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                  decoration: InputDecoration(
                    labelText: "Select Role",
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

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    '* Each e-mail address can only have one role, think before you choose !',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Password text field
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // Confirm password text field
              MyTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true,
              ),

              const SizedBox(height: 35),

              // Sign-up button
              MyButton(
                onTap: signUserUp,
                text: "SIGN UP",
              ),

              const SizedBox(height: 40),

              // Existing account message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account ?",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login Now",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
