import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translink/authentication/forgot_pw_page.dart';
import 'package:translink/components/my_button.dart';
import 'package:translink/components/my_textfield.dart';
import 'package:translink/components/square_tile_v2.dart';

import '../components/square_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // User sign-in method
  void signUserIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Try sign-in the user
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle
      Navigator.pop(context);

      wrongCredentialMessage(e.code);
    }
  }

  // Wrong email / password message pop-up
  void wrongCredentialMessage(String errorMessage) {
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
              const SquareTile2(imagePath: "lib/images/translink_app_logo.png"),

              const SizedBox(height: 25),

              // Login message
              const Text(
                "Welcome to TransLink App",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // Email text field
              MyTextField(
                controller: emailController,
                hintText: "Email Address",
                obscureText: false,
              ),

              const SizedBox(height: 20),

              // Password text field
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 15),

              // Forgot password message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const ForgotPasswordPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password ?",
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Sign-in button
              MyButton(
                onTap: signUserIn,
                text: "SIGN IN",
              ),

              const SizedBox(height: 40),

              // Not a member message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Not a member ? ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
