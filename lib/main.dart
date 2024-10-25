import 'package:flutter/material.dart';
import 'package:gtodo/home.dart';
import 'package:gtodo/login.dart';
import 'package:gtodo/profile.dart'; // Import the profile page.

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
        '/profile': (context) => ProfilePage(),
        '/home': (context) => HomePage() // Route to ProfilePage.
      },
      // Remove debug banner
    );
  }
}
