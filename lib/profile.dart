// profile.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gtodo/home.dart';
import 'package:gtodo/login.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        Map<String, dynamic> userData = 
            snapshot.data!.data() as Map<String, dynamic>;
        
        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
            backgroundColor: Colors.blueAccent,
            title: Text('Profile'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(userData),
                const SizedBox(height: 20),
                _buildTaskSummary(userData),
                const SizedBox(height: 20),
                _buildRecentActivities(userData),
                const SizedBox(height: 20),
                _buildSettingsButton(context),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.logout),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(Map<String, dynamic> userData) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purpleAccent,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData['username'] ?? 'User',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Points: ${userData['points'] ?? 0}',
              style: TextStyle(fontSize: 16, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Upgrade Avatar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskSummary(Map<String, dynamic> userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTaskCard('Completed', userData['completed'] ?? 0, Colors.green),
        _buildTaskCard('Skipped', userData['skipped'] ?? 0, Colors.yellow),
        _buildTaskCard('Missed', userData['missed'] ?? 0, Colors.red),
      ],
    );
  }

  Widget _buildTaskCard(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(Map<String, dynamic> userData) {
    List<dynamic> activities = userData['recentActivities'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const SizedBox(height: 10),
        ...activities.map((activity) => _buildActivityTile(
              activity['title'] ?? '',
              activity['date'] ?? '',
            )).toList(),
      ],
    );
  }

  Widget _buildActivityTile(String title, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        date,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text('Settings'),
      ),
    );
  }
}