import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:translink/components/my_app_bar.dart';

class ReviewComplaintsPage extends StatelessWidget {
  const ReviewComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Complaints').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching complaints'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No complaints found'));
          }

          // Group complaints by their resolution status
          final groupedComplaints =
              _groupComplaintsByStatus(snapshot.data!.docs);

          return ListView(
            children: [
              _buildSection('Pending', groupedComplaints['Pending'] ?? []),
              _buildSection('Work In Progress',
                  groupedComplaints['Work In Progress'] ?? []),
              _buildSection('Resolved', groupedComplaints['Resolved'] ?? []),
            ],
          );
        },
      ),
    );
  }

  // Helper function to group complaints by resolution status
  Map<String, List<DocumentSnapshot>> _groupComplaintsByStatus(
      List<DocumentSnapshot> docs) {
    Map<String, List<DocumentSnapshot>> groupedComplaints = {
      'Pending': [],
      'Work In Progress': [],
      'Resolved': [],
    };

    for (var doc in docs) {
      var status = (doc.data() as Map<String, dynamic>)['Resolution Status'] ??
          'Pending';
      groupedComplaints[status]?.add(doc);
    }

    return groupedComplaints;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.redAccent;
      case 'Work In Progress':
        return Colors.orangeAccent;
      case 'Resolved':
        return Colors.greenAccent;
      default:
        return Colors.blueAccent; // Fallback color
    }
  }

  // Helper function to build section
  Widget _buildSection(String status, List<DocumentSnapshot> complaints) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(15, 15, 15, 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "$status",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        ...complaints.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          return ComplaintCard(
            complaintData: data,
            complaintId: document.id,
          );
        }).toList(),
      ],
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaintData;
  final String complaintId;

  const ComplaintCard({
    required this.complaintData,
    required this.complaintId,
  });

  Future<String?> _getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        return data?['Full Name'] ?? 'Unknown User';
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserName(complaintData['Sender ID']),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Unknown User';
        if (snapshot.connectionState == ConnectionState.waiting) {
          userName = 'Loading...';
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Complaint ID : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(complaintId),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    'Sender Name : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(userName),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    'Date : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(complaintData['Date']),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    'Time : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(complaintData['Time']),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    'Status : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(complaintData['Resolution Status']),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Complaint Description :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                complaintData['Complaint Description'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (complaintData['Supporting Picture URL'] != null &&
                  complaintData['Supporting Picture URL'].isNotEmpty)
                Image.network(complaintData['Supporting Picture URL']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add action for marking the complaint as 'Work In Progress'
                      _updateComplaintStatus(complaintId, 'Work In Progress');
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            // Color when the button is pressed
                            return Colors.yellow.withOpacity(0.5);
                          }
                          // Color when the button is not pressed
                          return Colors.yellow;
                        },
                      ),
                    ),
                    child: const Text(
                      'In Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add action for resolving the complaint
                      _updateComplaintStatus(complaintId, 'Resolved');
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.black,
                          width: 1.5,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            // Color when the button is pressed
                            return Colors.greenAccent.withOpacity(0.5);
                          }
                          // Color when the button is not pressed
                          return Colors.greenAccent;
                        },
                      ),
                    ),
                    child: const Text(
                      'Resolve',
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
        );
      },
    );
  }

  void _updateComplaintStatus(String complaintId, String status) {
    FirebaseFirestore.instance
        .collection('Complaints')
        .doc(complaintId)
        .update({'Resolution Status': status});
  }
}
