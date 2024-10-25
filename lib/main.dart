import 'package:flutter/material.dart';
import 'package:gtodo/profile.dart'; // Import the profile page.
import 'login.dart'; // Import the login page.

void main() {
  runApp(MyApp());
}

// Main app widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner.
      title: 'Gamified To-Do List',
      theme: ThemeData.dark(), // Use dark theme for consistency.
      initialRoute: '/', // Define the initial route.
      routes: {
        '/': (context) => LoginPage(), // LoginPage as the initial screen.
        '/profile': (context) => ProfilePage(), // Route to ProfilePage.
      },
    );
  }
}
