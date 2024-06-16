import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DriverRideOfferForm extends StatefulWidget {
  final String rideOrderID;
  final String driverID;

  const DriverRideOfferForm({
    super.key,
    required this.rideOrderID,
    required this.driverID,
  });

  @override
  State<DriverRideOfferForm> createState() => _DriverRideOfferFormState();
}

class _DriverRideOfferFormState extends State<DriverRideOfferForm> {
  final TextEditingController _fareController = TextEditingController();
  bool _offerSubmitted = false;
  String _fareOffer = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Fare Offer Form',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: _offerSubmitted
          ? Text('You have offered: RM $_fareOffer')
          : TextField(
        controller: _fareController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Enter amount',
          prefixText: 'RM ',
          prefixStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red, // Customize button color as needed
            ),
          ),
        ),
        if (!_offerSubmitted)
          TextButton(
            onPressed: () {
              _submitOffer();
            },
            child: const Text(
              'Submit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  void _submitOffer() async {
    final String fareOffer = _fareController.text.trim();
    if (fareOffer.isNotEmpty) {
      final double fare = double.tryParse(fareOffer) ?? -1;
      if (fare >= 0) {
        try {
          QuerySnapshot existingOffersQuery = await FirebaseFirestore.instance
              .collection('Fare Offers')
              .where('Ride ID', isEqualTo: widget.rideOrderID)
              .where('Driver ID', isEqualTo: widget.driverID)
              .get();

          if (existingOffersQuery.docs.isNotEmpty) {
            // Offer already exists for this ride order by the current driver
            setState(() {
              _offerSubmitted = true;
              _fareOffer = fareOffer;
            });
            Navigator.of(context).pop(); // Close the dialog
          } else {
            // Get the count of the existing offers
            QuerySnapshot allOffersQuery =
            await FirebaseFirestore.instance.collection('Fare Offers').get();
            int offerCount = allOffersQuery.docs.length;

            // Create the new document ID
            String newOfferID = "UNI10 FR OFFER " + (offerCount + 1).toString();

            // Submit the offer to Firebase with the new document ID
            FirebaseFirestore.instance
                .collection('Fare Offers')
                .doc(newOfferID)
                .set({
              'Fare Offer': fareOffer,
              'Driver ID': widget.driverID,
              'Ride ID': widget.rideOrderID,
              'Offer Status': 'Submitted',
              'Offer Created At': FieldValue.serverTimestamp(),
            }).then((_) {
              print('Fare offer submitted successfully with ID: $newOfferID');
              setState(() {
                _offerSubmitted = true;
                _fareOffer = fareOffer;
              });
              Navigator.of(context).pop(); // Close the dialog
            }).catchError((error) {
              print('Failed to submit fare offer: $error');
            });
          }
        } catch (error) {
          print('Error checking existing offers or getting offer count: $error');
        }
      } else {
        // Invalid fare amount
        _showErrorDialog('Please enter a valid fare amount');
      }
    } else {
      // Empty offer input
      _showErrorDialog('Please enter your fare offer');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              'Error: $errorMessage',
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
}
