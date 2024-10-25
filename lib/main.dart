import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:gtodo/home.dart';
import 'package:gtodo/login.dart';
import 'package:gtodo/profile.dart'; // Import the profile page.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
