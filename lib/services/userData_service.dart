import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> fetchUserProfileField(String userId, String fieldName) async {
  // Get the reference to the user's document
  var userDocument = FirebaseFirestore.instance.collection('Users').doc(userId);

  // Retrieve only the specified field
  var fieldValue = await userDocument.get().then((snapshot) {
    return snapshot.get(fieldName);
  });

  return fieldValue.toString(); // Convert field value to string (if needed)
}
