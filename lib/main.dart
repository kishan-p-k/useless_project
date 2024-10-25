import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:gtodo/home.dart';
import 'package:gtodo/login.dart';
import 'package:gtodo/profile.dart'; // Import the profile page.
import 'firebase_options.dart'; // Import the generated file with Firebase options.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase with options
  runApp(const MyApp()); // Run the app
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
        '/home': (context) => HomePage(), // Route to HomePage
      },
    );
  }
}
