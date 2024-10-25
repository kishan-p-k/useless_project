import 'package:flutter/material.dart';
import 'package:gtodo/login.dart';
import 'package:gtodo/profile.dart';
import 'package:gtodo/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int firstEvolutionLevel = 20;
  final int secondEvolutionLevel = 45;

  String getPokemonGif(int level) {
    if (level > secondEvolutionLevel) {
      return 'assets/char3.gif';
    } else if (level >= 45) {
      return 'assets/char3_1.gif';
    } else if (level >= 25) {
      return 'assets/chr2.gif';
    } else if (level >= firstEvolutionLevel) {
      return 'assets/char2_2.gif';
    } else if (level >= 18) {
      return 'assets/char1_5.gif';
    } else if (level >= 10) {
      return 'assets/char1_4.gif';
    } else if (level >= 5) {
      return 'assets/char1_3.gif';
    } else if (level >= 2) {
      return 'assets/char1_2.gif';
    } else {
      return 'assets/char1_1.gif';
    }
  }

  Future<void> tryLevelUp(
      int currentPoints, int currentLevel, BuildContext context) async {
    int pointsNeeded = currentLevel * 2;

    if (currentPoints >= pointsNeeded) {
      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        'points': currentPoints - pointsNeeded,
        'level': currentLevel + 1,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Level Up! You are now level ${currentLevel + 1}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Not enough points! You need $pointsNeeded points to level up')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['username'] ?? 'User';
        int level = userData['level'] ?? 1;
        int points = userData['points'] ?? 0;

        String currentDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
        String currentTime = DateFormat('hh:mm a').format(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.person),
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  } else if (value == 'logout') {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: Center(  // Added Center widget here
            child: SingleChildScrollView(  // Added for better scrolling behavior
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // Changed to center
                  crossAxisAlignment: CrossAxisAlignment.center,  // Added for horizontal centering
                  children: [
                    Text(
                      currentDate,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,  // Added for text centering
                    ),
                    Text(
                      currentTime,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,  // Added for text centering
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        getPokemonGif(level),
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Level: $level',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,  // Added for text centering
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Points: $points',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,  // Added for text centering
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => tryLevelUp(points, level, context),
                      icon: const Icon(Icons.arrow_upward),
                      label: Text('Level Up (${level * 2} points needed)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskPage()),
              );
            },
            child: const Icon(Icons.task),
          ),
          bottomNavigationBar: const BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: SizedBox(height: 50),
          ),
        );
      },
    );
  }
}