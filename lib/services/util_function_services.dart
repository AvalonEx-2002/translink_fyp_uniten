import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UtilityFunction {
  // Truncate text if it exceeds a certain number of characters
  static String truncateText(String? text, int maxLength) {
    if (text != null && text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text ?? '';
  }

  // Functions for offers widget
  static Future<Map<String, dynamic>?> fetchDriverDetails(
      String driverId) async {
    try {
      DocumentSnapshot driverDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(driverId)
          .get();

      if (driverDoc.exists && driverDoc.data() != null) {
        return driverDoc.data() as Map<String, dynamic>;
      } else {
        print('Driver document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching driver details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchCarDetails(String ownerId) async {
    QuerySnapshot carQuery = await FirebaseFirestore.instance
        .collection('Cars')
        .where('Owner ID', isEqualTo: ownerId)
        .where('Car Status', isEqualTo: 'Active')
        .limit(1)
        .get();

    if (carQuery.docs.isNotEmpty) {
      return carQuery.docs.first.data() as Map<String, dynamic>;
    }

    return {
      'Car Model': 'No car info available',
      'License Plate': 'N/A',
    };
  }
}
