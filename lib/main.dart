import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'login.dart'; // Import the login page

// Replace with your actual FirebaseOptions
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDnxCcHUP0w0Vx1skOKAluYV1xM3zqF1_E",
  appId: "1:1047909571294:web:f57225d2f2195c4572004f",
  messagingSenderId: "1047909571294",
  projectId: "gtodo-d7d62",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(options: firebaseOptions); // Initialize Firebase with options
  await checkConnection(); // Check Firestore connection
  runApp(const MyApp());
}

Future<void> checkConnection() async {
  try {
    // Attempt to access a document from Firestore
    final doc = await FirebaseFirestore.instance.collection('test_collection').doc('test_document').get();
    if (doc.exists) {
      print('Connection to Firestore is successful!');
    } else {
      print('Document does not exist.');
    }
  } catch (e) {
    print('Failed to connect to Firestore: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set LoginPage as the home widget
    );
  }
}
