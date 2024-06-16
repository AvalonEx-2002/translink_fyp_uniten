import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translink/models/chat_message.dart';

class ChatService {
  // Get instance of auth & Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;

        // Ensure the document data is non-null
        if (data == null) {
          return <String, dynamic>{};
        }

        // Ensure the required fields are present
        return {
          "email": data["Email"] ?? 'Unknown Email',
          "uid": doc.id ?? 'Unknown UID',
          "fullName": data["Full Name"] ?? 'Unknown Name',
        };
      }).toList();
    });
  }

  // Send messages
  Future<void> sendMessage(String receiverID, String message) async {
    // Get current user info
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final String currentUserID = currentUser.uid;
    final String currentUserEmail = currentUser.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // Sort the IDs (this ensures chatRoomID is the same for any two people)
    String chatRoomID = ids.join("<=>");

    // Add new message to the database
    await _firestore
        .collection("Chat Rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Construct a chatRoomID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("<=>");

    return _firestore
        .collection("Chat Rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
