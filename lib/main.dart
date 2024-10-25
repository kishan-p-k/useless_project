import 'package:flutter/material.dart';
import 'package:gtodo/profile.dart';

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
      home: ProfilePage(), // Set ProfilePage as the initial screen.
    );
  }
}
