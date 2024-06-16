import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String buttonText;

  const MyAlertDialog({
    Key? key,
    required this.title,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: Center(
        child: Text(
          title,
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
            buttonText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900], // Customize button color as needed
            ),
          ),
        ),
      ],
    );
  }
}
