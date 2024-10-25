import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:gtodo/home.dart'; // Adjust based on your project structure

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Show an error if inputs are invalid
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Please enter both email and password."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to HomePage upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-disabled':
            errorMessage =
                'The user corresponding to the given email has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided for that user.';
            break;
          default:
            errorMessage = 'An unknown error occurred.';
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Solid dark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor:
                      const Color.fromRGBO(248, 248, 249, 1).withOpacity(0.8),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFFFDFDFD).withOpacity(0.8),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  // Navigate to signup page
                  print('Navigate to signup page');
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
