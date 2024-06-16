import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.purple[400],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                "List of Users",
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
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final List<DocumentSnapshot> userDocs = snapshot.data!.docs;
                final filteredUserDocs = userDocs.where((userDoc) {
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final name = userData['Full Name'].toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUserDocs.length,
                  itemBuilder: (context, index) {
                    final userData =
                        filteredUserDocs[index].data() as Map<String, dynamic>;
                    final userId = userData["User ID"];
                    final name = userData["Full Name"];
                    final email = userData["Email"];
                    final gender = userData["Gender"];
                    final studentId = userData["Student ID"];
                    final contactNum =
                        formatPhoneNumber(userData["Contact Number"]);
                    final role = userData["Role"];

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
                                  'User ID : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Optionally, can use this : filteredUserDocs[index].id
                                Text(userId),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.credit_card,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Student ID : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(studentId),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.drive_file_rename_outline_sharp,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Full Name : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(name),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.contact_phone_sharp,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Contact Number : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(contactNum),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.contact_mail,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Email Address : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(email),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_circle,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gender : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(gender),
                                const SizedBox(width: 2),
                                gender == "Male"
                                    ? const Icon(
                                        Icons.male,
                                        color: Colors.blue,
                                      )
                                    : const Icon(
                                        Icons.female,
                                        color: Colors.pink,
                                      ),
                              ],
                            ),
                            Row(
                              children: [
                                if (role == "Driver")
                                  const Icon(
                                    Icons.local_taxi,
                                    size: 18,
                                  ),
                                if (role == "Passenger")
                                  const Icon(
                                    Icons.hail,
                                    size: 18,
                                  ),
                                if (role == "Admin")
                                  const Icon(
                                    Icons.admin_panel_settings,
                                    size: 18,
                                  ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Role : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(role),
                              ],
                            ),
                            Center(
                              child: SizedBox(
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
                                        image: userData[
                                                    "Profile Picture URL"]
                                                .isEmpty
                                            ? (userData["Gender"] == "Male"
                                                ? Image.asset(
                                                        "lib/images/profile_pic.png")
                                                    .image
                                                : Image.asset(
                                                        "lib/images/profile_pic_female.png")
                                                    .image)
                                            : NetworkImage(userData[
                                                "Profile Picture URL"]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
