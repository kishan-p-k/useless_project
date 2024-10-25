import 'package:flutter/material.dart';
import 'package:gtodo/login.dart'; // Import LoginPage
import 'package:gtodo/profile.dart'; // Import ProfilePage
import 'package:gtodo/task.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
            onSelected: (value) {
              if (value == 'profile') {
                // Navigate to Profile Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'logout') {
                // Navigate to Login Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Level: 5',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Equipment: Sword, Shield, Armor',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskPage()),
                );
              },
              child: Text('Go to Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
