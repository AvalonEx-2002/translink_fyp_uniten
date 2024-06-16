import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translink/pages/admin-specific/edit_admin_profile_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  // Method to format phone number
  String formatPhoneNumber(int phoneNumber) {
    String phoneNumberString = phoneNumber.toString();
    if (phoneNumberString.length < 7) {
      return phoneNumberString; // Not enough digits, return as is
    }

    // Adding "0" in front of phone number
    if (phoneNumberString[0] != "0") {
      phoneNumberString = "0" + phoneNumberString;
    }

    // Insert the hyphen at the desired position
    return phoneNumberString.substring(0, 3) +
        '-' +
        phoneNumberString.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
              child: Text(
            'User profile not found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ));
        }

        // Extract user profile data
        Map<String, dynamic>? _userData =
            snapshot.data?.data() as Map<String, dynamic>;

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  // Profile picture
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height:
                            70, // Adjusted height to account for border and padding
                        child: Container(
                          padding: const EdgeInsets.all(
                              2), // Space between CircleAvatar and border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: _userData["Profile Picture URL"].isEmpty
                                    ? (_userData["Gender"] == "Male"
                                        ? Image.asset(
                                                "lib/images/profile_pic.png")
                                            .image
                                        : Image.asset(
                                                "lib/images/profile_pic_female.png")
                                            .image)
                                    : NetworkImage(
                                        _userData["Profile Picture URL"]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Student ID : ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_userData["Student ID"]),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                "Name : ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_userData["Full Name"]),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),

                // Other profile details
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          const Text(
                            "Email Address : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_userData["Email"]),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          const Text(
                            "Contact Number : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(formatPhoneNumber(_userData["Contact Number"])),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          const Text(
                            "Gender : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_userData["Gender"]),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            _userData["Gender"] == 'Male'
                                ? Icons.male
                                : Icons.female,
                            color: _userData["Gender"] == 'Male'
                                ? Colors.blue
                                : Colors.pink,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          const Text(
                            "Role : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_userData["Role"]),
                        ],
                      ),
                      // Push down the edit button
                      const SizedBox(
                        height: 25,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit profile page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditAdminProfilePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          // Background color
                          backgroundColor: Colors.deepPurple[300],

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
                          "Edit Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
