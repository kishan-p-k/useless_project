import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gtodo/login.dart'; // Ensure this path is correct based on your project structure

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signUp(BuildContext context) async {
    String email = emailController.text;
    String username = usernameController.text;
    String password = passwordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Please enter all fields."),
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
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally, you can save the username to Firestore or your backend here.

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The email is already in use.';
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
          title: Text("Sign Up Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      print('Sign up error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Circular avatar for profile image
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/th1.jpg'), 
              ),
              SizedBox(height: 20.0),
              Text(
                'Create Account',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded edges
                  ),
                  filled: true,
                  fillColor: const Color.fromRGBO(248, 248, 249, 1).withOpacity(0.3), // Adjust transparency
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded edges
                  ),
                  filled: true,
                  fillColor: const Color.fromRGBO(248, 248, 249, 1).withOpacity(0.3), // Adjust transparency
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded edges
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFDFDFD).withOpacity(0.3), // Adjust transparency
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _signUp(context),
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
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
