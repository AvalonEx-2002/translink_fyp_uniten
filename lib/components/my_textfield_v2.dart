import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MyTextFieldV2 extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextFieldV2({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: TextField(
        style: const TextStyle(
          fontSize: 15,
        ),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          filled: true,
          labelText: hintText,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
